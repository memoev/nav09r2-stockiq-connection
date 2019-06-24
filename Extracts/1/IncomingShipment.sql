SET NOCOUNT ON;

WITH finalQTY AS
(
	SELECT 
	RTRIM(receiptLine.[Document No_]) docNumber,
	RTRIM(receipt.[Order No_]) ErpOrderNumber,
	CASE
		WHEN receiptLine.[Order Line No_]%10000 = 5000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN receiptLine.[Order Line No_] >= 10000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			receiptLine.[Order Line No_]
	END LineNumber,
	SUM(CAST(receiptLine.[Quantity Invoiced] * itemUOM.[Qty_ per Unit of Measure] AS DECIMAL(19, 5))) as totalQTY
	FROM [Liberty Mountain$Purch_ Rcpt_ Line] receiptLine
	INNER JOIN [Liberty Mountain$Purch_ Rcpt_ Header] receipt
	ON receiptLine.[Document No_] = receipt.No_
	LEFT JOIN [Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON UPPER(itemQuantity.No_) = UPPER(receiptLine.[No_])
	LEFT JOIN [Liberty Mountain$Item Unit of Measure] as itemUOM
	ON itemQuantity.No_ = itemUOM.[Item No_]
	AND itemQuantity.[Purch_ Unit of Measure] = itemUOM.Code
	WHERE receiptLine.[Planned Receipt Date] >= dateadd(month, datediff(month,0,dateadd(yy,-3,getdate())), 0)
	GROUP BY RTRIM(receiptLine.[Document No_]),
	RTRIM(receipt.[Order No_]),
	CASE
		WHEN receiptLine.[Order Line No_]%10000 = 5000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN receiptLine.[Order Line No_] >= 10000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			receiptLine.[Order Line No_]
	END
)

SELECT 
	RTRIM(receiptLine.[Document No_]) + '-' + CAST(receiptLine.[Line No_]/10000 as varchar) IncomingShipmentCode,
	RTRIM(receipt.[Order No_]) ErpOrderNumber,
	CASE
		WHEN receiptLine.[Order Line No_]%10000 = 5000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN receiptLine.[Order Line No_] >= 10000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			receiptLine.[Order Line No_]
	END ErpLineNumber,
	receiptLine.[Expected Receipt Date] DateShipped,
	SUM(CAST(receiptLine.Quantity * itemUOM.[Qty_ per Unit of Measure] AS DECIMAL(19, 5))) QuantityShipped,
	receiptLine.[Planned Receipt Date] DateDelivered,
	SUM(CAST(receiptLine.[Quantity Invoiced] * itemUOM.[Qty_ per Unit of Measure] AS DECIMAL(19, 5))) QuantityDelivered, 
	receiptLine.[Posting Date] DateReceived,
	RTRIM(receipt.[Shipment Method Code]) ShippingMethodCode,
	NULL ShippingCarrierCode,
	8 ShipStatus,
	0 IsEmergencyShipment,
	NULL TrackingNumber,
	NULL ContainerNumber,
	NULL DateUpdated
FROM [Liberty Mountain$Purch_ Rcpt_ Line] receiptLine
INNER JOIN [Liberty Mountain$Purch_ Rcpt_ Header] receipt
	ON receiptLine.[Document No_] = receipt.No_
LEFT JOIN [Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON UPPER(itemQuantity.No_) = UPPER(receiptLine.[No_])
LEFT JOIN [Liberty Mountain$Item Unit of Measure] as itemUOM
	ON itemQuantity.No_ = itemUOM.[Item No_]
	AND itemQuantity.[Purch_ Unit of Measure] = itemUOM.Code

WHERE receiptLine.[Planned Receipt Date] >= dateadd(month, datediff(month,0,dateadd(yy,-3,getdate())), 0)
AND receiptLine.[Location Code] IN ('UT','PA')
AND RTRIM(receipt.[Order No_]) <> ''
AND RTRIM(receipt.[Order No_]) IS NOT NULL
AND receiptLine.Quantity <> 0 
--AND receiptLine.Type = 2  --Item
AND RTRIM(receiptLine.No_) <> ''

GROUP BY 
	RTRIM(receiptLine.[Document No_]) + '-' + CAST(receiptLine.[Line No_]/10000 as varchar),
	RTRIM(receipt.[Order No_]),
	CASE
		WHEN receiptLine.[Order Line No_]%10000 = 5000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))+.5
		WHEN receiptLine.[Order Line No_] >= 10000 THEN
			CAST(receiptLine.[Order Line No_]/10000 AS DECIMAL(6,3))
		ELSE
			receiptLine.[Order Line No_]
	END,
	receiptLine.[Expected Receipt Date],
	receiptLine.[Planned Receipt Date],
	receiptLine.[Posting Date],
	RTRIM(receipt.[Shipment Method Code])

;