
-- Identify duplicate rows
SELECT InvoiceNo, StockCode, CustomerID, COUNT(*) AS Cnt
FROM analytics.FactSales
GROUP BY InvoiceNo, StockCode, CustomerID
HAVING COUNT(*) > 1;


-- Add Derived Columns: TotalPrice + Discount Simulation

SELECT *,
  CASE 
    WHEN Quantity >= 10 THEN 0.10
    ELSE 0.0
  END AS DiscountRate,
  (Quantity * UnitPrice) * (1 - 
    CASE 
      WHEN Quantity >= 10 THEN 0.10
      ELSE 0.0
    END) AS FinalAmount
FROM analytics.FactSales;

--Fix Inconsistent Product Descriptions

SELECT DISTINCT Description
FROM analytics.DimProduct
WHERE Description LIKE '%?%' OR Description LIKE '%#%' OR Description LIKE '%*%';

--Handle Missing Data (CustomerID/Description/etc.)

-- Customers with missing CustomerID
SELECT * FROM staging.sales_raw WHERE CustomerID IS NULL;

-- Products with NULL description
SELECT * FROM analytics.DimProduct WHERE Description IS NULL OR Description = '';

--where the customerid is null we are replacing nulls with 'GUEST'

UPDATE staging.sales_raw
SET CustomerID = 'GUEST'
WHERE CustomerID IS NULL;

--Add GUEST Row in DimCustomer (if you haven't already)

INSERT INTO analytics.DimCustomer (CustomerID, Country)
SELECT 'GUEST', 'UNKNOWN'
WHERE NOT EXISTS (
  SELECT 1 FROM analytics.DimCustomer WHERE CustomerID = 'GUEST'
);


--Simulate Categorical Grouping

ALTER TABLE analytics.DimCustomer ADD Region NVARCHAR(50);

UPDATE analytics.DimCustomer
SET Region = 
  CASE 
    WHEN Country IN ('United Kingdom', 'France', 'Germany') THEN 'Western Europe'
    WHEN Country IN ('USA', 'Canada') THEN 'North America'
    ELSE 'Others'
  END;


  --Create RFM(Recency, Frequency, Monetary ) Segments (Marketing Readiness)

  -- Frequency: number of orders per customer
SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS Frequency
FROM analytics.FactSales
GROUP BY CustomerID;

-- Recency: Last purchase date
SELECT CustomerID, MAX(InvoiceDate) AS LastPurchase
FROM analytics.FactSales
GROUP BY CustomerID;

-- Monetary: Total spend
SELECT CustomerID, SUM(TotalAmount) AS MonetaryValue
FROM analytics.FactSales
GROUP BY CustomerID;


--Create Product Category Codes
--You can create a ProductCategory column from StockCode pattern

-- Example rule
ALTER TABLE analytics.DimProduct ADD ProductCategory NVARCHAR(50);

UPDATE analytics.DimProduct
SET ProductCategory =
  CASE 
    WHEN StockCode LIKE '2%' THEN 'Stationery'
    WHEN StockCode LIKE '8%' THEN 'Electronics'
    ELSE 'General'
  END;

-- Identify Anomalies

SELECT *
FROM analytics.FactSales
WHERE UnitPrice > 1000 OR Quantity > 1000;


--Create a Reporting View


CREATE VIEW analytics.vw_SalesReport AS
SELECT 
  f.InvoiceNo,
  f.InvoiceDate,
  d.Year, d.Month, d.Quarter,
  c.CustomerID, c.Country, c.Region,
  p.StockCode, p.Description, p.ProductCategory,
  f.Quantity,
  f.UnitPrice,
  f.TotalAmount
FROM analytics.FactSales f
JOIN analytics.DimCustomer c ON f.CustomerID = c.CustomerID
JOIN analytics.DimProduct p ON f.StockCode = p.StockCode
JOIN analytics.DimDate d ON f.InvoiceDate = d.FullDate;





