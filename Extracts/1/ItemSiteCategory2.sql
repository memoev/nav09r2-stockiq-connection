SET NOCOUNT ON;

SELECT DISTINCT 
	RTRIM(item.[Product Group Code]) ItemSiteCategory2Code, 
	RTRIM(item.[Product Group Code]) [Value], 
	NULL DateUpdated
FROM [Liberty Mountain$Item] item
WHERE RTRIM(item.[Product Group Code]) <> ''
AND item.Blocked <> 1
ORDER BY RTRIM(item.[Product Group Code]);