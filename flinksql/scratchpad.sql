-- Example CROSS JOIN UNNEST statement on the zones table.
-- not sure we'll ever need this in the zones data, but just wanted to stash here for reference.

-- expands the `forecastOffices` array in to rows.
select NoaaZonesInbound.id, NoaaZonesInbound.name, `ZonesExpanded`.office from NoaaZonesInbound
    CROSS JOIN UNNEST(NoaaZonesInbound.forecastOffices) as `ZonesExpanded`(office)
limit 10;
-- =======================================================================
-- ? Could this be a future subquery, if Flink SQL on CC supports that?
-- =======================================================================

-- `properties` in the NoaAlertsActiveInbound table is a `ROW` type with this schema:
ROW<`x_40id` STRING NOT NULL,
    `x_40type` STRING NOT NULL,
    `id` STRING NOT NULL,
    `areaDesc` STRING NOT NULL,
    `geocode` ROW<`SAME` ARRAY<STRING NOT NULL> NOT NULL, `UGC` ARRAY<STRING NOT NULL> NOT NULL> NOT NULL,
    `affectedZones` ARRAY<STRING NOT NULL> NOT NULL,
    `references` ARRAY<ROW<`x_40id` STRING NOT NULL,
    `identifier` STRING NOT NULL,
    `sender` STRING NOT NULL,
    `sent` TIMESTAMP(3) NOT NULL> NOT NULL> NOT NULL,
    `sent` TIMESTAMP(3) NOT NULL,
    `effective` TIMESTAMP(3) NOT NULL,
    `onset` TIMESTAMP(3) NOT NULL,
    `expires` TIMESTAMP(3) NOT NULL,
    `ends` TIMESTAMP(3),
    `status` STRING NOT NULL,
    `messageType` STRING NOT NULL,
    `category` STRING NOT NULL,
    `severity` STRING NOT NULL,
    `certainty` STRING NOT NULL,
    `urgency` STRING NOT NULL,
    `event` STRING NOT NULL,
    `sender` STRING NOT NULL,
    `senderName` STRING NOT NULL,
    `headline` STRING NOT NULL,
    `description` STRING,
    `instruction` STRING,
    `response` STRING NOT NULL,
    `parameters` ROW<`AWIPSidentifier` ARRAY<STRING NOT NULL> NOT NULL,
    `WMOidentifier` ARRAY<STRING NOT NULL> NOT NULL,
    `NWSheadline` ARRAY<STRING NOT NULL>,
    `BLOCKCHANNEL` ARRAY<STRING NOT NULL> NOT NULL,
    `VTEC` ARRAY<STRING NOT NULL>,
    `eventEndingTime` ARRAY<TIMESTAMP(3) NOT NULL>,
    `EAS_ORG` ARRAY<STRING NOT NULL>,
    `expiredReferences` ARRAY<STRING NOT NULL>,
    `eventMotionDescription` ARRAY<STRING NOT NULL>> NOT NULL
>
)



-- expands the GEO codes (UGC) in the active alerts table:
select id, `ActiveAlertsByUgcCode`.geocodeugc from ws_active_alerts CROSS JOIN UNNEST(ws_active_alerts.geocodeUGC) as `ActiveAlertsByUgcCode`(geocodeugc) limit 100;

-- sample join of unnested date
select active.id as alertId, `ActiveAlertsByUgcCode`.geocodeugc, zone.id as zoneId, zone.name as zoneName, zone.state as zoneState
    from ws_active_alerts active CROSS JOIN UNNEST(active.geocodeUGC) as `ActiveAlertsByUgcCode`(geocodeugc)
    join NoaaZonesInbound zone on `ActiveAlertsByUgcCode`.geocodeugc = zone.id
limit 100;

select
    active.id as alertId, active.category as category, active.severity as severity, active.urgency as urgency,
    active.event as event, active.headline as headline, active.description as description, active.instruction as instruction,
    active.response as response, `ActiveAlertsByUgcCode`.geocodeugc as zoneId,
    zone.name as zoneName, zone.state as zoneState, zone.geometry as zoneGeometry
from ws_active_alerts active
    CROSS JOIN UNNEST(active.geocodeUGC) as `ActiveAlertsByUgcCode`(geocodeugc)
join NoaaZonesInbound zone
    on `ActiveA_lertsByUgcCode`.geocodeugc = zone.id
limit 100;



-- data observations
select * from ws_active_alerts where messageType <> 'Cancel' and certainty <> 'Likely' limit 20;
