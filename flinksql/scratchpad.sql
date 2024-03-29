select a.alertId, a.zoneId, z.state, z.url from
ws_active_alerts_zone_expanded a
  left join NoaaZonesInbound z for SYSTEM_TIME as of a.`$rowtime` on a.zoneId = z.id;


select count(distinct alertId) as alertCount, state from ws_active_alerts_zone_states group by state;