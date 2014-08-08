--Add Unique Index
CREATE UNIQUE NONCLUSTERED INDEX
idx_ContactName ON dbo.Customers
(
ContactName
) ON [PRIMARY]