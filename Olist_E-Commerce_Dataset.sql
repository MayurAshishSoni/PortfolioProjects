--Firstly, Let's merge product category with product table and put data in new table called "final_products"
-- Using join function and INTO Statement


SELECT 
	   olist_products_dataset.product_id,
	   olist_products_dataset.product_category_name,
	   product_category_name_translation.product_category_name_english,
	   olist_products_dataset.product_name_lenght,
	   olist_products_dataset.product_description_lenght,
	   olist_products_dataset.product_photos_qty,
	   olist_products_dataset.product_weight_g,
	   olist_products_dataset.product_length_cm,
	   olist_products_dataset.product_height_cm,
	   olist_products_dataset.product_width_cm
INTO olist_final_products_dataset
From olist_products_dataset
LEFT JOIN 
	product_category_name_translation ON
		olist_products_dataset.product_category_name = product_category_name_translation.product_category_name;

--- Now Check if Customer data had "customer unique id" is really unique or not

SELECT customer_unique_id, COUNT(customer_unique_id) AS 'countcustomers'
FROM olist_customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(customer_unique_id) >1
ORDER BY COUNT(customer_unique_id) DESC;

---Yes there are duplicats in customer_unique_id
--- Now let's check if the customer have more than one state

SELECT customer_unique_id, COUNT(customer_state) AS NumnerofState
FROM olist_customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(customer_state) >1
ORDER BY COUNT(customer_state) DESC;

--- That means one customer have multiple state means we can not use query to count no of customer by state
--- Let's check oreder purchesed items

SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM olist_orders_dataset;

---The first and and last order dates are between Sep'16 to Oct'18
---Now let's check is there any gap in month in "order_purchase_timestamp"

SELECT YEAR(order_purchase_timestamp) AS YEARS,
	   MONTH(order_purchase_timestamp) AS MONTHS
FROM olist_orders_dataset
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp);

/***
we can see that there is no month of Nov'16
And here is the comment for it form kaggle (November/16 data is just missing because 
we were rolling out a new version of our platform. We had to pause the store for a few days to handle that change.)
***/

--- Assuming that Olist started in 2016, I would like to know the number of new customers increasing each year.

SELECT DISTINCT YEAR(order_purchase_timestamp) AS YEAR,
	   COUNT(DISTINCT customer_unique_id) AS Num_Customers
FROM olist_customers_dataset, olist_orders_dataset
WHERE olist_customers_dataset.customer_id = olist_orders_dataset.customer_id
GROUP BY YEAR(order_purchase_timestamp);

---Now check the growth of each year

SELECT YEAR,
		New_Customers,
		ISNULL(FORMAT((New_Customers)*1.00/LAG, 'P'),0) 'Growth%'
FROM(
	SELECT Year,
	   COUNT(CustID) AS New_Customers,
	   LAG(COUNT(CustID),1) OVER (ORDER BY Year) AS LAG
	FROM (
			SELECT  customer_unique_id AS CustID,
					YEAR(MIN(order_purchase_timestamp)) AS Year
			FROM olist_customers_dataset JOIN olist_orders_dataset
			ON olist_customers_dataset.customer_id = olist_orders_dataset.customer_id
			GROUP BY customer_unique_id) A
	GROUP BY year)B;

---Now Check Customers Reapting Rate

SELECT A.Year, C.Repeat_Customers,
		FORMAT(((C.Repeat_Customers*1.0)/A.NumOfCustomers),'p') As Repeat_Rate
FROM
	(SELECT  YEAR(order_purchase_timestamp) AS Year,
			COUNT(DISTINCT customer_unique_id) AS NumOfCustomers
		FROM olist_customers_dataset JOIN olist_orders_dataset
		ON olist_customers_dataset.customer_id = olist_orders_dataset.customer_id
		GROUP BY  YEAR(order_purchase_timestamp)) A
JOIN
	(SELECT Year,
			COUNT(DISTINCT customer_unique_id) AS Repeat_Customers 
	FROM(
			SELECT CASE ROW_NUMBER()
			OVER(PARTITION BY olist_customers_dataset.customer_unique_id
			ORDER BY olist_orders_dataset.order_purchase_timestamp)
			WHEN 1 THEN 'Total'
			ELSE 'Return'
			END AS customer_type,
			olist_customers_dataset.customer_unique_id,
			YEAR(order_purchase_timestamp) AS Year
			FROM olist_customers_dataset JOIN olist_orders_dataset
			ON olist_customers_dataset.customer_id = olist_orders_dataset.customer_id) B
			---ORDER BY customer_unique_id, order_purchase_timestamp) B
			WHERE customer_type = 'Return'
			GROUP BY Year, customer_type) C
			ON A.Year = C.Year;

--Let'S Check Top Sellers By review
--So that, Firstly check is there any null value in review column

SELECT *
FROM olist_order_reviews_dataset
WHERE review_score IS NULL;

--IS there any 0 review??

SELECT *
FROM olist_order_reviews_dataset
WHERE review_score = 0;

---There no 'NULL' or no 0 lineitems in data Amazing!!!
---Now let's check top 10 seller who got best reviews

SELECT TOP 10 olist_order_items_dataset.seller_id, 
				ROUND(AVG(olist_order_reviews_dataset.review_score),2) As AVG_Rating,
				COUNT(olist_order_reviews_dataset.review_score) AS TotalRatingCount
FROM olist_order_reviews_dataset JOIN olist_order_items_dataset
ON  olist_order_reviews_dataset.order_id = olist_order_items_dataset.order_id
GROUP BY seller_id
ORDER BY AVG_Rating DESC, TotalRatingCount DESC;

--Chaking Top Not so good sellers also

SELECT TOP 10 olist_order_items_dataset.seller_id, 
				ROUND(AVG(olist_order_reviews_dataset.review_score),2) As AVG_Rating,
				COUNT(olist_order_reviews_dataset.review_score) AS TotalRatingCount
FROM olist_order_reviews_dataset JOIN olist_order_items_dataset
ON  olist_order_reviews_dataset.order_id = olist_order_items_dataset.order_id
GROUP BY seller_id
ORDER BY AVG_Rating ASC, TotalRatingCount ASC;

---Top 10 product ID which got best review

SELECT TOP 10 olist_order_items_dataset.product_id, 
				ROUND(AVG(olist_order_reviews_dataset.review_score),2) As AVG_Rating,
				COUNT(olist_order_reviews_dataset.review_score) AS TotalRatingCount
FROM olist_order_reviews_dataset JOIN olist_order_items_dataset
ON  olist_order_reviews_dataset.order_id = olist_order_items_dataset.order_id
GROUP BY product_id
ORDER BY AVG_Rating DESC, TotalRatingCount DESC;

--And Bottom 10 Product ID Also

SELECT TOP 10 olist_order_items_dataset.product_id, 
				ROUND(AVG(olist_order_reviews_dataset.review_score),2) As AVG_Rating,
				COUNT(olist_order_reviews_dataset.review_score) AS TotalRatingCount
FROM olist_order_reviews_dataset JOIN olist_order_items_dataset
ON  olist_order_reviews_dataset.order_id = olist_order_items_dataset.order_id
GROUP BY product_id
ORDER BY AVG_Rating ASC, TotalRatingCount ASC;


---Now let's check top 10 product category whhich got best rating on Olist

SELECT TOP 10 olist_final_products_dataset.product_category_name_english AS Product_Category,
		AVG(AVG_Rating) AS AVG_Rating,
		SUM(TotalRatingCount) AS TotalRatingCount
FROM(SELECT olist_order_items_dataset.product_id, 
				ROUND(AVG(olist_order_reviews_dataset.review_score),2) As AVG_Rating,
				COUNT(olist_order_reviews_dataset.review_score) AS TotalRatingCount
FROM olist_order_reviews_dataset JOIN olist_order_items_dataset
ON  olist_order_reviews_dataset.order_id = olist_order_items_dataset.order_id
GROUP BY product_id) A JOIN olist_final_products_dataset
ON A.product_id = olist_final_products_dataset.product_id
GROUP BY olist_final_products_dataset.product_category_name_english
ORDER BY AVG_Rating DESC,TotalRatingCount DESC;

--There are Bottom category also on which Olsit need to improve 

SELECT TOP 10 olist_final_products_dataset.product_category_name_english AS Product_Category,
		AVG(AVG_Rating) AS AVG_Rating,
		SUM(TotalRatingCount) AS TotalRatingCount
FROM(SELECT olist_order_items_dataset.product_id, 
				ROUND(AVG(olist_order_reviews_dataset.review_score),2) As AVG_Rating,
				COUNT(olist_order_reviews_dataset.review_score) AS TotalRatingCount
FROM olist_order_reviews_dataset JOIN olist_order_items_dataset
ON  olist_order_reviews_dataset.order_id = olist_order_items_dataset.order_id
GROUP BY product_id) A JOIN olist_final_products_dataset
ON A.product_id = olist_final_products_dataset.product_id
GROUP BY olist_final_products_dataset.product_category_name_english
ORDER BY AVG_Rating ASC,TotalRatingCount ASC;

---Now Let's Check Populer Payment Type

SELECT payment_type,
		COUNT(order_id) AS PaymentsCount
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY PaymentsCount DESC;

--So there is cradit cards and boleto are top in payment type
---How much orders are on Installments

SELECT DISTINCT payment_installments AS NoOfInstallments,
		COUNT(order_id) NoOfOrders
FROM olist_order_payments_dataset
GROUP BY payment_installments
Order BY NoOfOrders DESC;

-- So By this, We can say that almost every order has atleat one installments
---Now Lets Check total revenu of the company by year

SELECT YEAR(olist_orders_dataset.order_purchase_timestamp) AS Year,
		ROUND(SUM(olist_order_items_dataset.price)+SUM(olist_order_items_dataset.freight_value),2) AS Total_Revenue
FROM olist_orders_dataset JOIN olist_order_items_dataset 
ON olist_orders_dataset.order_id = olist_order_items_dataset.order_id
WHERE order_status =  'delivered'
GROUP BY YEAR(olist_orders_dataset.order_purchase_timestamp)
ORDER BY Year;

--Now Let's Just Check % changes in Revenue by Month of year

SELECT Year,Month,Total_Revenue,
		ISNULL(FORMAT((Total_Revenue-previous_Revenue)/previous_Revenue,'P'),0) AS Growth
FROM
	(SELECT *,
		LAG(Total_Revenue,1) OVER (ORDER BY YEAR,Month) AS previous_Revenue
	FROM (
		SELECT YEAR(olist_orders_dataset.order_purchase_timestamp) AS Year,
			Month(olist_orders_dataset.order_purchase_timestamp) AS Month,
			ROUND(SUM(olist_order_items_dataset.price)+SUM(olist_order_items_dataset.freight_value),2) AS Total_Revenue
		FROM olist_orders_dataset JOIN olist_order_items_dataset 
		ON olist_orders_dataset.order_id = olist_order_items_dataset.order_id
		WHERE order_status =  'delivered'
		GROUP BY YEAR(olist_orders_dataset.order_purchase_timestamp),Month(olist_orders_dataset.order_purchase_timestamp))A)B;

---  Now let's check Top 3 sellers who got most revenue by year


SELECT *
FROM (
	SELECT YEAR(olist_orders_dataset.order_purchase_timestamp) AS Year, olist_order_items_dataset.seller_id,
		ROUND(SUM(olist_order_items_dataset.price)+SUM(olist_order_items_dataset.freight_value),2) AS Total_Revenue,
		RANK() OVER (
			PARTITION BY YEAR(olist_orders_dataset.order_purchase_timestamp) 
			ORDER BY ROUND(SUM(olist_order_items_dataset.price)+SUM(olist_order_items_dataset.freight_value),2) DESC) 
				AS value_rank
	FROM olist_orders_dataset JOIN olist_order_items_dataset 
	ON olist_orders_dataset.order_id = olist_order_items_dataset.order_id
	WHERE order_status =  'delivered'
	GROUP BY YEAR(olist_orders_dataset.order_purchase_timestamp), seller_id) A
	WHERE value_rank IN (1,2,3);
	
--- Chaking Bottem 3  Sellers Also

SELECT *
FROM (
	SELECT YEAR(olist_orders_dataset.order_purchase_timestamp) AS Year, olist_order_items_dataset.seller_id,
		ROUND(SUM(olist_order_items_dataset.price)+SUM(olist_order_items_dataset.freight_value),2) AS Total_Revenue,
		RANK() OVER (
			PARTITION BY YEAR(olist_orders_dataset.order_purchase_timestamp) 
			ORDER BY ROUND(SUM(olist_order_items_dataset.price)+SUM(olist_order_items_dataset.freight_value),2) ASC) 
				AS value_rank
	FROM olist_orders_dataset JOIN olist_order_items_dataset 
	ON olist_orders_dataset.order_id = olist_order_items_dataset.order_id
	WHERE order_status =  'delivered'
	GROUP BY YEAR(olist_orders_dataset.order_purchase_timestamp), seller_id) A
	WHERE value_rank IN (1,2,3);

-- Which product category Takes most time to Deliver

SELECT  olist_final_products_dataset.product_category_name_english,
		AVG(DATEDIFF(Day, order_purchase_timestamp, order_delivered_customer_date)) AS AvgDay
FROM olist_orders_dataset
JOIN olist_order_items_dataset
ON olist_orders_dataset.order_id = olist_order_items_dataset.order_id
JOIN olist_final_products_dataset
ON olist_order_items_dataset.product_id = olist_final_products_dataset.product_id
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY product_category_name_english
ORDER BY AvgDay DESC;

-- So we conclude that office_funiture take most time to deliver and arts_and_craftmanship take least amount of time to deliver 
--- Now check which product category made how much money in respactive years
 
SELECT *
FROM( 
SELECT product_category_name_english,
		YEAR(order_estimated_delivery_date) AS Year,
		ISNULL(ROUND(SUM(price)+SUM(freight_value),2),0) AS Total		
FROM olist_orders_dataset
JOIN olist_order_items_dataset
ON olist_orders_dataset.order_id = olist_order_items_dataset.order_id
JOIN olist_final_products_dataset
ON olist_order_items_dataset.product_id = olist_final_products_dataset.product_id
GROUP BY product_category_name_english,YEAR(order_estimated_delivery_date))A
PIVOT(
		SUM(Total)
		FOR Year IN(
		[2016],
		[2017],
		[2018])) AS pivot_table;

---This data is so much informative like
---1. There is so much null values in 2016 might because of lack of data of 2016
---2. There is 1 null in 2018 also which is seurity so we can say that there is no procuct was now avilable of securites  in 2018
---3. There is null value in product category also whaich gives pretty revenu to company

---That's All As of Now
--- Thank You So Much

