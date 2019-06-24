SET NOCOUNT ON;

--vendors
SELECT 
	supplier.[No_] SupplierCode,
	'000' ShipperCode,
	CASE
		WHEN RTRIM(LTRIM(supplier.[NAME])) ='' THEN supplier.[No_]
		ELSE
			REPLACE(REPLACE(REPLACE(supplier.[NAME],'/',''),CHAR(10),''),CHAR(13),'') 
	END Name,
	1 Type,
	NULL ErpComments,
	case when supplier.[Payment Method Code] IS NULL THEN NULL ELSE RTRIM(supplier.[Payment Method Code]) END AS DefaultPaymentTerms,
	NULL DefaultCashDiscount,
	'USD' DefaultCurrency,
	REPLACE(REPLACE(REPLACE(supplier.Contact,'/',''),CHAR(10),''),CHAR(13),'') ContactName, --???
	REPLACE(REPLACE(REPLACE(supplier.[Phone No_],'/',''),CHAR(10),''),CHAR(13),'') Phone,
	REPLACE(REPLACE(REPLACE(supplier.[Fax No_],'/',''),CHAR(10),''),CHAR(13),'') Fax,
	supplier.[E-Mail] Email,
	NULL WebsiteUrl,
	REPLACE(REPLACE(REPLACE(supplier.[Address],'/',''),CHAR(10),''),CHAR(13),'') AddressLine,
	CONCAT('Vendor Min: ', supplier.[Minimum Order Amount]) AddressLine2,
	Concat(CONCAT('Indirect Cost: ', Format(supplier.[Indirect Cost %], 'N2')),'%')  AddressLine3,
	RTRIM(supplier.City) City,
	RTRIM(supplier.County) [State],
	RTRIM(supplier.[Post Code]) PostalCode,
	RTRIM(supplier.[Country_Region Code]) Country,
	NULL DateUpdated,
	NULL SiteCode,
	ISNULL(NULLIF(RTRIM([Shipment Method Code]),''),'TBD') DefaultShipMethod  
	 
FROM dbo.[Liberty Mountain$Vendor] AS supplier WITH (NOLOCK)

ORDER BY supplier.[No_];


