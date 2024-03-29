create table ws_zones (
    zoneId STRING,
    url STRING,
    name STRING,
    zoneType STRING,
    state STRING,
    cwas ARRAY<STRING>,
    forecastOffices ARRAY<STRING>,
    timeZones ARRAY<STRING>,
    radarStation STRING,
    `ts` TIMESTAMP_LTZ(3) METADATA FROM 'timestamp',
    PRIMARY KEY (zoneId) NOT ENFORCED
) with (
    'key.format' = 'avro-registry',
    'value.format' = 'avro-registry',
    'kafka.cleanup-policy' = 'compact',
    'changelog.mode' = 'upsert'
);