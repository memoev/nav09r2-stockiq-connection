SET NOCOUNT ON;

SELECT DISTINCT
	RTRIM([Payment Terms Code]) AS	[PaymentTermsCode],
	RTRIM([Payment Terms Code]) AS [Name],
	0 As PaymentMethod,
	NULL As PaymentDays,
	NULL AS [DateUpdated]
FROM [Liberty Mountain$Vendor]
WHERE RTRIM([Payment Terms Code]) <> '';