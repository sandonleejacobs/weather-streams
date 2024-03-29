create table ws_active_alerts_zone_expanded (
    alertId STRING,
    zoneId STRING,
    event STRING,
    alertStatus STRING,
    alertMessageType STRING,
    category STRING,
    severity STRING,
    urgency STRING,
    headline STRING,
    description STRING,
    instruction STRING,
    response STRING,
    sentTs TIMESTAMP_LTZ(3),
    sender STRING,
    onsetTs TIMESTAMP_LTZ(3),
    effectiveTs TIMESTAMP_LTZ(3),
    expiryTs TIMESTAMP_LTZ(3),
    endTs TIMESTAMP_LTZ(3),
    nwsHeadline ARRAY<STRING>,
    `eventTs` TIMESTAMP_LTZ(3) METADATA FROM 'timestamp',
    WATERMARK FOR `eventTs` as `eventTs` - INTERVAL '5' MINUTES,
    PRIMARY KEY (alertId, zoneId) NOT ENFORCED
)
DISTRIBUTED BY (alertId, zoneId) INTO 3 BUCKETS
with (
    'key.format' = 'avro-registry',
    'value.format' = 'avro-registry',
    'kafka.cleanup-policy' = 'delete',
    'kafka.retention.time' = '5 minutes');
