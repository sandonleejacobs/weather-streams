import asyncio

import aiohttp

from .auth import require_dpat
from .errors import EndpointError
from lib.log import get_logger
import copy
import random
import requests
import time

log = get_logger()

API_ROOT = 'https://%(subdomain)s.%(domain)s/sql/%(api_version)s'
STMTS_PATH = '/organizations/%(org)s/environments/%(env)s/statements'


def random_id(n=16):
    # Generate a random hex string of length n
    return ('%0' + str(n) + 'x') % random.randrange(16 ** n)


class StatementsEndpointError(EndpointError):
    pass


class StatementsEndpoint(object):

    def __init__(self, auth, conf):
        self.auth = auth
        self.conf = conf
        self.poll_ms = 300
        self.name_prefix = self.conf['flink'].get('name_prefix', 'flink-client-')
        self.api_version = self.conf['flink'].get('api_version', 'v1beta1')
        self.root_url = self.generate_url()
        d = {}
        for p in ('sql.current-catalog', 'sql.current-database'):
            if p in self.conf['flink']:
                d[p] = self.conf['flink'][p]
        self.default_properties = d

    @property
    def headers(self):
        return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer %s' % self.auth.dpat.token,
            'User-Agent': 'flinklab'
        }

    def generate_url(self, *path):
        url = (API_ROOT + STMTS_PATH) % {
            'api_version': self.api_version,
            'subdomain': self.conf['flink']['subdomain'],
            'domain': self.conf['ccloud']['domain'],
            'org': self.conf['ccloud']['org'],
            'env': self.conf['ccloud']['env']
        }
        if path:
            path = '/%s' % '/'.join(path)
            url += path
        return url

    @require_dpat
    async def get(self, stmt_name):
        url = self.generate_url(stmt_name)

        # r = requests.get(url, headers=self.headers)
        #  use aiohttp to make the request instead of requests

        async with aiohttp.ClientSession() as session:
            async with session.get(url, headers=self.headers) as r:
                # Don't blow up the caller on 404, just let them deal with it however they want
                if r.status == 404:
                    return None
                if r.status != 200:
                    raise StatementsEndpointError(r)
                json = await r.json()
                return json

    @require_dpat
    async def create(self, sql, properties=None, prefix=None):
        start_time = time.time()
        # Any properties passed to this method take precedence over configuration file
        props = copy.deepcopy(self.default_properties)
        props.update(properties or {})
        prefix = prefix or self.name_prefix
        stmt = {
            'name': prefix + random_id(n=12),
            'spec': {
                'compute_pool_id': self.conf['flink']['compute_pool'],
                'principal': self.conf['flink']['principal'],
                'statement': sql,
                'properties': props
            }
        }
        event = {
            'request': stmt
        }
        log.debug('submitting create statement request', extra=event)

        # r = requests.post(self.root_url, headers=self.headers, json=stmt)
        async with aiohttp.ClientSession() as session:
            async with session.post(self.root_url, headers=self.headers, json=stmt) as r:
                end_time = time.time()
                time_taken = end_time - start_time
                if r.status != 200:
                    raise StatementsEndpointError(r)
                stmt_res = await r.json()
                event = {
                    'response': stmt_res
                }
                log.debug('created statement %s', stmt_res['name'], extra=event)
                return stmt_res

    @require_dpat
    async def results(self, stmt_name, continuous_query=False):
        url = self.generate_url(stmt_name, 'results')
        row_count = 0
        while True:
            # If we didn't get data or a next url, server is done sending us rows
            if not url:
                break

            # We may get a redirect to another domain here, so we can't follow redirects
            # automatically. Like most http libraries, requests will strip the auth header
            # before following a redirect to another domain in order to avoid inadvertently
            # sending it to a domain that the original request didn't ask for.
            # r = requests.get(url, headers=self.headers, allow_redirects=False)

            async with aiohttp.ClientSession() as session:
                async with session.get(url, headers=self.headers, allow_redirects=False) as r:
                    if r.status == 307:
                        url = r.next.url
                        continue
                    if r.status != 200:
                        raise StatementsEndpointError(r)

                    r = await r.json()

                    page = r['results']['data']
                    url = r['metadata']['next']

                    if not page:
                        # Never stopping polling in continuous mode
                        if continuous_query:
                            continue
                        else:
                            # If the last fetch had data but this one did not, we're done polling results
                            if row_count:
                                break

                        # No data, so wait a little bit before trying again
                        # TODO(derekjn): use exponential backoff up to 1s when no results
                        time.sleep(self.poll_ms / 1000.)
                        continue

                    # Note that since we got data, we immediately hit the results url again for more
                    row_count += len(page)
                    for data in page:
                        # Each element of data can take one of two forms (although a given statement will
                        # only return one of these formats, they won't be mixed):
                        #
                        # 1. No changelog: Each element of data looks like this:
                        # {
                        #   'row': ['value1', 'value2']
                        # }
                        #
                        # The row itself is just an array of values, one per column.
                        #
                        # 2. Changelog: Each element of data looks like this:
                        # {
                        #   'op': 0,
                        #   'row': ['value1', 'value2']
                        # }
                        #
                        # Operation is given as an integer in [0, 3]
                        #
                        # The meaning of each operation code is as follows:
                        #
                        # 0 (+I): INSERT, insert a new row into result
                        # 1 (-U): UPDATE_BEFORE, update operation, contains row before update
                        # 2 (+U): UPDATE_AFTER, update operation, contains row after update
                        # 3 (-D): DELETE, delete row from result
                        yield data
                    await asyncio.sleep(0.001)
                await asyncio.sleep(0.001)
            await asyncio.sleep(0.001)
        await asyncio.sleep(0.001)

    @require_dpat
    async def wait_for_status(self, stmt, *status, timeout=2 * 60):
        if not status:
            raise ValueError('expected at least one status to wait for')
        # Ignore case for status in case the API changes
        status = tuple(map(lambda s: s.lower(), status))
        start = time.time()
        name = stmt['name']
        while time.time() - start < timeout:
            s = await self.get(name)
            # Update the caller's statement with the latest metadata
            stmt.update(s)
            phase = s['status']['phase'].lower()
            if phase in status:
                return s
            # If caller isn't waiting for failed status, return None to indicate
            # that the wait operation failed. We do this instead of throw an exception
            # because it gives the caller more freedom around error handling.
            if phase == 'failed':
                return
            time.sleep(self.poll_ms / 1000.)
        # If we never returned, it's a timeout :(
        raise TimeoutError('timed out waiting for status %s for statement %s' % (status, name))