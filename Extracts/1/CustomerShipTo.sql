/******************************************************/
/* NOTE:  This script assumes customer uses the base  */
/*        customer number as the customer ship-to.    */
/******************************************************/

SET NOCOUNT ON

SELECT 
	RTRIM(cust.[No_]) CustomerShipToCode,    
	IIF(RTRIM(cust.[Name])='', RTRIM(cust.[No_]), RTRIM(cust.[Name])) [Name],
	0 IsProspect,
	0 IsCritical,
	RTRIM(cust.[No_]) CustomerCode,
	cust.Contact ContactName,
	cust.[Phone No_] Phone,
	RTRIM(cust.[Fax No_]) Fax,
	RTRIM(cust.[E-Mail]) Email,
	NULL WebSiteUrl,
	REPLACE(REPLACE(REPLACE(RTRIM(cust.Address),CHAR(9),''),CHAR(10),''),CHAR(13),'') AddressLine1,
	REPLACE(REPLACE(REPLACE(RTRIM(cust.[Address 2]),CHAR(9),''),CHAR(10),''),CHAR(13),'') AddressLine2,
	NULL AddressLine3,
	REPLACE(REPLACE(REPLACE(RTRIM(cust.City),CHAR(9),''),CHAR(10),''),CHAR(13),'') City,
	REPLACE(REPLACE(REPLACE(RTRIM(cust.County),CHAR(9),''),CHAR(10),''),CHAR(13),'') [State],
	REPLACE(REPLACE(REPLACE(RTRIM(cust.[Post Code]),CHAR(9),''),CHAR(10),''),CHAR(13),'') PostalCode,
	REPLACE(REPLACE(REPLACE(RTRIM(cust.[Country_Region Code]),CHAR(9),''),CHAR(10),''),CHAR(13),'') Country,
	NULL ReservedForFutureUse,
	NULL DateUpdated
FROM dbo.[Liberty Mountain$Customer] cust
ORDER BY RTRIM(cust.[No_]);