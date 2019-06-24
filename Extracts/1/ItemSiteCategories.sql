SET NOCOUNT ON
SELECT DISTINCT
	UPPER(item.No_) ItemCode,
	UPPER(site.[Location Code]) SiteCode,
	'000' ShipperCode,
	RTRIM(item.[Item Category Code]) ItemSiteCategory1Code,
	RTRIM(item.[Product Group Code]) ItemSiteCategory2Code,
	RTRIM(item.[Product Type Code]) ItemSiteCategory3Code,
	RTRIM(item.[Style]) ItemSiteCategory4Code,
	NULL ItemSiteCategory5Code,
	NULL DateUpdated
FROM [Liberty Mountain$Item] AS item WITH (NOLOCK) 
INNER JOIN [Liberty Mountain$Stockkeeping Unit] AS site WITH (NOLOCK)
	ON item.No_ = site.[Item No_]
INNER JOIN [Liberty Mountain$Item Unit of Measure] AS itemUOM WITH (NOLOCK)   
	ON item.No_ = itemUOM.[Item No_]
WHERE UPPER(site.[Location Code]) IN ('UT','PA')
AND item.Blocked <> 1

ORDER BY
ItemSiteCategory1Code,
ItemSiteCategory2Code;
	