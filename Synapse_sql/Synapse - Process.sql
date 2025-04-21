
--creating a raw data table which we got from ADF(Copy activity)

CREATE SCHEMA staging;

CREATE TABLE staging.sales_raw (
    InvoiceNo NVARCHAR(50),
    StockCode NVARCHAR(50),
    Description NVARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID NVARCHAR(50),
    Country NVARCHAR(100)
);

--Purpose: Store the raw CSV data in SQL before cleaning and transforming.




--Create Dimension Tables in Synapse

--Create schema:

CREATE SCHEMA analytics;

--Create DimProduct,DimCustomer, Dimdate, FactSales


CREATE TABLE analytics.DimProduct
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT DISTINCT 
  StockCode, 
  Description
FROM staging.sales_raw
WHERE StockCode IS NOT NULL AND Description IS NOT NULL;

---

CREATE TABLE analytics.DimCustomer
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT DISTINCT 
  CAST(CustomerID AS VARCHAR(50)) AS CustomerID,
  Country
FROM staging.sales_raw
WHERE CustomerID IS NOT NULL;


--

CREATE TABLE analytics.DimDate
WITH (
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT DISTINCT
  CAST(InvoiceDate AS DATE) AS FullDate,
  DATEPART(YEAR, InvoiceDate) AS Year,
  DATEPART(MONTH, InvoiceDate) AS Month,
  DATEPART(QUARTER, InvoiceDate) AS Quarter,
  DATENAME(WEEKDAY, InvoiceDate) AS DayOfWeek
FROM staging.sales_raw
WHERE InvoiceDate IS NOT NULL;


--


CREATE TABLE analytics.FactSales
WITH (
    DISTRIBUTION = HASH(CustomerID),
    CLUSTERED COLUMNSTORE INDEX
)
AS
SELECT
  InvoiceNo,
  CAST(CustomerID AS VARCHAR(50)) AS CustomerID,
  StockCode,
  CAST(InvoiceDate AS DATE) AS InvoiceDate,
  Quantity,
  UnitPrice,
  Quantity * UnitPrice AS TotalAmount
FROM staging.sales_raw
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0;


























