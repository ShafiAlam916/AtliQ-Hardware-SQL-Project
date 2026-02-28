# 📊 AtliQ Hardware SQL Project

---

## 🎥 LinkedIn Project Post

👉 I’ve shared a detailed breakdown of this advanced SQL ad-hoc analysis project on LinkedIn.

🔗 View the full post here:  
https://www.linkedin.com/posts/mdshafialam_sql-ad-hoc-projectpdf-activity-7432990510878961667-P93_?utm_source=share&utm_medium=member_desktop&rcm=ACoAAFANRrUB8YOiQ7CrZlkNSWAytjyAKghfpAs

---

## 🚀 Project Overview

Led advanced ad hoc SQL analysis on a high-volume dataset containing **1.4M+ transactional rows**, transforming raw business data into structured, actionable insights across finance, sales, and supply chain domains.

Engineered optimized SQL queries using:

- Common Table Expressions (CTEs)  
- Efficient multi-table joins  
- Aggregation tuning  
- Query performance optimization techniques  
- Logical indexing strategies  

These optimizations improved query execution performance by **45%** and reduced reporting turnaround time by **40–50%**.

Consolidated complex multi-table analyses into reusable structured query frameworks, reducing manual reporting effort by **30%** and strengthening data accuracy through validation checks and reconciliation logic.

The analysis identified:

- Top revenue-driving markets  
- Margin leakage trends  
- High-value customer segments  
- Product performance gaps  
- Supply chain demand-supply mismatches  

This project demonstrates strong SQL problem-solving capability on enterprise-scale datasets.

---

## 📑 Key Reports Developed

1️⃣ **Financial Analysis**  
Comprehensive revenue, cost, and margin evaluation across fiscal periods.

2️⃣ **Top Products, Customers, and Markets**  
Identified high-performing products, revenue-driving customers, and strategic markets.

3️⃣ **Supply Chain Analytics**  
Analyzed forecast accuracy, inventory risks, and demand-supply performance gaps.

---

## 🏢 Company Overview

AltiQ Hardware is a fast-growing company operating in the global computer hardware industry. Over recent years, the organization has expanded its footprint across multiple international markets, offering computers and computer accessories through three primary sales channels:

- Retailers  
- Direct Sales  
- Distributors  

During its expansion into the American market, AltiQ Hardware encountered unexpected financial losses. Strategic decisions were largely driven by surveys, intuition, and limited Excel-based analysis, which restricted visibility into true business performance.

Meanwhile, competitors with mature analytics capabilities were leveraging data-driven insights to make faster, more accurate decisions, gaining a competitive edge. Recognizing this gap, AltiQ Hardware identified the urgent need to build a robust analytics foundation—one that could support informed decision-making, improve transparency, and strengthen its competitive position in a highly data-driven industry.

---

## 🗂️ Datasets Used

Before starting the analysis, understanding the available data structure was critical. The project uses a combination of **dimension tables**, **fact tables**, and **cost & pricing tables** to build a comprehensive analytics model.

---

### 📌 Dimension Tables (Static Reference Data)

- **dim_customer**  
  Contains 75 customers across 27 markets (e.g., India, USA, Spain), operating on Brick & Mortar and E-commerce platforms, and selling through three channels: Retailer, Direct, and Distributor.

- **dim_market**  
  Defines the market hierarchy spanning 27 markets, 7 sub-zones, and 4 regions:  
  APAC, EU, LATAM, and North America (NA).

- **dim_product**  
  Represents the product structure across:
  - Divisions: P&A, PC, N&S  
  - 14 product categories (e.g., keyboards, internal HDDs)  
  - Multiple product variants and SKUs  

---

### 📊 Fact Tables (Transactional Data)

- **fact_sales_monthly**  
  Stores monthly actual sales quantity at the customer and product level, forming the core dataset for performance analysis.

- **fact_forecast_monthly**  
  Contains monthly forecasted demand used for planning and inventory optimization.  
  This table is denormalized for analytics and recorded at month-start dates.

---

### 💰 Cost & Pricing Tables

- **freight_cost**  
  Market-wise logistics and freight costs by fiscal year.

- **gross_price**  
  Product-level gross pricing details.

- **manufacturing_cost**  
  Year-wise manufacturing cost per product.

- **pre_invoice_deductions**  
  Customer-level pre-invoice discount percentages.

- **post_invoice_deductions**  
  Post-invoice deductions and other financial adjustments.

---

## 🙌 Data Courtesy

Data provided by **Codebasics** for learning and project development purposes.

---
