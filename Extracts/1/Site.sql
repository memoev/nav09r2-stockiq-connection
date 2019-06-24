SET NOCOUNT ON;

SELECT DISTINCT
	site.[Code] SiteCode,
	RTRIM(site.[Name]) Name,
	4 Type, 
	NULL Area,
	NULL Volume,
	'USD' DefaultCurrency,
	RTRIM(site.[Phone No_]) Phone,
	RTRIM(site.[Fax No_]) Fax,
	RTRIM(site.[E-Mail]) Email,
	NULL WebsiteUrl,
	RTRIM(site.Address) AddressLine1,
	RTRIM(site.[Address 2]) AddressLine2,
	NULL AddressLine3,
	RTRIM(site.City) City,
	RTRIM(site.County) State,
	RTRIM(site.[Post Code]) PostalCode,
	RTRIM(site.[Country_Region Code]) Country,
	NULL DateUpdated
FROM [Liberty Mountain$Location] AS site
WHERE site.[Code] IN ('UT','PA')
ORDER BY site.[Code];