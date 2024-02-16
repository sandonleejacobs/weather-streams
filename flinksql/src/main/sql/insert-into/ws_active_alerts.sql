insert into ws_active_alerts select
   properties.id, properties.areaDesc,
   properties.geocode.SAME as `geocodeSAME`, properties.geocode.UGC as `geocodeUGC`,
   properties.affectedZones,
   properties.sent, properties.effective, properties.onset, properties.expires,
   properties.ends, properties.status, properties.messageType, properties.category, properties.severity,
   properties.certainty, properties.urgency, properties.event, properties.sender, properties.senderName,
   properties.headline, properties.description, properties.instruction, properties.response, properties.NWSheadline,
   properties.eventEndingTime, properties.expiredReferences
from NoaaAlertsActiveInbound;