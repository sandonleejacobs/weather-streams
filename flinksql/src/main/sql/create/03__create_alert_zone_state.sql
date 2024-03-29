create table ws_active_alerts_zone_states (
    `alertId` STRING,
    `zoneId` STRING,
    `zoneUrl` STRING,
    `state` STRING,
    `status` STRING,
    `category` STRING,
    `severity` STRING,
    `urgency` STRING,
    `onsetTs` TIMESTAMP_LTZ(3),
    `effectiveTs` TIMESTAMP_LTZ(3),
    `expiryTs` TIMESTAMP_LTZ(3),
    `endTs` TIMESTAMP_LTZ(3),
    PRIMARY KEY (`alertId`, `zoneId`) NOT ENFORCED
) DISTRIBUTED BY (`alertId`, `zoneId`) INTO 3 BUCKETS
WITH (
    'key.format' = 'avro-registry',
    'value.format' = 'avro-registry',
    'changelog.mode' = 'upsert',
    'kafka.cleanup-policy' = 'compact');
