select
    active.`window_start` as `window_start`, active.`window_end` as `window_end`,
    count(active.`id`) as `activeAlertCount`,
    zone.`state` as `zoneState`
    from (
        SELECT * from TABLE(TUMBLE(TABLE ws_active_alerts, descriptor($rowtime), INTERVAL '60' minutes))
    ) active
    CROSS JOIN UNNEST(active.geocodeUGC) as `ActiveAlertsByUgcCode`(geocodeugc)
join NoaaZonesInbound zone
    on `ActiveAlertsByUgcCode`.geocodeugc = zone.id
group by active.`window_start`, active.`window_end`, rollup(zone.`state`);

-- Question to answer:
-- Can I get a count of the active alerts by state with an effectiveTs < x hours old?

-- this is getting an error in the flink workspace
select distinct(alertId, zoneState), count(*) from WsActiveAlertsByZone
where TIMESTAMPDIFF(HOUR, CAST(CURRENT_TIMESTAMP AS TIMESTAMP_LTZ(3)), effectiveTs) < 2
group by alertId, zoneState;

--There exists non deterministic function: 'CURRENT_TIMESTAMP' in condition: '<(CAST(/INT(Reinterpret(-($3, CURRENT_TIMESTAMP)), 3600000)):INTEGER, 2)'
--which may cause wrong result in update pipeline. related rel plan: Calc(select=[alertId, zoneState],
--where=[<(CAST(/INT(Reinterpret(-(effectiveTs, CURRENT_TIMESTAMP())), 3600000) AS INTEGER), 2)],
-- changelogMode=[I,UB,UA,D]) +- ChangelogNormalize(key=[alertId, zoneId], changelogMode=[I,UB,UA,D], upsertKeys=[[alertId, zoneId]]) +- Exchange(distribution=[hash[alertId, zoneId]],
-- changelogMode=[UA,D], upsertKeys=[[alertId, zoneId]]) +- Calc(select=[alertId, zoneId, zoneState, effectiveTs], changelogMode=[UA,D], upsertKeys=[[alertId, zoneId]]) +- TableSourceScan(table=[[weather-streams, weather-cluster-1, WsActiveAlertsByZone, metadata=[$rowtime], watermark=[SOURCE_WATERMARK()]]], fields=[alertId, zoneId, zoneUrl, event, alertStatus, alertMessageType, zoneName, zoneState, category, severity, urgency, headline, description, instruction, response, zoneGeometry, sentTs, sender, onsetTs, effectiveTs, expiryTs, endTs, nwsHeadline, $rowtime], changelogMode=[UA,D], upsertKeys=[[alertId, zoneId]])

-- example:
SELECT L.num as L_Num, L.id as L_Id, R.num as R_Num, R.id as R_Id,
  COALESCE(L.window_start, R.window_start) as window_start,
  COALESCE(L.window_end, R.window_end) as window_end
  FROM (
    SELECT * FROM TABLE(TUMBLE(TABLE LeftTable, DESCRIPTOR($rowtime), INTERVAL '5' MINUTES))
  ) L
  FULL JOIN (
    SELECT * FROM TABLE(TUMBLE(TABLE RightTable, DESCRIPTOR($rowtime), INTERVAL '5' MINUTES))
  ) R
  ON L.num = R.num AND L.window_start = R.window_start AND L.window_end = R.window_end;
