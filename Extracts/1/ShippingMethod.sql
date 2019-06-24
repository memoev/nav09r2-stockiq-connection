SET NOCOUNT ON;

--Taken from original NAV customer's RockySoft
SELECT DISTINCT
	RTRIM(shipMethod.[Code]) As ShippingMethodCode,
	RTRIM(shipMethod.[Description]) AS Name,
	NULL AS ShippingCarrierCode,   --?????????????????????????????
	CASE   --????????????????
		WHEN UPPER(RTRIM(shipMethod.[Code])) = 'DELIVERY' THEN 1 -- SIQ 1 = Delivery
		WHEN UPPER(RTRIM(shipMethod.[Code])) = 'PICK-UP' THEN 2 --SIQ 2 = Pickup
		ELSE NULL 
	END AS [ShipType],		
	NULL AS DateUpdated
FROM [Liberty Mountain$Shipment Method] shipMethod
WHERE RTRIM(shipMethod.[Code]) <> ''
UNION
SELECT 
'TBD' As ShippingMethodCode, 
'TBD' Name,
 NULL ShippingCarrierCode,
 NULL [ShipType],
 NULL;