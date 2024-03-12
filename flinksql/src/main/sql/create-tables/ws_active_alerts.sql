create table ws_active_alerts (
    `id` STRING PRIMARY KEY NOT ENFORCED,
    `areaDesc` STRING,
    `geocodeSAME` ARRAY<STRING>,
    `geocodeUGC` ARRAY<STRING>,
    `affectedZones` ARRAY<STRING>,
    `sent` TIMESTAMP(3),
    `effective` TIMESTAMP(3),
    `onset` TIMESTAMP(3),
    `expires` TIMESTAMP(3),
    `ends` TIMESTAMP(3),
    `status` STRING,
    `messageType` STRING,
    `category` STRING,
    `severity` STRING,
    `certainty` STRING,
    `urgency` STRING,
    `event` STRING,
    `sender` STRING,
    `senderName` STRING,
    `headline` STRING,
    `description` STRING,
    `instruction` STRING,
    `response` STRING,
    `NWSheadline` ARRAY<STRING>,
    `eventEndingTime` ARRAY<TIMESTAMP(3)>,
    `expiredReferences` ARRAY<STRING>,
    WATERMARK for `onset` AS `onset` - INTERVAL '5' MINUTE)
with ('value.format' = 'avro-registry', 'changelog.mode' = 'upsert', 'kafka.cleanup-policy' = 'delete');



