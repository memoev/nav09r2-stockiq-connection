SET NOCOUNT ON;
-------------------------------------
-- Do not change below this line.
SELECT
	CAST(salesOrderLine.[Document No_] AS VARCHAR) + '--' +
	CAST(
		CASE WHEN salesOrderLine.[Line No_] >= 10000 THEN
			salesOrderLine.[Line No_]*1.00/10000
		ELSE
			salesOrderLine.[Line No_]
		END
	AS VARCHAR) OutgoingShipmentCode,
	salesOrder.[No_] OrderNumber,      
	CASE
		WHEN salesOrderLine.[Line No_]>=10000 THEN
			salesOrderLine.[Line No_]*1.00/10000 
		ELSE
			salesOrderLine.[Line No_]
	END LineNumber,  
	salesOrderLine.[Shipment Date] DateShipped,  
	CAST(salesOrderLine.Quantity AS DECIMAL(19, 5)) QuantityShipped,
	salesOrderLine.[Planned Delivery Date] DateDelivered, 
	CAST(salesOrderLine.Quantity AS DECIMAL(19, 5)) QuantityDelivered,  -- OR [Quantity Invoiced]?
	1 ShipmentOriginType,
	NULL ShippingMethodCode,
	NULL ShippingCarrierCode,
	NULL ShipStatus,
	NULL TrackingNumber,
	NULL DateUpdated,
	CAST(salesOrderLine.[Unit Price] AS DECIMAL(19, 5)) InvoicePrice,
	'USD' InvoicePriceCurrency,
	'USD' InvoicePriceCurrency,
	CAST(salesOrderLine.[Unit Cost] AS DECIMAL(19, 5)) InvoiceCost, 
	'USD' InvoiceCostCurrency
FROM [Liberty Mountain$Sales Shipment Line] AS salesOrderLine WITH (NOLOCK)
INNER JOIN dbo.[Liberty Mountain$Item] AS itemQuantity WITH (NOLOCK)
	ON itemQuantity.[No_] = salesOrderLine.[No_]
LEFT JOIN [Liberty Mountain$Sales Shipment Header] AS salesOrder WITH (NOLOCK)
	ON salesOrderLine.[Document No_] = salesOrder.No_

WHERE salesOrderLine.Quantity <> 0	
AND salesOrderLine.Type = 2  --Item
AND RTRIM(salesOrderLine.No_) <> ''
AND salesOrderLine.[Shipment Date] >= dateadd(month, datediff(month,0,dateadd(yy,-3,getdate())), 0)
AND itemQuantity.Blocked = 0

ORDER BY DateShipped DESC, OutgoingShipmentCode, OrderNumber, LineNumber;