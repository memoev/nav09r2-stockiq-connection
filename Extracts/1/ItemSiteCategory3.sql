SET NOCOUNT ON;

SELECT DISTINCT 
	RTRIM(item.[Product Type Code]) ItemSiteCategory3Code, 
	RTRIM(item.[Product Type Code]) [Value], 
	NULL DateUpdated
FROM [Liberty Mountain$Item] item
WHERE RTRIM(item.[Product Type Code]) <> ''
AND item.Blocked <> 1
ORDER BY RTRIM(item.[Product Type Code]);


