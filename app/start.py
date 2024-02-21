import asyncio
import random
import altair as alt
import streamlit as st
from pandas import DataFrame

from api.auth import AuthEndpoint
from api.statements import StatementsEndpoint
from lib.config import Config
from lib.flink import Changelog

async def query(conf, sql, continuous_query):
    auth = AuthEndpoint(conf)
    statements = StatementsEndpoint(auth, conf)

    stmt = await statements.create(sql)
    print(f'running statement {sql}')
    ready = await statements.wait_for_status(stmt, 'running', 'completed')
    print(f'ready = {ready}')
    schema = ready['status']['result_schema']
    name = ready['name']
    # this is an async generator, not a blocking function
    results = statements.results(name, continuous_query)
    return results, schema


def random_array_of_tuples(n):
    return [(random.randint(1, 10), random.randint(1, 1000)) for _ in range(n)]


async def populate_table(widget, sql, continuous_query):
    conf = Config('./config.yml')
    print(conf)
    results, schema = await query(conf, sql, continuous_query)
    print(f'results = {results}')
    changelog = Changelog(schema, results)
    await changelog.consume(1)
    table = changelog.collapse()
    while True:
        new_data = await changelog.consume(1)
        table.update(new_data)
        # wait until we get the update-after to render, otherwise graphs
        # and tables content "jump" around.
        if new_data[0][0] != "-U":
            df = DataFrame(table, None, table.columns)
            df.sort_values(by=df.columns[0], inplace=True)
            widget.dataframe(df, hide_index=True,
                             column_config={"state": "state"})
        await asyncio.sleep(0.01)


async def main():
    st.title("Streamlit Weather on Confluent Cloud for Flink")
    
    col1, col2 = st.columns(2)

    with col1:
        st.header("States")
        states_table = st.empty()

        # st.header("Graphs")
        # average_balance_table = st.empty()

    with col2:
        st.header("Maps")
        map_of_users = st.empty()

    states_table_query = """
        select distinct(state) as state from NoaaZonesInbound limit 60;
        """
    await asyncio.gather(
        populate_table(states_table, states_table_query, continuous_query=True)
    )


# if __name__ == "__main__":
asyncio.run(main())