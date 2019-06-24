SET NOCOUNT ON

SELECT DISTINCT
	RTRIM([Purchaser Code]) BuyerCode,
	RTRIM([Purchaser Code]) [Name],
	NULL Phone,
	NULL Fax,
	NULL Email,
	NULL WebSiteUrl,
	NULL AddressLine1,
	NULL AddressLine2,
	NULL AddressLine3,
	NULL City,
	NULL [State],
	NULL PostalCode,
	NULL Country,
	NULL DateUpdated
FROM dbo.[Liberty Mountain$Vendor] AS buyer
WHERE RTRIM([Purchaser Code]) IN ('LM', 'LM1', 'LM2', 'LM3', 'LM4', 'LMC')
ORDER BY BuyerCode;
