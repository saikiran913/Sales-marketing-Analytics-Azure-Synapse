# 📊 Sales & Marketing Analytics with Azure Synapse

An end-to-end data engineering project simulating a real-world sales and marketing analytics pipeline using **Azure Synapse**, **Azure Data Factory**, and **Power BI**.

---

## 🚀 Project Summary

This project showcases how to ingest, clean, transform, model, and visualize sales data using Microsoft Azure tools.

---

## 🧱 Tech Stack

- **Azure Data Factory** – Ingest CSV from Blob Storage to Synapse
- **Azure Synapse Analytics (Dedicated SQL Pool)** – Data modeling and transformation
- **Power BI** – Dashboard visualization
- **Azure Blob Storage** – Source data

---

## 📐 Data Modeling (Star Schema)

The Image is included with the name ERD(Fact and dim)

**Fact Table**:
- `FactSales`

**Dimension Tables**:
- `DimCustomer`
- `DimProduct`
- `DimDate`

---

## ⚙️ ETL Process

1. Upload `sales_data.csv` to Azure Blob
2. Use ADF to copy raw data to Synapse `staging.sales_raw`
3. Create star schema tables in `analytics` schema
4. Perform data cleaning & transformations
5. Create reporting views
6. Connect Power BI to Synapse and build reports

---

## 📊 Power BI Dashboard


Visualizations include:
- Monthly Revenue
- Top Products
- Sales by Country
- Customer Segmentation
- Order Funnel

---



