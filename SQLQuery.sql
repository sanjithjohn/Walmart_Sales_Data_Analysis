------------------------------------WALMART SALES ANALYSIS------------------------------------------------
-- Table Columns Preview

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'WalmartSalesData#csv$'


-- Table Preview

SELECT * FROM  WalmartSalesData#csv$


-- Checking for empty cells

SELECT 
    COLUMN_NAME,
    CASE 
        WHEN EXISTS (SELECT 1 FROM WalmartSalesData#csv$ WHERE COLUMN_NAME IS NULL) THEN 'Has NULL'
        ELSE 'No NULL'
    END AS NullCheck
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'walmartsalesdata#csv$';


-- No null values in any columns

--Number of Rows
SELECT COUNT(*) FROM WalmartSalesData#csv$


--Backingup the table 

SELECT * 
INTO backup_table 
FROM WalmartSalesData#csv$;

--Adding Day Column

ALTER TABLE WalmartSalesData#csv$
ADD  Day_Name VARCHAR(50)

UPDATE WalmartSalesData#csv$
SET
 Day_Name = DATENAME(WEEKDAY, DATE)  


-- Adding Month Column

Alter TABLE WalmartSalesData#csv$
Add month varchar(10)

Update WalmartSalesData#csv$
SET month = DATENAME(MONTH,Date)




 --Correcting the Date and Time formats

 UPDATE WalmartSalesData#csv$
SET Time = FORMAT(Time, 'HH:MM:SS')

 

-- Adding day time(morning, afternoon,evening)

ALTER TABLE WalmartSalesData#csv$
ADD Day_Time varchar(20)

UPDATE WalmartSalesData#csv$
SET Time = CONVERT(time,TIME)


UPDATE WalmartSalesData#csv$
SET Day_Time = 
CASE WHEN Time > '6:00:00' AND Time < '12:00:00' THEN 'MORNING'
	 WHEN Time >  '12:00:01' AND Time < '18:00:00' THEN 'AFTERNOON'
	 ELSE 'EVENING'
END


-----------------GENERIC QUESTIONS-----------------------------
---------------------------------------------------------------

--1) How many unique cities does the data have?

SELECT COUNT (DISTINCT City) FROM WalmartSalesData#csv$

--2) In which city is each branch?

SELECT  DISTINCT branch, city from WalmartSalesData#csv$


---------------PRODUCT-----------------------------------------
---------------------------------------------------------------


--1) How many unique product lines does the data have?

SELECT COUNT(DISTINCT [Product line]) FROM WalmartSalesData#csv$

--2) What is the most common payment method?

SELECT TOP 1 Payment, paymentm FROM
( SELECT Payment,  COUNT (Payment) as paymentm FROM WalmartSalesData#csv$
	GROUP BY Payment) AS subquery
ORDER BY paymentm DESC 

--3) What is the most selling product line?

SELECT TOP 1 [Product line], COUNTP FROM 
	(SELECT [Product line], COUNT(*) AS COUNTP FROM WalmartSalesData#csv$
	GROUP BY [Product line]) AS subquery
ORDER BY COUNTP DESC

--4) What is the total revenue by month?

SELECT MONTH, SUM([gross income]) AS [Income Per Month] FROM WalmartSalesData#csv$
GROUP BY MONTH


--5) What month had the largest COGS?

SELECT TOP 1 MONTH, [CGS PER MONTH] FROM
	(SELECT MONTH, SUM(COGS) AS [CGS PER MONTH] FROM WalmartSalesData#csv$
	GROUP BY MONTH ) AS subquery
ORDER BY [CGS PER MONTH] DESC

--6) What product line had the largest revenue?

SELECT TOP 1 [Product line], REVENUE_PER_PRODUCT_LINE FROM 
(SELECT [Product line], SUM([gross income]) AS REVENUE_PER_PRODUCT_LINE FROM WalmartSalesData#csv$
	GROUP BY [Product line]) AS subquery
ORDER BY REVENUE_PER_PRODUCT_LINE DESC

--7) What is the city with the largest revenue?

SELECT TOP 1 CITY , REVENUE FROM 
	(SELECT CITY, SUM([Gross Income]) as REVENUE FROM WalmartSalesData#csv$
	GROUP BY City) AS subquery
ORDER BY REVENUE DESC


--8) What product line had the largest VAT?

SELECT TOP 1 [product line] , VAT FROM WalmartSalesData#csv$
ORDER BY VAT DESC

--9) Fetch each product line and add a column to those 
--product line showing "Good", "Bad". Good if its greater than average sales


 SELECT [product line] ,
   CASE WHEN total < (SELECT AVG([Total Sales]) FROM WalmartSalesData#csv$)
				THEN 'BAD'
	ELSE 'GOOD'
	END
   AS GoodOrBad
  FROM WalmartSalesData#csv$



--10) Which branch sold more products than average product sold?

SELECT branch , avg(quantity) AS AvgSales FROM WalmartSalesData#csv$
GROUP BY Branch HAVING avg(quantity) > (SELECT AVG(quantity) FROM WalmartSalesData#csv$)


--11) What is the most common product line by gender?

SELECT
    Gender,
    [Product line],
    total_cnt
FROM 
 (
    SELECT
        Gender,
        [Product line],
        COUNT(gender) AS total_cnt,
        ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY COUNT(gender) DESC) AS RowNum
    FROM WalmartSalesData#csv$
    GROUP BY Gender, [Product line]
 )AS subquery
WHERE RowNum = 1

--12) What is the average rating of each product line?

SELECT [product line], round(AVG(Rating),2)  as ratings FROM WalmartSalesData#csv$
GROUP BY [Product line]
ORDER BY AVG(Rating) DESC




-----------------SALES-------------------------------------
-----------------------------------------------------------


-- 1)  What are the sales done in each time of the day in each weekdays

SELECT Day_Name, Day_time, SUM(quantity) AS SALES FROM WalmartSalesData#csv$
GROUP BY Day_Name, Day_Time HAVING Day_Name NOT IN ('sunday','saturday')
ORDER BY Day_Name, Day_Time ASC

--2) Which of the customer types brings the most revenue?

SELECT TOP 1 [CUSTOMER TYPE] , SUM([total sales]) FROM WalmartSalesData#csv$
GROUP BY [Customer type]

--3) Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT TOP 1 City , SUM(VAT) FROM WalmartSalesData#csv$
GROUP BY City 

--4) Which customer type pays the most in VAT?

SELECT TOP 1 [CUSTOMER TYPE] , SUM(VAT) FROM WalmartSalesData#csv$
GROUP BY [Customer type]



-----------------CUSTOMER---------------------------------- 
-----------------------------------------------------------

  SELECT * FROM  WalmartSalesData#csv$


--1) What are the unique customer types that the data have?

SELECT DISTINCT [customer type] FROM WalmartSalesData#csv$ 

--2) What are the various payment methods?

SELECT DISTINCT Payment FROM WalmartSalesData#csv$ 

--3) What is the most common customer type?

SELECT TOP 1 [customer type] AS [MOST COMMON CUSTOMER TYPE]  FROM WalmartSalesData#csv$
GROUP BY [Customer type]
ORDER BY COUNT(*) DESC

--4) Which customer type buys the most?

SELECT TOP 1 [customer type] AS [CUSTOMER TYPE BUYING THE MOST]  FROM WalmartSalesData#csv$
GROUP BY [Customer type]
ORDER BY SUM(quantity) DESC

--5) What is the gender of most of the customers?

SELECT TOP 1 Gender AS [MOST COMMON CUSTOMER GENDER]  FROM WalmartSalesData#csv$
GROUP BY Gender
ORDER BY COUNT(Gender)

--6) What is the gender distribution per branch?

SELECT BRANCH, GENDER, gender_cnt FROM
	(SELECT *, ROW_NUMBER() OVER (partition by Branch ORDER BY gender_cnt DESC) as RowNumber FROM
		(SELECT Branch, gender , COUNT(*)as Gender_Cnt FROM WalmartSalesData#csv$
		GROUP BY Branch, gender
		) AS subquery
	) AS subquery1
WHERE RowNumber = 1


--7) Which time of the day do customers give most ratings?

SELECT TOP 1 day_time FROM WalmartSalesData#csv$
GROUP BY Day_Time
ORDER BY COUNT(Rating)

--8) Which time of the day do customers give most ratings per branch?

SELECT * FROM
	(SELECT BRANCH, day_time, COUNT(Rating) AS NoOfRATINGS, 
	ROW_NUMBER() OVER (Partition BY branch ORDER BY COUNT(Rating) DESC) AS RowNumber
	FROM WalmartSalesData#csv$
	GROUP BY Branch , Day_Time
	) AS subquery
WHERE RowNumber = 1

--9) Which day of the week has the best avg ratings?

SELECT TOP 1 day_name , AVG(rating) FROM WalmartSalesData#csv$
GROUP BY Day_Name
ORDER BY AVG(rating) DESC

--10) Which day of the week has the best average ratings per branch?

SELECT BRANCH, day_name, avgrating FROM
	(SELECT Branch,day_name, AVG(rating) AS AvgRating, 
	ROW_NUMBER() OVER ( PARTITION BY branch Order BY AVG(rating) DESC) AS RowNumber
	FROM WalmartSalesData#csv$
	GROUP BY branch, Day_Name
	) AS subquery
WHERE RowNumber = 1


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--
---------------------------------------------------------------------------------------
