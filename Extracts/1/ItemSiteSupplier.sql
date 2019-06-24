SET NOCOUNT ON;

WITH vendorLT
AS
(
	SELECT vendor.[Purchaser Code] purchCode,
	vendor.No_ vendorCode,
	vendor.[Lead Time Calculation] ltCalc
	FROM dbo.[Liberty Mountain$Vendor] AS vendor
)

SELECT DISTINCT
	UPPER(itemQuantity.No_) ItemCode,
	UPPER(site.[Location Code]) SiteCode,
	CASE
		WHEN site.[Vendor No_] = ' ' and site.[Transfer-from Code] = ' ' THEN
			'Unknown'
		ELSE
		 site.[Vendor No_]
	END SupplierCode,
	'000' ShipperCode,
	NULL SupplierItemCategoryCode,
	CASE
		WHEN RTRIM(itemQuantity.[Vendor No_]) = RTRIM(site.[Vendor No_]) THEN 1
		ELSE
			NULL
	END ErpSupplierLevel,  
	REPLACE(CAST(site.[Vendor Item No_] as varchar),'"','""') SupplierItemCode,
	CASE 
		WHEN itemQuantity.[Purch_ Unit of Measure] = 'EACH' THEN 
			IIF(itemQuantity.[Minimum Order Quantity]=0, 1, itemQuantity.[Minimum Order Quantity])
		ELSE 
			IIF(
				itemQuantity.[Minimum Order Quantity] / itemUOM.[Qty_ per Unit of Measure] < 1, 1,
				itemQuantity.[Minimum Order Quantity] / itemUOM.[Qty_ per Unit of Measure]
				)
	END MinimumOrderQuantity,
	CASE
			WHEN itemQuantity.[Purch_ Unit of Measure] = 'EACH' THEN 
				IIF(site.[Order Multiple]<1, 1, site.[Order Multiple])
			ELSE 
				IIF(
					site.[Order Multiple]/itemUOM.[Qty_ per Unit of Measure] < 1, 1,
					site.[Order Multiple]/itemUOM.[Qty_ per Unit of Measure]
				)
	END OrderMultipleQuantity,
	NULL OrderMultipleReceivingCost,
	NULL OrderMultipleReceivingCostCurrency,
	NULL MaxOrderQuantity,
	1 YieldPercentage,   
	price.[Direct Unit Cost] SupplierCost,
	'USD' SupplierCostCurrency,  
	CASE
		WHEN itemUOM.Code <> price.[Unit of Measure Code] THEN
			price.[Unit of Measure Code]
		ELSE
			itemUOM.Code 
	END PurchaseUnitOfMeasure,
	0 ErpAdminLeadTime,
	--NOTE:  The following was based on the original NAV customer's RS logic
	CASE	
		WHEN RIGHT(vendor.[Lead Time Calculation], 1) = CHAR(2) Then LEFT(vendor.[Lead Time Calculation], LEN(vendor.[Lead Time Calculation])-1) 
		WHEN RIGHT(vendor.[Lead Time Calculation], 1) = CHAR(4) then LEFT(vendor.[Lead Time Calculation], LEN(vendor.[Lead Time Calculation])-1)*7
		WHEN RIGHT(vendor.[Lead Time Calculation], 1) = CHAR(5) then LEFT(vendor.[Lead Time Calculation], LEN(vendor.[Lead Time Calculation])-1)*30 ELSE '' 
	END ErpManufacturingLeadTime,
	0 ErpShippingLeadTime,
	0 ErpPutawayLeadTime,
	NULL SupplierOnHand,
	NULL DateUpdated
FROM [Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
INNER JOIN [Liberty Mountain$Stockkeeping Unit] AS site WITH (NOLOCK)
	ON itemQuantity.No_ = site.[Item No_]
INNER JOIN dbo.[Liberty Mountain$Vendor] AS vendor
	ON site.[Vendor No_] = vendor.No_

INNER JOIN [Liberty Mountain$Item Unit of Measure] AS itemUOM WITH (NOLOCK)   
	ON itemQuantity.No_ = itemUOM.[Item No_]
LEFT JOIN 
(SELECT purchasePrice.* FROM [Liberty Mountain$Purchase Price] purchasePrice
INNER JOIN 
	(SELECT [Item No_], [Vendor No_], [Unit of Measure Code], MAX([Starting Date])as startdate
	FROM [Liberty Mountain$Purchase Price] group by [Item No_],[Vendor No_], [Unit of Measure Code]
	) oldestDate
	ON purchasePrice.[Item No_]=oldestDate.[Item No_]
	AND purchasePrice.[Vendor No_]=oldestDate.[Vendor No_]
	AND purchasePrice.[Starting Date]=oldestDate.startdate
	AND purchasePrice.[Unit of Measure Code]=oldestDate.[Unit of Measure Code]
	) price
	ON itemQuantity.No_ = price.[Item No_]
	AND itemQuantity.[Vendor No_] = price.[Vendor No_]

WHERE itemQuantity.Blocked <> 1
AND RTRIM(site.[Vendor No_])  <> ''
AND site.[Vendor No_] IS NOT NULL
AND site.[Location Code] IN ('UT','PA')
AND vendor.[Purchaser Code] like 'LM%'
AND (UPPER(itemQuantity.No_) >= '000000' AND UPPER(itemQuantity.No_) <= '999999')
;