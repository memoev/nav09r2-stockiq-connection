SET NOCOUNT ON;

-- Since the starting quantity can vary from 0-1, create a list of vendor-item pairs to identify the lowest level pricebreak.
-- The first range = base cost and can be excluded from the matrix.
WITH 
STARTLIST AS
(
    SELECT itemPrice.[Vendor No_] VENDORID, RTRIM(itemPrice.[Item No_]) ITEMNMBR, MIN(itemPrice.[Minimum Quantity]) FIRSTRANGE
  FROM 
  (SELECT purchasePrice.* FROM [WXYZ$Purchase Price] purchasePrice
	INNER JOIN (SELECT [Item No_], [Vendor No_], [Unit of Measure Code], [Minimum Quantity], MAX([Starting Date]) as startdate
	FROM [WXYZ$Purchase Price] 
	GROUP BY [Item No_],[Vendor No_], [Unit of Measure Code], [Minimum Quantity]
	) oldestDate
	ON purchasePrice.[Item No_]=oldestDate.[Item No_]
	AND purchasePrice.[Vendor No_]=oldestDate.[Vendor No_]
	AND purchasePrice.[Starting Date]=oldestDate.startdate
	AND purchasePrice.[Unit of Measure Code]=oldestDate.[Unit of Measure Code]
	AND purchasePrice.[Minimum Quantity] = oldestDate.[Minimum Quantity]
	) itemPrice
  GROUP BY itemPrice.[Vendor No_], RTRIM(itemPrice.[Item No_])
)

SELECT
	'000' ShipperCode,
	itemPrice.[Item No_] ItemCode,
	itemPrice.[Vendor No_] SupplierCode,
	1 Type,                          -- VolumeDiscount
	1 DiscountMeasure,               -- Units
	2 DiscountType,                  -- Cost
	itemPrice.[Minimum Quantity] Quantity,   -- "quantity at which this level of discount is reached."
	itemPrice.[Direct Unit Cost] Amount,
	NULL MaxNumberOfBuys,
	0 NumberOfTimesUsed,
	NULL MaxBuyQuantity,
	0 QuantityBoughtOnPricebreak,
	NULL SupplierQuoteNumber,
	NULL DateEffective,
	CASE
			WHEN itemPrice.[Ending Date] NOT LIKE '1753-01-01%' THEN
				itemPrice.[Ending Date]
			ELSE
				' '
		END DateExpires,
	NULL Note,
	NULL DateUpdated 
FROM 
	(SELECT purchasePrice.* FROM [WXYZ$Purchase Price] purchasePrice
	INNER JOIN (SELECT [Item No_], [Vendor No_], [Unit of Measure Code], [Minimum Quantity], MAX([Starting Date])as startdate
	FROM [WXYZ$Purchase Price] 
	GROUP BY [Item No_],[Vendor No_], [Unit of Measure Code], [Minimum Quantity]
	) oldestDate
ON purchasePrice.[Item No_]=oldestDate.[Item No_]
AND purchasePrice.[Vendor No_]=oldestDate.[Vendor No_]
AND purchasePrice.[Starting Date]=oldestDate.startdate
AND purchasePrice.[Unit of Measure Code]=oldestDate.[Unit of Measure Code]
AND purchasePrice.[Minimum Quantity] = oldestDate.[Minimum Quantity]) itemPrice

WHERE NOT EXISTS
	(SELECT skip1.VENDORID, skip1.ITEMNMBR, skip1.FIRSTRANGE
	 FROM STARTLIST skip1
	 WHERE skip1.VENDORID=RTRIM(itemPrice.[Vendor No_])
		AND skip1.ITEMNMBR=RTRIM(itemPrice.[Item No_])
		AND skip1.FIRSTRANGE=itemPrice.[Minimum Quantity]
	);
		
		