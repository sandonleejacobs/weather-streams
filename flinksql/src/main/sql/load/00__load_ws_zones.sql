insert into ws_zones (
    `zoneId`, `url`, `name`, `zoneType`, `state`, `cwas`, `forecastOffices`, `timeZones`, `radarStation`
) select
    `id` as `zoneId`, `url` as `url`, `name` as `name`, `zoneType` as `zoneType`,
    `state` as `state`, `cwas` as `cwas`, `forecastOffices` as `forecastOffices`,
    `timeZones` as `timeZones`, `radarStation` as `radarStation`
from  NoaaZonesInbound;