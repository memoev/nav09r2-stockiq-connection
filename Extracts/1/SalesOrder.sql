SET NOCOUNT ON;
-- Uncomment these lines to debug:
--DECLARE @OldestDate date = dateadd(month, datediff(month,0,dateadd(yy,-3,getdate())), 0);
-------------------------------------
-- Do not change below this line.

--open sales orders
SELECT
	'000' DemandSeriesCode,
	salesOrderLine.[Document No_] OrderNumber, 
	CASE
		WHEN salesOrderLine.[Line No_]>= 10000 THEN
			salesOrderLine.[Line No_]*1.00/10000
		ELSE
			salesOrderLine.[Line No_]
	END LineNumber,
	'000' ShipperCode,
	salesOrderLine.No_ ItemCode,
	salesOrderLine.[Location Code] SiteCode,
	RTRIM(customer.No_) CustomerShipToCode, 
	1 DemandType, --only get sales orders on purpose
	CASE
		WHEN salesOrder.Status = 1 THEN 1 --0=Open, 1=Released, 3=Pending Approval, 4=Pending Prepayment
		ELSE
			2
	END LineStatus,
	salesOrderLine.[Shipment Date] DemandDate,    -- OR [Requested Delivery Date] ??
	salesOrderLine.[Shipment Date] RequestedShipDate,    -- OR [Planned Shipment Date] ??
	NULL RequiredDate,
	CAST(salesOrderLine.[Outstanding Quantity] as decimal(19, 5)) Quantity,
	CAST(salesOrderLine.[Unit Price] as decimal(19, 5)) InvoicePrice,
	NULL AS InvoicePriceCurrency,
	0 IsExceptional,
	0 IsOnPromotion,
	NULL Note,
	NULL DateUpdated,
	CAST(salesOrderLine.[Unit Cost] AS DECIMAL(19,5)) AS InvoiceCost,
	NULL AS InvoiceCostCurrency,
	CONVERT(varchar(10),salesOrderLine.[Shipment Date], 101) AS DateOrdered,
	NULL As QuantityShipped,
	0 AS IsDropShip
FROM [Liberty Mountain$Sales Line] AS salesOrderLine WITH (NOLOCK)             
INNER JOIN [Liberty Mountain$Sales Header] AS salesOrder WITH (NOLOCK)        
	ON salesOrderLine.[Document No_] = salesOrder.No_
LEFT JOIN [Liberty Mountain$Customer] customer WITH (NOLOCK)
	ON RTRIM(customer.[No_]) = RTRIM(salesOrder.[Sell-to Customer No_])
WHERE salesOrderLine.[Shipment Date] >= @OldestDate 
AND salesOrderLine.[Outstanding Quantity] <> 0	
AND salesOrder.[Document Type] = 1 
AND salesOrderLine.Type = 2  --Item
AND RTRIM(salesOrderLine.No_) <> ''
AND salesOrderLine.[Location Code] IN ('UT','PA')

UNION

--historical sales orders (Invoice types)
SELECT
	'000' DemandSeriesCode,
	salesOrderLine.[Document No_] OrderNumber,        
	CASE
		WHEN salesOrderLine.[Line No_]>= 10000 THEN
			salesOrderLine.[Line No_]*1.00/10000 
		ELSE
			salesOrderLine.[Line No_]
	END LineNumber,      
	'000' ShipperCode,
	salesOrderLine.No_ ItemCode,
	CASE 
		WHEN salesOrderLine.[Location Code] = 'BUCK CONS' THEN
			pr.[Global Dimension 2 Code]
		ELSE
			salesOrderLine.[Location Code]
	END SiteCode,
	RTRIM(customer.No_) CustomerShipToCode, --??
	1 DemandType, --only get sales orders on purpose
	2 LineStatus,
	salesOrderLine.[Posting Date] DemandDate,    -- OR [Requested Delivery Date] ??
	salesOrderLine.[Shipment Date] RequestedShipDate,    -- OR [Planned Shipment Date] ??
	NULL RequiredDate,
	CAST(salesOrderLine.[Quantity] as decimal(19, 5)) Quantity,
	CAST((salesOrderLine.[Item Charge Base Amount]/salesOrderLine.[Quantity]) as decimal(19, 5)) InvoicePrice, 
	NULL AS InvoicePriceCurrency,
	0 IsExceptional,
	0 IsOnPromotion,
	NULL Note,
	NULL DateUpdated,
	CAST(salesOrderLine.[Unit Cost] as decimal(19,5)) As InvoiceCost,
	NULL AS InvoiceCostCurrency,
	CONVERT(varchar(10),salesOrderLine.[Posting Date], 101) AS DateOrdered,
	NULL As QuantityShipped,
	0 As IsDropShip
FROM [Liberty Mountain$Sales Shipment Line] AS salesOrderLine WITH (NOLOCK)
INNER JOIN dbo.[Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON itemQuantity.[No_] = salesOrderLine.No_
LEFT JOIN [Liberty Mountain$Sales Shipment Header] AS salesOrder WITH (NOLOCK)            
	ON salesOrderLine.[Document No_] = salesOrder.No_
LEFT JOIN [Liberty Mountain$Customer] customer WITH (NOLOCK)
	ON RTRIM(customer.[No_]) = RTRIM(salesOrder.[Sell-to Customer No_])
LEFT join [Liberty Mountain$Item Ledger Entry] AS pr WITH (NOLOCK)
		ON salesOrderLine.No_ = pr.[Item No_]
		AND pr.[Document No_] = salesOrder.No_
		AND pr.[Location Code] = salesOrderLine.[Location Code]
WHERE salesOrderLine.[Posting Date] >= @OldestDate 
AND salesOrderLine.[Quantity] <> 0
AND salesOrderLine.Type = 2  --Item
AND RTRIM(salesOrderLine.No_) <> ''
AND salesOrderLine.[Location Code] IN ('UT','PA')
AND itemQuantity.Blocked = 0

UNION

--RS: insert open transfer orders 
SELECT
	'000' DemandSeriesCode,
	transerLine.[Document No_] OrderNumber,       
	CASE
		WHEN transerLine.[Line No_]>= 10000 THEN
			CAST(transerLine.[Line No_]*1.00/10000 AS DECIMAL(6,3))
		ELSE
			transerLine.[Line No_]
	END LineNumber,      
	'000' ShipperCode,
	UPPER(transerLine.[Item No_]) ItemCode,
	UPPER(transerLine.[Transfer-from Code]) SiteCode,
	transerLine.[Transfer-to Code] CustomerShipToCode, 
	1 DemandType, --only get sales orders on purpose
	1 LineStatus,
	CONVERT(varchar(10),transferHeader.[Shipment Date], 101) DemandDate,    -- Correct Source?
	CONVERT(varchar(10),transferHeader.[Shipment Date], 101) RequestedShipDate,    -- Correct Source?
	NULL RequiredDate,
	CAST(transerLine.[Outstanding Quantity] as decimal(19, 5)) Quantity,
	0 InvoicePrice,       
	NULL AS InvoicePriceCurrency,
	0 IsExceptional,
	0 IsOnPromotion,
	NULL Note,
	NULL DateUpdated,
	NULL As InvoiceCost,
	NULL AS InvoiceCostCurrency,
	CONVERT(varchar(10),transferHeader.[Shipment Date], 101) AS DateOrdered,
	NULL As QuantityShipped,
	0 As IsDropShip
FROM [Liberty Mountain$Transfer Line] AS transerLine WITH (NOLOCK)
INNER JOIN [Liberty Mountain$Transfer Header] AS transferHeader WITH (NOLOCK)
	ON transerLine.[Document No_] = transferHeader.No_
INNER JOIN dbo.[Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON itemQuantity.[No_] = transerLine.[Item No_]
WHERE transerLine.[Item No_] <> '' 
AND transerLine.Quantity > 0
AND transerLine.[Outstanding Quantity] <> 0
AND UPPER(transerLine.[Transfer-from Code]) IN ('UT','PA')
AND (transerLine.[Item No_] >= '000000') AND (transerLine.[Item No_] <= '999999')
AND itemQuantity.Blocked = 0;
