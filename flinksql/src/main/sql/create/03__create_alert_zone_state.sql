create table ws_active_alert_states (
    `alertId` STRING,
    `state` STRING,
    `status` STRING,
    `category` STRING,
    `severity` STRING,
    `urgency` STRING,
    `onsetTs` TIMESTAMP_LTZ(3),
    `effectiveTs` TIMESTAMP_LTZ(3),
    `expiryTs` TIMESTAMP_LTZ(3),
    `endTs` TIMESTAMP_LTZ(3),
    `eventTs` TIMESTAMP_LTZ(3) METADATA FROM 'timestamp',
    WATERMARK FOR `eventTs` as `eventTs` - INTERVAL '5' MINUTES,
    PRIMARY KEY (`alertId`) NOT ENFORCED
) DISTRIBUTED BY (`alertId`) INTO 3 BUCKETS
WITH (
    'value.format' = 'avro-registry',
    'kafka.cleanup-policy' = 'delete',
    'kafka.retention.time' = '10 minutes');
