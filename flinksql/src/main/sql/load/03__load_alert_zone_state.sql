insert into ws_active_alert_states
    select
        alert.`alertId` as `alertId`,
        z.`state` as `state`,
        alert.`alertStatus` as `status`,
        alert.`category` as `category`,
        alert.`severity` as `severity`,
        alert.`urgency` as `urgency`,
        alert.`onsetTs` as `onsetTs`,
        alert.`effectiveTs` as `effectiveTs`,
        alert.`expiryTs` as `expiryTs`,
        alert.`endTs` as `endTs`,
        alert.`eventTs` as `eventTs`
    from ws_active_alerts_zone_expanded alert
    join ws_zones z on
        alert.`zoneId` = z.`zoneId`
    where alert.`alertStatus` in ('Actual') and z.`state` is not null;

