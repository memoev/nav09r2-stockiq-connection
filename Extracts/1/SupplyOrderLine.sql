SET NOCOUNT ON;
-- Uncomment these lines to debug:
--DECLARE @OldestDate date = dateadd(month, datediff(month,0,dateadd(yy,-3,getdate())), 0);
-------------------------------------
-- Do not change below this line.

WITH lastVersion AS
(
	SELECT poLine.[Document No_] ErpOrderNumber,
	CASE
		WHEN poLine.[Line No_] >= 10000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			poLine.[Line No_]
	END ErpLineNumber,
	MIN(poLine.[Version No_]) VersionNumber
	FROM [Liberty Mountain$Purchase Line Archive] as poLine
	WHERE UPPER(poLine.[Location Code]) IN ('UT','PA')
	AND ISNUMERIC(poLine.[No_]) = 1
	AND poLine.[No_] BETWEEN 0 AND 999999
	GROUP BY poLine.[Document No_], 
	CASE
		WHEN poLine.[Line No_] >= 10000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			poLine.[Line No_]
	END
)

--Working POs
SELECT 
	poLine.[Document No_] ErpOrderNumber,
	CASE
		WHEN poLine.[Line No_]%10000 = 5000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN poLine.[Line No_] >= 10000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			poLine.[Line No_]
	END ErpLineNumber,
	CASE
		WHEN poHeader.[External Document No_] LIKE '%SIQ%' THEN
			poHeader.[External Document No_]
	END StockIqOrderNumber,
	NULL StockIqLineNumber,
	UPPER(poLine.No_) ItemCode,
	UPPER(poLine.[Location Code]) SiteCode,
	CASE               
		WHEN poLine.[Quantity Received] < poLine.Quantity THEN 1 -- Still Open
		ELSE
			2 --Closed
	END ErpLineStatus,
	CASE
		when itemUOM.[Qty_ per Unit of Measure] > 0 THEN
		 poLine.[Outstanding Quantity] * itemUOM.[Qty_ per Unit of Measure]
		ELSE
		 poLine.[Outstanding Quantity]
	END ReleaseQuantity,
	CASE
		when itemUOM.[Qty_ per Unit of Measure] > 0 THEN
		 poLine.[Outstanding Quantity] * itemUOM.[Qty_ per Unit of Measure]
		ELSE
		 poLine.[Outstanding Quantity]
	END RemainingReleaseQuantity,
	CAST(poLine.[Unit Cost (LCY)] AS DECIMAL(19,5)) PurchaseCost,  
	'USD' PurchaseCostCurrency,
	CASE
		WHEN poLine.[Promised Receipt Date] = '1753-01-01' THEN poLine.[Expected Receipt Date]
		ELSE
			poLine.[Promised Receipt Date]
	END ExpectedShipDate,
	CASE
		WHEN poLine.[Promised Receipt Date] = '1753-01-01' THEN poLine.[Expected Receipt Date]
		ELSE
			poLine.[Promised Receipt Date]
	END ExpectedDockDate,
	NULL InternalLineComment,
	NULL ExternalLineComment,
	NULL DateUpdated
FROM [Liberty Mountain$Purchase Line] as poLine WITH (NOLOCK)      
INNER JOIN  [Liberty Mountain$Purchase Header] as poHeader
	ON poLine.[Document Type] = poHeader.[Document Type]
	AND poLine.[Document No_] = poHeader.No_		
LEFT JOIN [Liberty Mountain$Prod_ Order Line] AS workOrder
	ON poLine.[Document No_] = workOrder.[Prod_ Order No_]
	AND poLine.[Line No_] = workOrder.[Line No_]
INNER JOIN [Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON UPPER(itemQuantity.No_) = UPPER(poLine.No_)
LEFT JOIN [Liberty Mountain$Item Unit of Measure] as itemUOM
	ON itemQuantity.No_ = itemUOM.[Item No_]
	AND itemQuantity.[Purch_ Unit of Measure] = itemUOM.Code
WHERE poLine.[Order Date] >= @OldestDate
AND poHeader.[PO Status] < 5
AND UPPER(poHeader.[Location Code]) IN ('UT','PA')
AND UPPER(poLine.[Location Code]) IN ('UT','PA')
AND ISNUMERIC(poLine.[No_]) = 1
AND poLine.[No_] BETWEEN 0 AND 999999
AND itemQuantity.Blocked = 0

AND NOT EXISTS
	(SELECT poLineHist.[Document No_] ErpOrderNumber,
	CASE
		WHEN poLineHist.[Line No_]%10000 = 5000 THEN
			CAST(poLineHist.[Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN poLineHist.[Line No_] >= 10000 THEN
			CAST(poLineHist.[Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			poLineHist.[Line No_]
	END ErpLineNumber
	FROM [Liberty Mountain$Purchase Line Archive] as poLineHist WITH (NOLOCK)      
	INNER JOIN  [Liberty Mountain$Purchase Header Archive] as poHeaderHist
	ON poLineHist.[Document Type] = poHeaderHist.[Document Type]
	AND poLineHist.[Document No_] = poHeaderHist.No_	
	WHERE poLineHist.[Document No_] = poLine.[Document No_]
	AND poLineHIst.[Line No_] = poLine.[Line No_]
	AND 
		(poLine.[Outstanding Quantity] = 0
		OR
		poLine.[Outstanding Quantity] = poLineHist.[Outstanding Quantity])
	)

UNION

--History PO
SELECT 
	poLine.[Document No_] ErpOrderNumber,
	CASE
		WHEN poLine.[Line No_]%10000 = 5000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN poLine.[Line No_] >= 10000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			poLine.[Line No_]
	END ErpLineNumber,
	NULL StockIqOrderNumber,
	NULL StockIqLineNumber,
	UPPER(poLine.No_) ItemCode,
	UPPER(poLine.[Location Code]) SiteCode,
	2 ErpLineStatus,  --5/29/19: CB Consider all archived orders as closed per Guillermo Villalta
	CASE
		when itemUOM.[Qty_ per Unit of Measure] > 0 THEN
		 poLine.[Outstanding Quantity] * itemUOM.[Qty_ per Unit of Measure]
		ELSE
		 poLine.[Outstanding Quantity]
	END ReleaseQuantity,
	CASE
		when itemUOM.[Qty_ per Unit of Measure] > 0 THEN
		 poLine.[Outstanding Quantity] * itemUOM.[Qty_ per Unit of Measure]
		ELSE
		 poLine.[Outstanding Quantity]
	END RemainingReleaseQuantity,
	CAST(poLine.[Unit Cost (LCY)] AS DECIMAL(19,5)) PurchaseCost,  
	'USD' PurchaseCostCurrency,
	CASE
		WHEN poLine.[Promised Receipt Date] = '1753-01-01' THEN poLine.[Expected Receipt Date]
		ELSE
			poLine.[Promised Receipt Date]
	END ExpectedShipDate,
	CASE
		WHEN poLine.[Promised Receipt Date] = '1753-01-01' THEN poLine.[Expected Receipt Date]
		ELSE
			poLine.[Promised Receipt Date]
	END ExpectedDockDate,
	NULL InternalLineComment,
	NULL ExternalLineComment,
	NULL DateUpdated
FROM [Liberty Mountain$Purchase Line Archive] as poLine WITH (NOLOCK)      
INNER JOIN  [Liberty Mountain$Purchase Header Archive] as poHeader
	ON poLine.[Document Type] = poHeader.[Document Type]
	AND poLine.[Document No_] = poHeader.No_		
LEFT JOIN [Liberty Mountain$Prod_ Order Line] AS workOrder
	ON poLine.[Document No_] = workOrder.[Prod_ Order No_]
	AND poLine.[Line No_] = workOrder.[Line No_]
INNER JOIN [Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON UPPER(itemQuantity.No_) = UPPER(poLine.No_)
LEFT JOIN [Liberty Mountain$Item Unit of Measure] as itemUOM
	ON itemQuantity.No_ = itemUOM.[Item No_]
	AND itemQuantity.[Purch_ Unit of Measure] = itemUOM.Code
INNER JOIN lastVersion
	ON lastVersion.ErpOrderNumber = poLine.[Document No_]
	AND lastVersion.ErpLineNumber = CASE
		WHEN poLine.[Line No_] >= 10000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			poLine.[Line No_]
	END
	AND lastVersion.VersionNumber = poLine.[Version No_]
WHERE poLine.[Order Date] >= @OldestDate
AND UPPER(poHeader.[Location Code]) IN ('UT','PA')
AND UPPER(poLine.[Location Code]) IN ('UT','PA')
AND ISNUMERIC(poLine.[No_]) = 1
AND poLine.[No_] BETWEEN 0 AND 999999
AND itemQuantity.Blocked = 0

UNION --transfers

SELECT 
	poLine.[Document No_] ErpOrderNumber,
	CASE
		WHEN poLine.[Line No_]%10000 = 5000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN poLine.[Line No_]>= 10000 THEN
			CAST(poLine.[Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			poLine.[Line No_]
	END ErpLineNumber,
	CASE
		WHEN poHeader.[External Document No_] LIKE '%SIQ%' then poHeader.[External Document No_] 
	ELSE
		NULL
	END StockIqOrderNumber,
	NULL StockIqLineNumber,
	UPPER(poLine.[Item No_]) ItemCode,
	UPPER(poLine.[Transfer-to Code]) SiteCode,
	1 ErpLineStatus,  --OR pol.Status (0/1) ?
	poLine.Quantity ReleaseQuantity,
	poLine.Quantity RemainingReleaseQuantity,
	0 PurchaseCost,  
	'USD' PurchaseCostCurrency,
	poHeader.[Posting Date] ExpectedShipDate,
	poHeader.[Receipt Date] ExpectedDockDate,
	NULL InternalLineComment,
	NULL ExternalLineComment,
	NULL DateUpdated
FROM	[Liberty Mountain$Transfer Line] AS poLine WITH (NOLOCK)   
	INNER JOIN  [Liberty Mountain$Transfer Header] as poHeader
		on poLine.[Document No_] = poHeader.No_
WHERE poLine.[Outstanding Quantity] > 0 			
AND poLine.[Outstanding Quantity] > 0
AND poHeader.[Receipt Date] >= @OldestDate
AND UPPER(poLine.[Transfer-to Code]) IN ('UT','PA')
AND (poLine.[Item No_] >= '000000') AND (poLine.[Item No_] <= '999999')
;