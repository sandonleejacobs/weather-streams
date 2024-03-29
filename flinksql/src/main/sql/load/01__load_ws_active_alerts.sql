insert into ws_active_alerts
select
   properties.id as `id`, properties.areaDesc as `areaDesc`,
   properties.geocode.SAME as `geocodeSAME`, properties.geocode.UGC as `geocodeUGC`,
   properties.affectedZones as `affectedZones`,
   properties.sent as `sent`, properties.effective as `effective`, properties.onset as `onset`,
   properties.expires as `expires`, properties.ends as `ends`,
   properties.status as `status`, properties.messageType as `messageType`,
   properties.category as `category`, properties.severity as `severity`,
   properties.certainty as `certainty`, properties.urgency as `urgency`,
   properties.event as `event`, properties.sender as `sender`, properties.senderName as `senderName`,
   properties.headline as `headline`, properties.description as `description`,
   properties.instruction as `instruction`, properties.response as `response`,
   properties.NWSheadline as `NWSheadline`,
   properties.eventEndingTime as `eventEndingTime`, properties.expiredReferences as `expiredReferences`,
   $rowtime as `eventTs`
from NoaaAlertsActiveInbound where properties.messageType <> 'cancel';