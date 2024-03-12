insert into WsActiveAlertsByZone select
    active.`id` as `alertId`,
    `ActiveAlertsByUgcCode`.geocodeugc as `zoneId`,
    zone.`url` as `zoneUrl`,
    active.`event` as `event`,
    active.`status` as `alertStatus`,
    active.`messageType` as `alertMessageType`,
    zone.`name` as `zoneName`,
    zone.`state` as `zoneState`,
    active.`category` as `category`,
    active.`severity` as `severity`,
    active.`urgency` as `urgency`,
    active.`headline` as `headline`,
    active.`description` as `description`,
    active.`instruction` as `instruction`,
    active.`response` as `response`,
    zone.`geometry` as `zoneGeometry`,
    active.`sent` as `sentTs`,
    active.`sender` as `sender`,
    active.`onset` as `onsetTs`,
    active.`effective` as `effectiveTs`,
    active.`expires` as `expiryTs`,
    active.`ends` as `endTs`,
    active.`NWSheadline` as `nwsHeadline`
from ws_active_alerts active
    CROSS JOIN UNNEST(active.geocodeUGC) as `ActiveAlertsByUgcCode`(geocodeugc)
join NoaaZonesInbound zone
    on `ActiveAlertsByUgcCode`.geocodeugc = zone.id;