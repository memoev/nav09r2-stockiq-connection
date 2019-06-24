SET NOCOUNT ON;
DECLARE @bomSite VARCHAR(2) = '**ENTER PROD SITE HERE**';
-- Do not change below this line.

SELECT DISTINCT
	UPPER(bomHeader.No_) ParentItemCode,
	@bomSite ParentSiteCode,
	UPPER(bomDetail.No_) ChildItemCode,
	@bomSite ChildSiteCode,
	'000' ShipperCode,
	CAST(bomDetail.Quantity AS DECIMAL(19,5)) QuantityPer,
	NULL DateUpdated	
FROM [WXYZ$Production BOM Header] AS bomHeader 
INNER JOIN [WXYZ$Production BOM Line] AS bomDetail
	ON bomHeader.No_ = bomDetail.[Production BOM No_]

INNER JOIN [WXYZ$Stockkeeping Unit] AS Stockkeeping WITH (NOLOCK)
	ON UPPER(bomHeader.No_) = Stockkeeping.[Item No_]
	AND Stockkeeping.[Location Code] = @bomSite
INNER JOIN [WXYZ$Stockkeeping Unit] AS compStockkeeping WITH (NOLOCK)
	ON UPPER(bomDetail.No_) = compStockkeeping.[Item No_]
	AND compStockkeeping.[Location Code] = @bomSite

LEFT JOIN [WXYZ$Item] as itemQuantity WITH (NOLOCK)
	ON UPPER(itemQuantity.No_) = UPPER(bomHeader.No_)
LEFT JOIN [WXYZ$Production BOM Version] AS Version
	ON bomHeader.No_ = Version.[Production BOM No_]
	AND Version.[Version Code] NOT IN ('4', '8','2')
WHERE itemQuantity.Blocked <> 1
AND bomDetail.[Version Code] NOT IN ('4', '8','2')
AND bomDetail.Type = 1
AND RTRIM(bomDetail.No_) <> '';