SET NOCOUNT ON
-- Uncomment these lines to debug:
--DECLARE @IntegrationConfigurationId int = 1
---------------------------------------
-- Do not change below this line.

SELECT DISTINCT
	UPPER(itemQuantity.[No_]) ItemCode,
	'000' ShipperCode,
	@IntegrationConfigurationId IntegrationConfigurationId,
	NULL Upc,
	CASE 
			WHEN (itemQuantity.[Out For Season] = 1) THEN CONCAT(REPLACE(itemQuantity.Description,'"','""'), ' [OFS ', CONVERT(VARCHAR(10), itemQuantity.[Availability Date], 1), ' ]')
			WHEN (itemQuantity.[CloseOut] = 1) THEN CONCAT(REPLACE(itemQuantity.Description,'"','""'), ' [CLOSEOUT]')
			ELSE REPLACE(REPLACE(itemQuantity.Description, '"','""'),CHAR(10),'')
		END ItemDescription,
	itemQuantity.[Base Unit of Measure] UnitOfMeasure,
	CAST(itemQuantity.[Net Weight] AS DECIMAL(19,5)) UnitWeight, 
	NULL WeightUnits,
	NULL UnitLength,
	NULL UnitWidth,
	NULL UnitHeight,
	NULL SizeUnits,
	NULL UnitsPerPallet,--
	NULL EquivalencyUnits,
	NULL ImageUri,
	NULL ErpNotes,
	NULL DateUpdated
FROM  dbo.[Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
INNER JOIN dbo.[Liberty Mountain$Stockkeeping Unit] SKU WITH (NOLOCK)
	ON SKU.[Item No_] = itemQuantity.[No_]
INNER JOIN prod.dbo.[Liberty Mountain$Vendor] AS supplier ON SKU.[Vendor No_] = supplier.No_
	
WHERE itemQuantity.Blocked = 0
AND SKU.[Location Code] IN ('PA', 'UT')
AND (SKU.[Item No_] >= '000000' AND SKU.[Item No_] <= '999999')
AND supplier.[Purchaser Code] like 'LM%'

ORDER BY UPPER(itemQuantity.[No_]);