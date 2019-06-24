SET NOCOUNT ON
-- Uncomment these lines to debug:
--DECLARE @OldestDate date = dateadd(month, datediff(month,0,dateadd(yy,-3,getdate())), 0);
-------------------------------------
-- Do not change below this line.

--Working POs
SELECT DISTINCT
	'000' ShipperCode,
	poLine.[Document No_] ErpOrderNumber,
	CASE
		WHEN poHeader.[External Document No_] LIKE '%SIQ%' THEN
			poHeader.[External Document No_]
	END StockIqOrderNumber,
	poLine.[Buy-from Vendor No_] SupplierCode,  
	1 SupplyType, --PO
	poHeader.[Order Date] OrderCreationDate,   --OR poLine.[Planned Receipt Date]
	poHeader.[Order Date] ReleaseDate, 
	NULL ExpectedReleaseDate,
	NULL InternalNote,
	NULL ExternalNote,
	NULL  PaymentTermsCode,
	NULL CashDiscountCode,
	poHeader.[Order Date] DateCreated,
	NULL DateUpdated
FROM [Liberty Mountain$Purchase Line] AS poLine WITH (NOLOCK)
INNER JOIN  [Liberty Mountain$Purchase Header] AS poHeader    
	ON poLine.[Document Type] = poHeader.[Document Type]
	AND poLine.[Document No_] = poHeader.No_
WHERE poLine.[Order Date] >= @OldestDate
AND UPPER(poHeader.[Location Code]) IN ('UT','PA')
AND UPPER(poLine.[Location Code]) IN ('UT','PA')
AND ISNUMERIC(poLine.[No_]) = 1
AND poLine.[No_] BETWEEN 0 AND 999999

UNION 

--History PO
SELECT DISTINCT
	'000' ShipperCode,
	poLine.[Document No_] ErpOrderNumber,
	NULL StockIqOrderNumber,
	poLine.[Buy-from Vendor No_] SupplierCode,  
	1 SupplyType, --PO
	poHeader.[Order Date] OrderCreationDate,   --OR poLine.[Planned Receipt Date]
	poHeader.[Order Date] ReleaseDate, 
	NULL ExpectedReleaseDate,
	NULL InternalNote,
	NULL ExternalNote,
	NULL  PaymentTermsCode,
	NULL CashDiscountCode,
	poHeader.[Order Date] DateCreated,
	NULL DateUpdated
FROM [Liberty Mountain$Purchase Line Archive] AS poLine WITH (NOLOCK)
INNER JOIN  [Liberty Mountain$Purchase Header Archive] AS poHeader    
	ON poLine.[Document Type] = poHeader.[Document Type]
	AND poLine.[Document No_] = poHeader.No_
WHERE poLine.[Order Date] >= @OldestDate
AND UPPER(poHeader.[Location Code]) IN ('UT','PA')
AND UPPER(poLine.[Location Code]) IN ('UT','PA')
AND ISNUMERIC(poLine.[No_]) = 1
AND poLine.[No_] BETWEEN 0 AND 999999

UNION --transfers

SELECT DISTINCT
	'000' ShipperCode,
	poLine.[Document No_] ErpOrderNumber,
	CASE
		WHEN poHeader.[External Document No_] LIKE '%SIQ%' then poHeader.[External Document No_] 
	ELSE
		NULL
	END StockIqOrderNumber,
	poLine.[Transfer-from Code] SupplierCode,
	8 SupplyType, --Transfer
	poHeader.[Receipt Date] OrderCreationDate,  --OR poHeader.[Posting Date]
	poHeader.[Posting Date] ReleaseDate,  --??
	NULL ExpectedReleaseDate,
	NULL InternalNote,
	NULL ExternalNote,
	NULL PaymentTermsCode,
	NULL CashDiscountCode,
	CONVERT (varchar(10),poHeader.[Receipt Date],111) DateCreated,
	NULL DateUpdated
FROM	[Liberty Mountain$Transfer Line] AS poLine WITH (NOLOCK)
	INNER JOIN  [Liberty Mountain$Transfer Header] AS poHeader
		ON poLine.[Document No_] = poHeader.No_
WHERE poLine.[Outstanding Quantity] > 0
AND poHeader.[Receipt Date] >= @OldestDate
AND poLine.[Item No_] <> ''
;