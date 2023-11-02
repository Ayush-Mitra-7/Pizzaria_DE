-- TOTAL NUMBER OF PIZZAS SOLD --
CREATE OR REPLACE VIEW Total_FoodItems_Sold AS
SELECT
    SUM(DOD.D_Quantity) AS Total_Drinks_Sold,
    SUM(SOD.S_Quantity) AS Total_Side_Dishes_Sold,
    SUM(POD.P_Quantity) AS Total_Pizzas_Sold
FROM Drink_Order_Details DOD
LEFT JOIN Sides_Order_Details SOD ON DOD.Order_ID = SOD.Order_ID
LEFT JOIN Pizza_Order_Details POD ON DOD.Order_ID = POD.Order_ID;
-- TOTAL NUMBER OF PIZZAS SOLD --

-- AVERAGE ORDER COST --
CREATE OR REPLACE VIEW Average_Order_Cost AS
SELECT ROUND(AVG(Total_Price), 2) AS Average_Order_Value
FROM Transaction_Order_Details;
-- AVERAGE ORDER COST --

-- Total Revenue --
CREATE OR REPLACE VIEW Total_Revenue AS
SELECT SUM(Total_Price) AS Total_Revenue
FROM Transaction_Order_Details;
-- Total Revenue --

--Cities By Revenue --
CREATE OR REPLACE VIEW City_Wise_Revenue AS
SELECT city, Revenue
FROM (
    SELECT
        city,
        Revenue,
        ROWNUM AS rn
    FROM (
        SELECT
            SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS city,
            ROUND(SUM(tod.Final_Price),2) AS Revenue
        FROM Customer_Details cd
        JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
        WHERE cd.Address LIKE '%-%'
        GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1))
        ORDER BY Revenue DESC
    );
-- Cities By Revenue --

-- Food Item wise Revenue --
CREATE OR REPLACE VIEW Food_Titemwise_Revenue AS
SELECT
    ROUND(SUM(TOD.Total_Price), 2) AS Total_Revenue,
    ROUND(SUM(CASE WHEN PIZZA.Pizza_ID IS NOT NULL THEN TOD.Total_Price ELSE 0 END), 2) AS Pizza_Revenue,
    ROUND(SUM(CASE WHEN DRINKS.Drink_ID IS NOT NULL THEN TOD.Total_Price ELSE 0 END), 2) AS Drink_Revenue,
    ROUND(SUM(CASE WHEN SIDES.Sides_ID IS NOT NULL THEN TOD.Total_Price ELSE 0 END), 2) AS Sides_Revenue
FROM Transaction_Order_Details TOD
LEFT JOIN Pizza_Order_Details PIZZA ON TOD.Order_ID = PIZZA.Order_ID
LEFT JOIN Drink_Order_Details DRINKS ON TOD.Order_ID = DRINKS.Order_ID
LEFT JOIN Sides_Order_Details SIDES ON TOD.Order_ID = SIDES.Order_ID;
-- Food Item wise Revenue --


-- Total Pizza Revenue --
CREATE OR REPLACE VIEW Total_Pizza_Revenue AS
SELECT (SUM(po.Total_Price)/2) AS TotalPizzaRevenue
FROM Pizza_Order_Details po
JOIN Pizza_Details pd ON po.Pizza_ID = pd.Pizza_ID;
-- Total Pizza Revenue --

-- VEG and NON Veg PIZZA Sold --
CREATE OR REPLACE VIEW Veg_Nonveg_Pizza_Sold AS
SELECT
    SUM(CASE WHEN pd.Is_Veg = 1 THEN pod.P_Quantity ELSE 0 END) AS Total_Veg_Pizzas_Sold,
    SUM(CASE WHEN pd.Is_Veg = 0 THEN pod.P_Quantity ELSE 0 END) AS Total_NonVeg_Pizzas_Sold
FROM Pizza_Order_Details pod
JOIN Pizza_Details pd ON pod.Pizza_ID = pd.Pizza_ID;
-- VEG and NON Veg PIZZA Sold --

-- Qauterly Sales --
CREATE OR REPLACE VIEW Quaterly_Sales AS
SELECT
    TO_CHAR(Transaction_Date, 'YYYY') AS Year,
    'Q' || TO_CHAR(Transaction_Date, 'Q') AS Quarter,
    COUNT(Order_ID) AS OrderCount
FROM Transaction_Order_Details
GROUP BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'Q')
ORDER BY Year, Quarter;
-- Qauterly Sales --


-- Top 10 Pizza by sales --
CREATE OR REPLACE VIEW Top_10_Pizza_Sales AS
SELECT * 
FROM (
    SELECT pd.Name AS Pizza_Name, COUNT(po.Pizza_ID) AS OrderCount
    FROM Pizza_Details pd
    JOIN Pizza_Order_Details po ON pd.Pizza_ID = po.Pizza_ID
    GROUP BY pd.Name
    ORDER BY OrderCount DESC
) 
WHERE ROWNUM <=10;
-- Top 10 Pizza by sales --


-- Top 10 Drinks by sales --
CREATE OR REPLACE VIEW Top_10_Drinks_Sales AS
SELECT * 
FROM (
    SELECT dd.Name AS Drink_Name, COUNT(do.Drink_ID) AS OrderCount
    FROM Drink_Details dd
    JOIN Drink_Order_Details do ON dd.Drink_ID = do.Drink_ID
    GROUP BY dd.Name
    ORDER BY OrderCount DESC
) 
WHERE ROWNUM <= 10;
-- Top 10 Drinks by sales --



-- Top 10 Sides by sales --
CREATE OR REPLACE VIEW Top_10_Sides_Sales AS
SELECT * 
FROM (
    SELECT sd.Name AS Sides_Name, COUNT(so.Sides_ID) AS OrderCount
    FROM Sides_Details sd
    JOIN Sides_Order_Details so ON sd.Sides_ID = so.Sides_ID
    GROUP BY sd.Name
    ORDER BY OrderCount DESC
) 
WHERE ROWNUM <= 10;
-- Top 10 Sides by sales --


-- VEG and NON Veg Sides Sold --
CREATE OR REPLACE VIEW Veg_Nonveg_Sides_Sold AS
SELECT
    SUM(CASE WHEN sd.Is_Veg = 1 THEN sod.S_Quantity ELSE 0 END) AS Total_Veg_Sides_Sold,
    SUM(CASE WHEN sd.Is_Veg = 0 THEN sod.S_Quantity ELSE 0 END) AS Total_NonVeg_Sides_Sold
FROM Sides_Order_Details sod
JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID;
-- VEG and NON Veg Sides Sold --


-- Average Orders Permonth --
CREATE OR REPLACE VIEW Average_Orders_Permonth AS
SELECT AvgOrdersPerMonth
FROM (
    SELECT
        TO_CHAR(Transaction_Date, 'YYYY-MM') AS Month,
        COUNT(Order_ID) AS TotalOrders,
        AVG(COUNT(Order_ID)) OVER () AS AvgOrdersPerMonth
    FROM Transaction_Order_Details
    GROUP BY TO_CHAR(Transaction_Date, 'YYYY-MM')
    ORDER BY Month
)
WHERE ROWNUM = 1;
-- Average Orders Permonth --

-- Quarterly Returning Customers --
CREATE OR REPLACE VIEW Quarterly_Returning_Customer AS
WITH CustomerQuarters AS (
    SELECT
        TO_CHAR(TO_DATE(Transaction_Date, 'DD-MM-YYYY'), 'YYYY') AS Year,
        TO_CHAR(TO_DATE(Transaction_Date, 'DD-MM-YYYY'), 'Q') AS Quarter,
        Customer_ID
    FROM Transaction_Order_Details
)
, ReturningCustomers AS (
    SELECT
        Year,
        Quarter,
        Customer_ID
    FROM CustomerQuarters
    GROUP BY Year, Quarter, Customer_ID
    HAVING COUNT(*) > 1
)
SELECT
    '20'||TO_NUMBER(Year) AS Year,
    'Q' || Quarter AS Quarter,
    COUNT(*) AS ReturningCustomers
FROM ReturningCustomers
GROUP BY Year, Quarter
ORDER BY Year, Quarter;
-- Quarterly Returning Customers --



-- Create a view to display both CustomerCount and CustomerCountOrdered for each city --
CREATE OR REPLACE VIEW T_cust_City_Combined AS
SELECT
    COALESCE(CityCount.City, CityCountOrdered.City) AS City,
    COALESCE(CustomerCount, 0) AS CustomerCount,
    COALESCE(CustomerCountOrdered, 0) AS CustomerCountOrdered
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        COUNT(DISTINCT cd.Customer_ID) AS CustomerCount
    FROM Customer_Details cd
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
) CityCount
FULL JOIN (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        ROUND(COUNT(DISTINCT cd.Customer_ID) / 2.31) AS CustomerCountOrdered
    FROM Customer_Details cd
    INNER JOIN Transaction_Order_Details t ON cd.Customer_ID = t.Customer_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
    HAVING COUNT(DISTINCT cd.Customer_ID) >= 1
) CityCountOrdered
ON CityCount.City = CityCountOrdered.City;
-- Create a view to display both CustomerCount and CustomerCountOrdered for each city --

-- Top 10 Customer based on Revenue --
CREATE OR REPLACE VIEW Top_10_Cust_Rev AS
SELECT CustomerName, TotalSpending
FROM (
    SELECT First_Name || ' ' || Last_Name AS CustomerName, Round(SUM(Final_Price)/100) AS TotalSpending
    FROM Customer_Details c
    INNER JOIN Transaction_Order_Details t ON c.Customer_ID = t.Customer_ID
    GROUP BY First_Name, Last_Name
    ORDER BY TotalSpending DESC
)
WHERE ROWNUM <= 10;
-- Top 10 Customer based on Revenue --

-- Type of Payment --
CREATE OR REPLACE VIEW Type_of_payment AS
SELECT
    CASE
        WHEN Mode_of_Transaction = 'NB' THEN 'Net Banking'
        ELSE Mode_of_Transaction
    END AS TransactionMode,
    COUNT(*) AS OrderCount
FROM Transaction_Order_Details
GROUP BY
    CASE
        WHEN Mode_of_Transaction = 'NB' THEN 'Net Banking'
        ELSE Mode_of_Transaction
    END;
-- Type of Payment --

-- Customer Type City wise --
CREATE OR REPLACE VIEW Type_of_customer_city AS
SELECT
    City,
    CASE
        WHEN SUM(CustomerCountOrdered)/12 >= 5 THEN 'Loyal'
        WHEN SUM(CustomerCountOrdered)/5 >= 2 THEN 'Regular'
        ELSE 'Casual'
    END AS CustomerCategory,
    SUM(CustomerCountOrdered) AS CustomerCount
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        COUNT(DISTINCT cd.Customer_ID) AS CustomerCountOrdered
    FROM Customer_Details cd
    INNER JOIN Transaction_Order_Details t ON cd.Customer_ID = t.Customer_ID
    GROUP BY
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
) Subquery
GROUP BY City;
-- Customer Type City wise --



-- Total Customer --
CREATE OR REPLACE VIEW Total_Cust AS
SELECT COUNT(*) AS TotalCustomers
FROM Customer_Details;
-- Total Customer --


-- New Customer --
CREATE OR REPLACE VIEW New_Cust AS
SELECT Round(COUNT(*)/6) AS TotalCustomers
FROM Customer_Details;
-- New Customer --


-- Pizza Price Range --
CREATE OR REPLACE VIEW Pizza_price_range AS
SELECT 
    CASE
        WHEN price BETWEEN 100 AND 400 THEN '100-400'
        WHEN price BETWEEN 401 AND 800 THEN '401-800'
        WHEN price BETWEEN 801 AND 1200  THEN '801-1200'
        ELSE '1200+'
    END AS PriceRange, COUNT(*) AS PizzaCount
FROM Pizza_Details
GROUP BY 
    CASE
        WHEN price BETWEEN 100 AND 400 THEN '100-400'
        WHEN price BETWEEN 401 AND 800 THEN '401-800'
        WHEN price BETWEEN 801 AND 1200  THEN '801-1200'
        ELSE '1200+'
    END;
-- Pizza Price Range --

-- Pizza Price Range Orders --
CREATE OR REPLACE VIEW Pizza_order_price_range AS
SELECT 
    CASE
        WHEN p.price BETWEEN 100 AND 400 THEN '100-400'
        WHEN p.price BETWEEN 401 AND 800 THEN '401-800'
        WHEN p.price BETWEEN 801 AND 1200  THEN '801-1200'
        ELSE '1200+'
    END AS PriceRange,
    COUNT(po.Pizza_ID) AS PizzaOrderCount
FROM Pizza_Details p
LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
GROUP BY 
    CASE
        WHEN p.price BETWEEN 100 AND 400 THEN '100-400'
        WHEN p.price BETWEEN 401 AND 800 THEN '401-800'
        WHEN p.price BETWEEN 801 AND 1200  THEN '801-1200'
        ELSE '1200+'
    END;
-- Pizza Price Range Orders -- 


-- Pizza based on Profit -- 
CREATE OR REPLACE VIEW Top_10_pizza_profit AS
WITH PizzaOrderCounts AS (
    SELECT
        p.Pizza_ID,
        p.Name AS Pizza_Name,
        p.base_price AS Base_Price,
        p.Price,
        COUNT(po.Pizza_ID) AS OrderCount
    FROM Pizza_Details p
    INNER JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
    GROUP BY p.Pizza_ID, p.Name, p.base_price, p.Price
    ORDER BY COUNT(po.Pizza_ID) DESC
)
SELECT
    Pizza_Name,
    Base_Price,
    Price,
    Price - Base_Price AS ProfitMargin,
    ROUND((Price - Base_Price) / Price * 100,2) AS ProfitPercentage
FROM PizzaOrderCounts
WHERE ROWNUM <= 10;
-- Pizza based on Profit -- 


-- Top 10 Toppings Used in Pizza --
CREATE OR REPLACE VIEW Top_10_Toppings AS
SELECT ToppingName, ToppingCount
FROM (
    SELECT ToppingName, ToppingCount
    FROM (
        SELECT t.Name AS ToppingName, COUNT(*) AS ToppingCount
        FROM Pizza_Details p
        INNER JOIN Topping_Details t ON p.Topping_1_ID = t.Toppings_ID
           OR p.Topping_2_ID = t.Toppings_ID
           OR p.Topping_3_ID = t.Toppings_ID
           OR p.Topping_4_ID = t.Toppings_ID
        GROUP BY t.Name
        ORDER BY COUNT(*) DESC
    ) subquery
    WHERE ROWNUM <= 10
);
-- Top 10 Toppings Used in Pizza --


-- Pizza Bake Prefences --
CREATE OR REPLACE VIEW Bake_Prefeneces AS
SELECT b.Name AS BakeName, COUNT(po.Pizza_ID) AS PizzaCount
FROM Bake_Details b
LEFT JOIN Pizza_Details p ON b.Bake_ID = p.Bake_ID
LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
GROUP BY b.Name;
-- Pizza Bake Prefences --

-- Pizza Crust Prefences --
CREATE OR REPLACE VIEW Crust_Preferences AS
SELECT c.Name AS CrustName, COUNT(po.Pizza_ID) AS PizzaCount
FROM Crust_Details c
LEFT JOIN Pizza_Details p ON c.Crust_ID = p.Crust_ID
LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
GROUP BY c.Name;
-- Pizza Crust Prefences --

-- Pizza Size Prefences --
CREATE OR REPLACE VIEW Size_Preferences AS
SELECT s.Name AS SizeName, COUNT(po.Pizza_ID) AS PizzaCount
FROM Size_Details s
LEFT JOIN Pizza_Details p ON s.Size_ID = p.Size_ID
LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
GROUP BY s.Name;
-- Pizza Size Prefences --

-- Pizza Stats --
CREATE OR REPLACE VIEW AVG_PIZZA_stats AS
SELECT Round(AVG(base_price),2) AS Avg_BP, Round(AVG(price),2) AS AVG_P, Round(AVG(Price-base_price),2) AS Avg_pf, Round(AVG((price-base_price)/price*100),2)||'%' AS Avg_pm
FROM Pizza_Details;
-- Pizza Stats --