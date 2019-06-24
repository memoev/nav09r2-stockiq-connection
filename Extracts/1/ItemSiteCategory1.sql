SET NOCOUNT ON;

SELECT DISTINCT 
	RTRIM(item.[Item Category Code]) ItemSiteCategory1Code, 
	RTRIM(item.[Item Category Code]) [Value], 
	NULL DateUpdated
FROM [Liberty Mountain$Item] item
WHERE RTRIM(item.[Item Category Code]) <> ''
AND item.Blocked <> 1
ORDER BY RTRIM(item.[Item Category Code]);