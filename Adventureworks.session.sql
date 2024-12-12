--Total Sales Amount
SELECT ROUND(SUM(salesterritory.salesytd),2) AS Total_Sales
FROM sales.salesterritory

--Sales by Region
SELECT ROUND(SUM(salesterritory.salesytd),2) AS Region_Sales, salesterritory.group
FROM sales.salesterritory
GROUP BY salesterritory.group

--Sales by year
SELECT
ROUND(SUM(totaldue),2) AS Sales,
DATE_PART('year', salesorderheader.modifieddate::date) AS year_sold
FROM sales.salesorderheader
GROUP BY year_sold
ORDER BY Sales DESC

-- Sales by store

-- Step 1: Join to match PersonID for each BuisnessEntityID
SELECT
s.businessentityid,
be.personid,
s.name,
s.salespersonid
FROM sales.store AS s
LEFT JOIN person.businessentitycontact AS be ON
s.businessentityid = be.businessentityid

-- Step 2: Join to match CustomerID for each PersonID
WITH id_table AS
(SELECT
s.businessentityid,
be.personid,
s.name,
s.salespersonid
FROM sales.store AS s
LEFT JOIN person.businessentitycontact AS be ON
s.businessentityid = be.businessentityid)

SELECT 
id_table.name,
cid.customerid
FROM id_table
LEFT JOIN sales.customer AS cid ON
id_table.personID = cid.personID


--Step 3: Join Sales Table using CustomerID to Find Sales by Store 
WITH sales_by_store AS 
(
    WITH id_table AS
    (SELECT
    s.businessentityid,
    be.personid,
    s.name,
    s.salespersonid
    FROM sales.store AS s
    LEFT JOIN person.businessentitycontact AS be ON
    s.businessentityid = be.businessentityid)

    SELECT 
    id_table.name,
    cid.customerid
    FROM id_table
    LEFT JOIN sales.customer AS cid ON
    id_table.personID = cid.personID
)

SELECT 
    sales_by_store.name,
    ROUND(SUM(salesorderheader.totaldue),2) AS tot_store_sales
FROM sales_by_store
INNER JOIN sales.salesorderheader ON
sales_by_store.customerID = salesorderheader.customerID
GROUP BY sales_by_store.name
ORDER BY tot_store_sales DESC

--Total Order Quantity
SELECT COUNT(DISTINCT salesorderdetail.salesorderdetailid) AS Total_Orders
FROM sales.salesorderdetail

--Total Number of Products
SELECT COUNT(DISTINCT product.productid) AS tot_products
FROM production.product


--Count of Products and Average Profit by Category
SELECT pro_cat.productcategoryID, 
pro_cat.name,
COUNT(pro_cat.productcategoryID) AS pro_cat_count,
ROUND(AVG(product.listprice),2) AS avg_list_price,
ROUND(AVG(product.standardcost),2) AS avg_cost,
ROUND(AVG(product.listprice),2)-ROUND(AVG(product.standardcost),2) as avg_profit
FROM production.product
INNER JOIN production.productsubcategory AS sub_cat ON --Inner Join so we can get rid of products with no listed category
product.productsubcategoryID = sub_cat.productsubcategoryID
INNER JOIN production.productcategory AS pro_cat ON
sub_cat.productcategoryID = pro_cat.productcategoryID
GROUP BY pro_cat.productcategoryID
ORDER BY avg_profit DESC, pro_cat_count DESC


--Count of Products and Average Profit by Subcategory
SELECT sub_cat.productsubcategoryID, 
sub_cat.name,
COUNT(sub_cat.productsubcategoryID) AS sub_cat_count, 
ROUND(AVG(product.listprice),2) AS avg_list_price,
ROUND(AVG(product.standardcost),2) AS avg_cost,
ROUND(AVG(product.listprice),2)-ROUND(AVG(product.standardcost),2) as avg_profit
FROM production.product
INNER JOIN production.productsubcategory AS sub_cat ON --Inner Join so we can get rid of products with no listed category
product.productsubcategoryID = sub_cat.productsubcategoryID
INNER JOIN production.productcategory AS pro_cat ON
sub_cat.productcategoryID = pro_cat.productcategoryID
GROUP BY sub_cat.productsubcategoryID
ORDER BY avg_profit DESC, sub_cat_count DESC








