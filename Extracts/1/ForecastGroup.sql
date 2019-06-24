SET NOCOUNT ON;

SELECT DISTINCT
	RTRIM(custShipTo.[No_]) ForecastGroupCode,
	RTRIM(custShipTo.[Name]) [Name]
	FROM dbo.[Liberty Mountain$Customer] custShipTo
	WHERE RTRIM([Territory Code]) = 'House Accounts'

UNION

SELECT DISTINCT
	UPPER(RTRIM([Territory Code])) ForecastGroupCode, 
	UPPER(RTRIM([Territory Code])) [Name]
	FROM dbo.[Liberty Mountain$Customer] custShipTo
	WHERE RTRIM([Territory Code]) <> 'House Accounts'

ORDER BY ForecastGroupCode;