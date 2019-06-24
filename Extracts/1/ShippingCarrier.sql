SET NOCOUNT ON;

--Taken from original NAV customer's RockySoft

SELECT 'TBD' AS ShippingCarrierCode,
	'TBD' AS [Name],
	NULL As DateUpdated
UNION
SELECT DISTINCT
	RTRIM(Code) AS ShippingCarrierCode,
	RTRIM([Name]) AS [Name],
	NULL As DateUpdated
FROM [Liberty Mountain$Shipping Agent]
WHERE RTRIM(Code) <> ''
--UNION
--SELECT DISTINCT
--	RTRIM([Shipping Agent Code]) AS ShippingCarrierCode,
--	RTRIM([Description]) 
--	AS [Name],
--	NULL As DateUpdated
--FROM [Liberty Mountain$E-Ship Agent Service]
--WHERE RTRIM([Shipping Agent Code]) NOT IN
--	(SELECT RTRIM(Code) FROM [Liberty Mountain$Shipping Agent])
;

