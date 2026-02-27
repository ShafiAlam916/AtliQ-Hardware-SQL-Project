-- For using window functions properly we need to turn off 'ONLY_FULL_GROUP_BY' mode
SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

/* ============================================================
   1) Top Markets, Products, and Customers by Net Sales
   ============================================================

   As a Product Owner, I want a report for top markets, products,
   and customers by net sales for a given financial year so that
   I can get a holistic view of financial performance and take
   appropriate actions to address potential issues.

   Requirements:
   - Top Markets:
       • Rank
       • Market
       • Net Sales (in millions)

   - Top Products:
       • Rank
       • Product
       • Net Sales

   - Top Customers:
       • Rank
       • Customer
       • Net Sales

   Note:
   - Implement as a stored procedure.
   - Should be reusable for any financial year.
   ============================================================ */

-- This view generates detailed gross sales data by joining sales, customer, product, and price tables.

DROP VIEW IF EXISTS gdb0041.gross_test_sales;

CREATE VIEW gdb0041.gross_test_sales AS
SELECT 
    s.date AS date,
    s.fiscal_year AS fiscal_year,
    c.customer_code AS customer_code,
    c.customer AS customer,
    c.market AS market,
    c.region AS region,
    p.product AS product,
    p.variant AS variant,
    s.sold_quantity AS sold_quantity,
    g.gross_price AS gross_price,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_price_mln
FROM gdb0041.fact_sales_monthly s
JOIN gdb0041.dim_customer c 
    ON s.customer_code = c.customer_code
JOIN gdb0041.dim_product p 
    ON s.product_code = p.product_code
JOIN gdb0041.fact_gross_price g 
    ON s.product_code = g.product_code
   AND s.fiscal_year = g.fiscal_year;
   
   
-- This view generates gross sales data along with pre-invoice discount percentage for each transaction.

DROP VIEW IF EXISTS gdb0041.sales_pre_inv_discount;

CREATE VIEW gdb0041.sales_pre_inv_discount AS
SELECT 
    s.date AS calendar_date,
    s.fiscal_year AS fiscal_year,
    s.product_code AS prod_code,
    p.product AS product,
    s.customer_code AS cust_code,
    c.customer AS customer,
    c.market AS market,
    p.variant AS variant,
    s.sold_quantity AS sold_quantity,
    g.gross_price AS gross_price_per_unit,
    ROUND(s.sold_quantity * g.gross_price, 2) AS total_gross_sales,
    pre.pre_invoice_discount_pct AS pre_invoice_discount_pct
FROM gdb0041.fact_sales_monthly s
JOIN gdb0041.dim_product p 
    ON s.product_code = p.product_code
JOIN gdb0041.fact_gross_price g 
    ON s.product_code = g.product_code
   AND s.fiscal_year = g.fiscal_year
JOIN gdb0041.fact_pre_invoice_deductions pre 
    ON s.customer_code = pre.customer_code
   AND s.fiscal_year = pre.fiscal_year
JOIN gdb0041.dim_customer c 
    ON s.customer_code = c.customer_code;
    
    
-- This view calculates net invoice sales and post-invoice discount percentage using pre-invoice sales data.

DROP VIEW IF EXISTS gdb0041.sales_post_inv_discount;

CREATE VIEW gdb0041.sales_post_inv_discount AS
SELECT 
    s.calendar_date AS calendar_date,
    s.fiscal_year AS fiscal_year,
    s.prod_code AS prod_code,
    s.product AS product,
    s.cust_code AS cust_code,
    s.customer AS customer,
    s.market AS market,
    s.variant AS variant,
    s.sold_quantity AS sold_quantity,
    s.gross_price_per_unit AS gross_price_per_unit,
    s.total_gross_sales AS total_gross_sales,
    s.pre_invoice_discount_pct AS pre_invoice_discount_pct,
    po.discounts_pct AS discounts_pct,
    po.other_deductions_pct AS other_deductions_pct,
    ROUND((1 - s.pre_invoice_discount_pct) * s.total_gross_sales, 2) 
        AS net_invoice_sales,
    (po.discounts_pct + po.other_deductions_pct) 
        AS post_invoice_discount_pct
FROM gdb0041.sales_pre_inv_discount s
JOIN gdb0041.fact_post_invoice_deductions po
    ON s.prod_code = po.product_code
   AND s.cust_code = po.customer_code
   AND s.calendar_date = po.date;


-- This view calculates final net sales after applying both pre-invoice and post-invoice discounts.

DROP VIEW IF EXISTS gdb0041.net_sales;

CREATE VIEW gdb0041.net_sales AS
SELECT 
    s.calendar_date AS calendar_date,
    s.fiscal_year AS fiscal_year,
    s.prod_code AS prod_code,
    s.product AS product,
    s.cust_code AS cust_code,
    s.customer AS customer,
    s.market AS market,
    s.variant AS variant,
    s.sold_quantity AS sold_quantity,
    s.gross_price_per_unit AS gross_price_per_unit,
    s.total_gross_sales AS total_gross_sales,
    s.pre_invoice_discount_pct AS pre_invoice_discount_pct,
    s.discounts_pct AS discounts_pct,
    s.other_deductions_pct AS other_deductions_pct,
    s.net_invoice_sales AS net_invoice_sales,
    s.post_invoice_discount_pct AS post_invoice_discount_pct,
    ROUND((1 - s.post_invoice_discount_pct) * s.net_invoice_sales, 2) 
        AS net_sales
FROM gdb0041.sales_post_inv_discount s;


-- Top 5 Markets
WITH market_sales AS (
    SELECT  
        market,
        ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
    FROM gdb0041.net_sales
    WHERE fiscal_year = 2021
    GROUP BY market
)

SELECT
    RANK() OVER (ORDER BY net_sales_mln DESC) AS rnk,
    market,
    net_sales_mln
FROM market_sales
ORDER BY net_sales_mln DESC
LIMIT 5;


-- Top 5 Customers

WITH customer_sales AS (
    SELECT  
        customer,
        ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
    FROM gdb0041.net_sales
    WHERE fiscal_year = 2021
    GROUP BY customer
)

SELECT
    RANK() OVER (ORDER BY net_sales_mln DESC) AS rnk,
    customer,
    net_sales_mln
FROM customer_sales
ORDER BY net_sales_mln DESC
LIMIT 5;

-- Top 5 Products

WITH product_sales AS (
    SELECT  
        product,
        ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
    FROM gdb0041.net_sales
    WHERE fiscal_year = 2021
    GROUP BY product
)

SELECT
    RANK() OVER (ORDER BY net_sales_mln DESC) AS rnk,
    product,
    net_sales_mln
FROM product_sales
ORDER BY net_sales_mln DESC
LIMIT 5;


/* ============================================================
   2) Net Sales % Share – Global (Top 10 Markets)
   ============================================================

   As a Product Owner, I want a bar chart report for a given
   financial year (e.g., FY2021) showing the top 10 markets
   by % net sales contribution globally.

   Requirements:
   - Calculate net sales % share for each market.
   - Rank markets by % contribution.
   - Return top 10 markets.
   - Make it reusable for any financial year.
   ============================================================ */
   
WITH cte1 AS (
    SELECT  
        customer,
        ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
    FROM gdb0041.net_sales n
    WHERE fiscal_year = 2021
    GROUP BY customer
    ORDER BY net_sales_mln DESC
)
SELECT *,
       net_sales_mln * 100 / SUM(net_sales_mln) OVER() AS contri_pct
FROM cte1;


/* ============================================================
   3) Net Sales % Share by Region
   ============================================================

   As a Product Owner, I want region-wise (APAC, EU, LATAM, NA, etc.)
   % net sales breakdown by customers within each region for a
   given financial year.

   Requirements:
   - Show % net sales contribution by customers per region.
   - Enable regional financial performance analysis.
   - Structure output suitable for visualization (bar charts).
   - Reusable for any financial year.
   ============================================================ */
   
WITH cte1 AS (
    SELECT  
        c.region,
        c.customer,
        ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
    FROM gdb0041.net_sales n
    JOIN dim_customer c
        ON n.customer_code = c.customer_code
    WHERE fiscal_year = 2021
    GROUP BY c.customer, c.region
    ORDER BY net_sales_mln DESC
)
SELECT *,
       net_sales_mln * 100 / SUM(net_sales_mln) OVER(PARTITION BY region) AS contri_pct_reg
FROM cte1
ORDER BY contri_pct_reg DESC;


/* ============================================================
   4) Top N Products in Each Division by Quantity Sold
   ============================================================

   Write a stored procedure to retrieve top N products in each
   division based on total quantity sold for a given financial year.

   Parameters:
   - Financial Year
   - N (Top count)

   Output:
   - Division
   - Product
   - Total Quantity Sold
   - Rank (within division)

   Note:
   - Use ranking logic partitioned by division.
   - Reusable for any financial year.
   ============================================================ */
   
WITH cte1 AS (
    SELECT  
        p.division,
        p.product,
        SUM(s.sold_quantity) AS total_qty
    FROM gdb0041.fact_sales_monthly s
    JOIN gdb0041.dim_product p
        ON p.product_code = s.product_code
    WHERE fiscal_year = 2021
    GROUP BY p.product
),
cte2 AS (
    SELECT *,
           DENSE_RANK() OVER(PARTITION BY division ORDER BY total_qty DESC) AS drnk
    FROM cte1
)
SELECT *
FROM cte2
WHERE drnk <= 3;


/* ============================================================
   5) Top 2 Markets in Every Region by Gross Sales
   ============================================================

   Retrieve the top 2 markets in each region based on gross sales
   amount for a given financial year (e.g., FY2021).

   Output:
   - Market
   - Region
   - Gross Sales (in millions)
   - Rank (within region)

   Note:
   - Ranking must be region-wise.
   - Limit to top 2 per region.
   ============================================================ */
   
WITH cte1 AS (
    SELECT  
        market,
        region,
        ROUND(SUM(gross_price_mln) / 1000000, 2) AS total_gross_price_mln
    FROM gdb0041.gross_sales
    WHERE fiscal_year = 2021
    GROUP BY market
),
cte2 AS (
    SELECT *,
           DENSE_RANK() OVER(PARTITION BY region ORDER BY total_gross_price_mln DESC) AS drnk
    FROM cte1
)
SELECT *
FROM cte2
WHERE drnk < 3;
