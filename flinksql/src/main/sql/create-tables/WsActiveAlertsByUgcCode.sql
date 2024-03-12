create table WsActiveAlertsByZone (
    alertId STRING,
    zoneId STRING,
    zoneUrl STRING,
    event STRING,
    alertStatus STRING,
    alertMessageType STRING,
    zoneName STRING,
    zoneState STRING,
    category STRING,
    severity STRING,
    urgency STRING,
    headline STRING,
    description STRING,
    instruction STRING,
    response STRING,
    zoneGeometry STRING,
    sentTs TIMESTAMP_LTZ(3),
    sender STRING,
    onsetTs TIMESTAMP_LTZ(3),
    effectiveTs TIMESTAMP_LTZ(3),
    expiryTs TIMESTAMP_LTZ(3),
    endTs TIMESTAMP_LTZ(3),
    nwsHeadline ARRAY<STRING>,
    PRIMARY KEY (alertId, zoneId) NOT ENFORCED
)
with (
    'key.format' = 'avro-registry',
    'value.format' = 'avro-registry',
    'changelog.mode' = 'upsert',
    'kafka.cleanup-policy' = 'delete');
