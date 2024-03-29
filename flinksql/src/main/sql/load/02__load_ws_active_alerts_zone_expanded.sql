insert into ws_active_alerts_zone_expanded select
    active.`id` as `alertId`,
    `ActiveAlertsByUgcCode`.geocodeugc as `zoneId`,
    active.`event` as `event`,
    active.`status` as `alertStatus`,
    active.`messageType` as `alertMessageType`,
    active.`category` as `category`,
    active.`severity` as `severity`,
    active.`urgency` as `urgency`,
    active.`headline` as `headline`,
    active.`description` as `description`,
    active.`instruction` as `instruction`,
    active.`response` as `response`,
    active.`sent` as `sentTs`,
    active.`sender` as `sender`,
    active.`onset` as `onsetTs`,
    active.`effective` as `effectiveTs`,
    active.`expires` as `expiryTs`,
    active.`ends` as `endTs`,
    active.`NWSheadline` as `nwsHeadline`,
    active.`eventTs` as `eventTs`
from ws_active_alerts active
    CROSS JOIN UNNEST(active.geocodeUGC) as `ActiveAlertsByUgcCode`(geocodeugc);
