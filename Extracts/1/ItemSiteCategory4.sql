SET NOCOUNT ON;

SELECT DISTINCT 
	RTRIM(item.[Style]) ItemSiteCategory4Code, 
	RTRIM(item.[Style]) [Value], 
	NULL DateUpdated
FROM [Liberty Mountain$Item] item
WHERE RTRIM(item.[Style]) <> ''
AND item.Blocked <> 1

ORDER BY RTRIM(item.[Style]);


