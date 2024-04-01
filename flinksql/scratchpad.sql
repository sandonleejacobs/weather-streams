select a.alertId, a.zoneId, z.state, z.url from
ws_active_alerts_zone_expanded a
  left join NoaaZonesInbound z for SYSTEM_TIME as of a.`$rowtime` on a.zoneId = z.id;


select count(distinct alertId) as alertCount, state from ws_active_alert_states group by state;



SELECT window_start, window_end, state, count(alertId) as `sum`
  FROM TABLE(
    TUMBLE(TABLE ws_active_alert_states, DESCRIPTOR($rowtime), INTERVAL '5' MINUTES))
  GROUP BY window_start, window_end, state;



  SELECT state, count(distinct alertId) OVER (
      PARTITION BY alertId
      ORDER BY eventTs
      RANGE BETWEEN INTERVAL '5' MINUTE PRECEDING AND CURRENT ROW
    ) AS alertsCount
  FROM ws_active_alert_states;



  SELECT state, COUNT(distinct alertId)
  FROM ws_active_alert_states
  GROUP BY ROLLUP (state);