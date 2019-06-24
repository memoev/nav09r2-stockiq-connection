SET NOCOUNT ON;

--Taken from original NAV customer's RockySoft
WITH onHand AS
(
SELECT [Item No_],
	[Location Code],
	SUM([Quantity]) onHandQty	
FROM dbo.[Liberty Mountain$Item Ledger Entry]
WHERE Quantity <> 0
GROUP BY [Item No_],[Location Code]
),
AllFirstDates
AS
(
	SELECT DISTINCT UPPER(poLine.No_) ItemCode, 
	UPPER(poLine.[Location Code]) SiteCode, 
	poLine.[Planned Receipt Date] FirstReceiptDate
	FROM [Liberty Mountain$Purchase Line] as poLine  WITH (NOLOCK) 
	INNER JOIN [Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON UPPER(itemQuantity.No_) = UPPER(poLine.No_)
	WHERE UPPER(poLine.[Location Code]) IN ('PA', 'UT')
	AND poLine.[Prod_ Order No_] = ''  --JB Suggestion
	AND poLine.Type = 2  --Item
	AND RTRIM(poLine.No_) <> ''
	AND poLine.[Planned Receipt Date] > '01/01/1900'
	AND itemQuantity.Blocked <> 1

	UNION ALL

	SELECT UPPER(itemLedger.[Item No_]) ItemCode, 
	UPPER(itemLedger.[Location Code]) SiteCode, 
	MIN(itemLedger.[Document Date]) FirstReceiptDate
	FROM [Liberty Mountain$Item Ledger Entry] as itemLedger  WITH (NOLOCK) 
	INNER JOIN [Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON UPPER(itemQuantity.No_) = UPPER(itemLedger.[Item No_])
	WHERE UPPER(itemLedger.[Location Code]) IN ('PA', 'UT')
	AND itemLedger.[Document Date] > '01/01/1900'
	AND itemQuantity.Blocked <> 1
	AND [Entry Type] IN (0,1,5) --Purchase, Sale, Transfer
	GROUP BY UPPER(itemLedger.[Item No_]), UPPER(itemLedger.[Location Code])
),
FirstDate
AS
(
	SELECT ItemCode, SiteCode, min(FirstReceiptDate) FirstReceiptDate
	FROM AllFirstDates
	GROUP BY ItemCode, SiteCode
)

SELECT DISTINCT
	UPPER(item.No_) ItemCode,
	CASE
		WHEN onHand.[Location Code] IS NOT NULL THEN onHand.[Location Code]
		ELSE site.[Location Code]
	END SiteCode,
	'000' ShipperCode,
	CASE 
		WHEN RTRIM([Transfer-from Code]) = '' THEN NULL
		ELSE
			RTRIM([Transfer-from Code])
	END HubWarehouse, -- case here if need to set up hub
	0 IsPhantom,
	NULL PlantCode,
	CASE 
		WHEN supplier.[Purchaser Code] = ' ' THEN
			'UNKNOWN'
		ELSE
			supplier.[Purchaser Code]
	END BuyerCode,
	NULL OwnedByCustomerCode,
	NULL CustomerItemCode,
	--CAST(
	--	CASE 
	--		WHEN site.[Unit Cost] IS NOT NULL THEN site.[Unit Cost]
	--		ELSE	
	--			item.[Unit Cost]
	--	END
	--AS DECIMAL(19,5)) CurrentCost,
	item.[Last Direct Cost] CurrentCost,
	'USD' CurrentCostCurrency,
	--CAST(
	--	CASE 
	--		WHEN site.[Unit Cost] IS NOT NULL THEN site.[Unit Cost]
	--		ELSE
	--			item.[Unit Cost]
	--	END
	--AS DECIMAL(19,5)) StandardCost,
	item.[Unit Cost] StandardCost,
	'USD' StandardCostCurrency,
	--CAST(item.[Unit Price] AS DECIMAL(19,5)) StandardPrice,   
	item.[Unit Price]  StandardPrice,  
	'USD' StandardPriceCurrency,
	CAST(ISNULL(onHand.onHandQty,0) AS DECIMAL(19,5)) OnHandQuantity,   
	CASE 
			WHEN item.[Out For Season] = 1 THEN  64 --'DoNotOrder'
			WHEN item.[CloseOut] = 1 THEN 64 --'DoNotOrder'
			WHEN item.[Replenishment System] = 1 THEN
				CASE
					WHEN item.[Manufacturing Policy] = 0 THEN 2 --'OrderPoint'
					ELSE 16 --'BuildToORder'
				END
			WHEN item.[Special Order] = 1 THEN 8 --'BuyToOrder'
			ELSE 2 --OrderPoint NOTE:  PE was ''
		END ErpOrderPolicy,
	NULL ErpSafetyStock,
	NULL ErpSafetyStockMeasure,
	NULL DateCreated,
	FOL.FirstReceiptDate DateFirstStocked, 
	NULL DateObsolete,
	NULL ShelfLifeDays,
	NULL ErpNotes,
	NULL ErpOrderCycleDays,
	NULL FixedOrderQuantity,
	NULL MinMaxTargetQuantity,
	0 OutOfStockQuantity,
	NULL TargetStockMultiple,
	NULL DateUpdated
FROM [Liberty Mountain$Item] AS item WITH (NOLOCK) 
INNER JOIN [Liberty Mountain$Item Unit of Measure] AS itemUOM WITH (NOLOCK)   
	ON item.No_ = itemUOM.[Item No_]
LEFT JOIN [Liberty Mountain$Stockkeeping Unit] AS site WITH (NOLOCK)
	ON item.No_ = site.[Item No_]
LEFT JOIN onHand
	ON onHand.[Item No_] = item.No_
	AND onHand.[Location Code] = site.[Location Code]
LEFT JOIN FirstDate FOL
	ON FOL.ItemCode=site.[Item No_]
	AND FOL.SiteCode=site.[Location Code]
INNER JOIN dbo.[Liberty Mountain$Vendor] AS supplier
	ON site.[Vendor No_] = supplier.No_
WHERE 
--AND site.[Reordering Policy] IS NOT NULL 
item.Blocked = 0
AND site.[Location Code] IN ('PA', 'UT')
AND (site.[Item No_] >= '000000') AND (site.[Item No_] <= '999999')

ORDER BY 
	UPPER(item.No_),
	SiteCode;
