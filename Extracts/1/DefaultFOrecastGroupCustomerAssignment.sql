SET NOCOUNT ON;

SELECT DISTINCT
	CASE
		WHEN RTRIM(custShipTo.[Territory Code]) = 'House Accounts' THEN
			UPPER(RTRIM(custShipTo.[No_]))
		ELSE	
			UPPER(RTRIM(custShipTo.[Territory Code]) )
	END ForecastGroupCode,
	UPPER(RTRIM(custShipTo.[No_])) CustomerShipToCode
	FROM dbo.[Liberty Mountain$Customer] custShipTo

WHERE -- If neither FG or Territory is provided then customer will default to All Other/Unassigned
RTRIM(custShipTo.[No_]) <> '' OR
RTRIM(custShipTo.[Territory Code]) <> ''

ORDER BY ForecastGroupCode, CustomerShipToCode;