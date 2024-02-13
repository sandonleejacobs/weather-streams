select
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.id') as event_url,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.id') as id,
    JSON_QUERY(DECODE(val, 'UTF-8'), '$.properties.geocode.SAME') as geoCodesSAME,
    JSON_QUERY(DECODE(val, 'UTF-8'), '$.properties.affectedZones') as affectedZones,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.sent') as sentTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.effective') as effectiveTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.onset') as onsetTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.expires') as expireTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.ends') as endTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.status') as status,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.messageType') as messageType,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.category') as category
from noaa_alerts_active_inbound limit 10;


create table foo_step_2 (
    id STRING PRIMARY KEY NOT ENFORCED,
    event_url STRING,
    geoCodesUGC STRING
) with ('value.format' = 'avro-registry');


insert into foo_step_2 select
                    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.id') as id,
                    JSON_VALUE(DECODE(val, 'UTF-8'), '$.id') as event_url,
                    JSON_QUERY(DECODE(val, 'UTF-8'), '$.properties.geocode.UGC' WITH CONDITIONAL ARRAY WRAPPER) as geoCodesUGC
                from noaa_alerts_active_inbound;


select id, event_url, geo_code_ugc from foo_step_2 cross join unnest(JSON_STRING(geoCodesUGC)) as g (geo_code_ugc) limit 100;


create table alert_rowed (
    id STRING PRIMARY KEY NOT ENFORCED,

)

select
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.id') as event_url,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.id') as id,
    CAST(JSON_QUERY(DECODE(val, 'UTF-8'), '$.properties.geocode.UGC') as STRING) as geoCodesUGC,
    JSON_QUERY(DECODE(val, 'UTF-8'), '$.properties.affectedZones') as affectedZones,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.sent') as sentTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.effective') as effectiveTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.onset') as onsetTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.expires') as expireTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.ends') as endTs,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.status') as status,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.messageType') as messageType,
    JSON_VALUE(DECODE(val, 'UTF-8'), '$.properties.category') as category
from noaa_alerts_active_inbound limit 10;