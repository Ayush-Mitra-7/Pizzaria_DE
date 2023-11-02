SELECT
    TO_CHAR(Transaction_Date, 'YYYY') AS Year,
    TO_CHAR(Transaction_Date, 'MM') AS Month,
    TO_CHAR(SUM(Final_Price), 'FM999999999.99') AS Total_Revenue
FROM Transaction_Order_Details
GROUP BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM')
ORDER BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM');

-- # Revenue Total #--

SELECT
    TO_CHAR(Transaction_Date, 'YYYY') AS Year,
    TO_CHAR(Transaction_Date, 'MM') AS Month,
    SUM(CASE WHEN po.Pizza_ID IS NOT NULL THEN po.Total_Price ELSE 0 END) AS Revenue_of_Pizza
FROM Transaction_Order_Details tod
LEFT JOIN Pizza_Order_Details po ON tod.Order_ID = po.Order_ID
GROUP BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM')
ORDER BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM');
-- ## Revenue of Pizza ## --

SELECT
    TO_CHAR(Transaction_Date, 'YYYY') AS Year,
    TO_CHAR(Transaction_Date, 'MM') AS Month,
    SUM(CASE WHEN do.Drink_ID IS NOT NULL THEN do.Total_Price ELSE 0 END) AS Revenue_of_Drinks
FROM Transaction_Order_Details tod
LEFT JOIN Drink_Order_Details do ON tod.Order_ID = do.Order_ID
GROUP BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM')
ORDER BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM');
-- ## Revenue of Drinks ## --

SELECT
    TO_CHAR(Transaction_Date, 'YYYY') AS Year,
    TO_CHAR(Transaction_Date, 'MM') AS Month,
    SUM(CASE WHEN so.Sides_ID IS NOT NULL THEN so.Total_Price ELSE 0 END) AS Revenue_of_Sides
FROM Transaction_Order_Details tod
LEFT JOIN Sides_Order_Details so ON tod.Order_ID = so.Order_ID
GROUP BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM')
ORDER BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM');
-- ## Revenue of sides ## --

SELECT
    TO_CHAR(Transaction_Date, 'YYYY') AS Year,
    TO_CHAR(Transaction_Date, 'MM') AS Month,
    SUM(CASE WHEN co.Combo_ID IS NOT NULL THEN co.Total_Price ELSE 0 END) AS Revenue_of_Combo
FROM Transaction_Order_Details tod
LEFT JOIN Combo_Order_Details co ON tod.Order_ID = co.Order_ID
GROUP BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM')
ORDER BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'MM');
-- ## Revenue of combo ## --


SELECT * FROM (
    SELECT
        pd.Name AS Pizza_Name,
        SUM(pod.Total_Price) AS Revenue
    FROM Pizza_Order_Details pod
    JOIN Pizza_Details pd ON pod.Pizza_ID = pd.Pizza_ID
    GROUP BY pd.Name
    ORDER BY Revenue asc
)
WHERE ROWNUM <= 5;
-- ## Top 5 Pizza by revenue ## --

WITH PizzaRevenueRank AS (
    SELECT
        pd.Name AS Pizza_Name,
        TO_CHAR(tod.Transaction_Date, 'YYYY') AS Year,
        SUM(pod.Total_Price) AS Revenue,
        ROW_NUMBER() OVER (PARTITION BY TO_CHAR(tod.Transaction_Date, 'YYYY') ORDER BY SUM(pod.Total_Price) DESC) AS Pizza_Rank
    FROM Pizza_Order_Details pod
    JOIN Pizza_Details pd ON pod.Pizza_ID = pd.Pizza_ID
    JOIN Transaction_Order_Details tod ON pod.Order_ID = tod.Order_ID
    GROUP BY pd.Name, TO_CHAR(tod.Transaction_Date, 'YYYY')
)

SELECT Year, Pizza_Name, Revenue
FROM PizzaRevenueRank
WHERE Pizza_Rank <= 5;
-- ## Top 5 pizza by Revenue Year wise ## --

SELECT * FROM (
    SELECT
        pd.Name AS Pizza_Name,
        COUNT(pod.Order_ID) AS Total_Sales
    FROM Pizza_Order_Details pod
    JOIN Pizza_Details pd ON pod.Pizza_ID = pd.Pizza_ID
    GROUP BY pd.Name
    ORDER BY Total_Sales DESC
)
WHERE ROWNUM <= 5;
-- ## Top 5 Pizza by Total Sales ## --

SELECT * FROM (
    SELECT
        pd.Name AS Pizza_Name,
        COUNT(DISTINCT pod.Order_ID) AS Total_Orders
    FROM Pizza_Order_Details pod
    JOIN Pizza_Details pd ON pod.Pizza_ID = pd.Pizza_ID
    GROUP BY pd.Name
    ORDER BY Total_Orders DESC
)
WHERE ROWNUM <= 5;
-- ## Top 5 Pizza by Total orders ## --

SELECT city, Revenue
FROM (
    SELECT
        city,
        Revenue,
        ROWNUM AS rn
    FROM (
        SELECT
            SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS city,
            SUM(tod.Final_Price) AS Revenue
        FROM Customer_Details cd
        JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
        WHERE cd.Address LIKE '%-%'
        GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1))
        ORDER BY Revenue DESC
    )
WHERE ROWNUM <= 5;
-- ## Top Five city by Revenue ## --

SELECT
    City,
    TotalSales
FROM (
    SELECT
        City,
        TotalSales,
        ROWNUM AS rn
    FROM (
        SELECT
            SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
            COUNT(DISTINCT tod.Order_ID) AS TotalSales
        FROM Customer_Details cd
        JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
        WHERE cd.Address LIKE '%-%'
        GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1))
        ORDER BY TotalSales DESC
    )
WHERE rn <= 5;
-- ## Top % cities with total number of sales ## --

SELECT
    City,
    TotalOrders
FROM (
    SELECT
        City,
        TotalOrders,
        ROWNUM AS rn
    FROM (
        SELECT
            SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
            COUNT(DISTINCT tod.Order_ID) AS TotalOrders
        FROM Customer_Details cd
        JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
        WHERE cd.Address LIKE '%-%'
        GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1))
        ORDER BY TotalOrders DESC
    )
WHERE rn <= 5;
-- ## Top % cities with total number of orders ## --

SELECT SUM(Final_Price) AS Total_Revenue
FROM Transaction_Order_Details;
-- ## Total Revenue ## --

SELECT
    SUM(CASE WHEN pd.Is_Veg = 1 THEN pod.P_Quantity ELSE 0 END) AS Total_Veg_Pizzas_Sold,
    SUM(CASE WHEN pd.Is_Veg = 0 THEN pod.P_Quantity ELSE 0 END) AS Total_NonVeg_Pizzas_Sold
FROM Pizza_Order_Details pod
JOIN Pizza_Details pd ON pod.Pizza_ID = pd.Pizza_ID;
-- ## Total Number of veg and nonveg pizza sold ## --

SELECT
    SUM(DOD.D_Quantity) AS Total_Drinks_Sold,
    SUM(SOD.S_Quantity) AS Total_Side_Dishes_Sold,
    SUM(POD.P_Quantity) AS Total_Pizzas_Sold
FROM Drink_Order_Details DOD
LEFT JOIN Sides_Order_Details SOD ON DOD.Order_ID = SOD.Order_ID
LEFT JOIN Pizza_Order_Details POD ON DOD.Order_ID = POD.Order_ID;
-- ## Total Number of Drinks Sides and Pizza sold ## --


SELECT
    MAX(Final_Price) AS Min_Order_Value
FROM Transaction_Order_Details;


WITH MonthlyTransactionCounts AS (
    SELECT
        EXTRACT(YEAR FROM Transaction_Date) AS Year,
        EXTRACT(MONTH FROM Transaction_Date) AS Month,
        COUNT(Order_ID) AS Transactions
    FROM Transaction_Order_Details
    GROUP BY EXTRACT(YEAR FROM Transaction_Date), EXTRACT(MONTH FROM Transaction_Date)
)
SELECT
    Year,
    Month,
    AVG(Transactions) AS Avg_Transactions
FROM MonthlyTransactionCounts
GROUP BY Year, Month
ORDER BY Year, Month;

WITH YearlyTransactionCounts AS (
    SELECT
        EXTRACT(YEAR FROM Transaction_Date) AS Year,
        COUNT(Order_ID) AS Transactions
    FROM Transaction_Order_Details
    GROUP BY EXTRACT(YEAR FROM Transaction_Date)
)
SELECT
    Year,
    AVG(Transactions) AS Avg_Transactions
FROM YearlyTransactionCounts
GROUP BY Year
ORDER BY Year;

SELECT
    EXTRACT(YEAR FROM Transaction_Date) AS Year,
    SUM(Final_Price) AS Revenue
FROM Transaction_Order_Details
GROUP BY EXTRACT(YEAR FROM Transaction_Date)
ORDER BY Year;


SELECT City, Total_Pizzas_Sold
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        COUNT(pod.Pizza_ID) AS Total_Pizzas_Sold
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Pizza_Order_Details pod ON tod.Order_ID = pod.Order_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
    ORDER BY Total_Pizzas_Sold asc
)
WHERE ROWNUM <= 5;

SELECT
    SUM(D_Quantity) AS Total_Drinks_Sold
FROM Drink_Order_Details;


SELECT
    SUM(D_Quantity * Price) AS Total_Revenue_Drinks
FROM Drink_Order_Details
JOIN Drink_Details ON Drink_Order_Details.Drink_ID = Drink_Details.Drink_ID;



SELECT Drink_Name, Total_Revenue
FROM (
    SELECT
        dd.Name AS Drink_Name,
        SUM(dod.D_Quantity * dd.Price) AS Total_Revenue
    FROM Drink_Order_Details dod
    JOIN Drink_Details dd ON dod.Drink_ID = dd.Drink_ID
    GROUP BY dd.Name
    ORDER BY Total_Revenue asc
)
WHERE ROWNUM <= 5;


SELECT City, Total_Revenue_Drinks
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(dod.D_Quantity * dd.Price) AS Total_Revenue_Drinks
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Drink_Order_Details dod ON tod.Order_ID = dod.Order_ID
    JOIN Drink_Details dd ON dod.Drink_ID = dd.Drink_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
    ORDER BY Total_Revenue_Drinks DESC
)
WHERE ROWNUM <= 5;


SELECT
    SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
    SUM(dod.D_Quantity * dd.Price) AS Total_Revenue_Drinks
FROM Customer_Details cd
JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
JOIN Drink_Order_Details dod ON tod.Order_ID = dod.Order_ID
JOIN Drink_Details dd ON dod.Drink_ID = dd.Drink_ID
GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
ORDER BY Total_Revenue_Drinks DESC;


SELECT
    dd.Name AS Drink_Type,
    SUM(dod.D_Quantity) AS Total_Quantity_Sold
FROM Drink_Order_Details dod
JOIN Drink_Details dd ON dod.Drink_ID = dd.Drink_ID
GROUP BY dd.Name
ORDER BY Total_Quantity_Sold DESC;



SELECT City
FROM (
    SELECT
        City,
        Total_Spending_Drinks,
        Total_Spending_Sides
    FROM (
        SELECT
            SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
            SUM(dod.D_Quantity * dd.Price) AS Total_Spending_Drinks,
            SUM(sod.S_Quantity * sd.Price) AS Total_Spending_Sides
        FROM Customer_Details cd
        JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
        JOIN Drink_Order_Details dod ON tod.Order_ID = dod.Order_ID
        JOIN Drink_Details dd ON dod.Drink_ID = dd.Drink_ID
        LEFT JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
        LEFT JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
        GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1))
        WHERE Total_Spending_Drinks > Total_Spending_Sides
        ORDER BY (Total_Spending_Drinks - Total_Spending_Sides) DESC
    )
    WHERE ROWNUM <= 5;

SELECT City, Total_Spending_Drinks, Total_Spending_Sides, (Total_Spending_Drinks - Total_Spending_Sides) AS Net_Revenue
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(dod.D_Quantity * dd.Price) AS Total_Spending_Drinks,
        SUM(sod.S_Quantity * sd.Price) AS Total_Spending_Sides
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Drink_Order_Details dod ON tod.Order_ID = dod.Order_ID
    JOIN Drink_Details dd ON dod.Drink_ID = dd.Drink_ID
    LEFT JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    LEFT JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
)
WHERE (Total_Spending_Drinks > Total_Spending_Sides)
AND ROWNUM <= 5
ORDER BY Net_Revenue DESC;


SELECT SUM(S_Quantity) AS TotalSidesSold
FROM Sides_Order_Details;


SELECT SUM(sod.S_Quantity * sd.Price) AS TotalRevenueGeneratedBySides
FROM Sides_Order_Details sod
JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID;


SELECT *
FROM (
    SELECT
        s.Sides_ID,
        s.Name AS SideName,
        SUM(sod.S_Quantity * sd.Price) AS RevenueGenerated
    FROM Sides_Order_Details sod
    JOIN Sides_Details s ON sod.Sides_ID = s.Sides_ID
    GROUP BY s.Sides_ID, s.Name
    ORDER BY RevenueGenerated DESC
)


WHERE ROWNUM <= 5;



SELECT *
FROM (
    SELECT
        s."Sides_ID",
        s."Name" AS SideName,
        SUM(sod."S_Quantity" * s."Price") AS RevenueGenerated
    FROM "Sides_Order_Details" sod
    JOIN "Sides_Details" s ON sod."Sides_ID" = s."Sides_ID"
    GROUP BY s."Sides_ID", s."Name"
    ORDER BY RevenueGenerated DESC
)
WHERE ROWNUM <= 5;


SELECT Side_Name, Total_Revenue
FROM (
    SELECT
        sd.Name AS Side_Name,
        SUM(sod.S_Quantity * sd.Price) AS Total_Revenue
    FROM Sides_Order_Details sod
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY sd.Name
    ORDER BY Total_Revenue asc
)
WHERE ROWNUM <= 5;


SELECT
    City,
    Side_Name,
    Total_Revenue
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        sd.Name AS Side_Name,
        SUM(sod.S_Quantity * sd.Price) AS Total_Revenue
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1), sd.Name
)
ORDER BY City, Total_Revenue DESC;



SELECT City, SUM(Total_Revenue) AS Total_Revenue_In_City
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(sod.S_Quantity * sd.Price) AS Total_Revenue
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
)
GROUP BY City;



SELECT City, Total_Spending_Sides, Total_Spending_Drinks, (Total_Spending_Sides - Total_Spending_Drinks) AS Net_Sides_Spending
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(sod.S_Quantity * sd.Price) AS Total_Spending_Sides,
        SUM(dod.D_Quantity * dd.Price) AS Total_Spending_Drinks
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    LEFT JOIN Drink_Order_Details dod ON tod.Order_ID = dod.Order_ID
    LEFT JOIN Drink_Details dd ON dod.Drink_ID = dd.Drink_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
)
WHERE (Total_Spending_Sides > Total_Spending_Drinks)
AND ROWNUM <= 5
ORDER BY Net_Sides_Spending DESC;


SELECT City, Total_Veg_Sides_Ordered
FROM (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(CASE WHEN sd.Is_Veg = 1 THEN sod.S_Quantity ELSE 0 END) AS Total_Veg_Sides_Ordered
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
)
ORDER BY Total_Veg_Sides_Ordered DESC;

WITH VegSides AS (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(CASE WHEN sd.Is_Veg = 1 THEN sod.S_Quantity ELSE 0 END) AS Total_Veg_Sides_Ordered
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
),
NonVegSides AS (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(CASE WHEN sd.Is_Veg = 0 THEN sod.S_Quantity ELSE 0 END) AS Total_NonVeg_Sides_Ordered
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
)
SELECT V.City, V.Total_Veg_Sides_Ordered, NV.Total_NonVeg_Sides_Ordered
FROM VegSides V
JOIN NonVegSides NV ON V.City = NV.City
ORDER BY V.Total_Veg_Sides_Ordered DESC;

WITH VegSides AS (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(CASE WHEN sd.Is_Veg = 1 THEN sod.S_Quantity * sd.Price ELSE 0 END) AS Total_Veg_Sides_Revenue
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
),
NonVegSides AS (
    SELECT
        SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1) AS City,
        SUM(CASE WHEN sd.Is_Veg = 0 THEN sod.S_Quantity * sd.Price ELSE 0 END) AS Total_NonVeg_Sides_Revenue
    FROM Customer_Details cd
    JOIN Transaction_Order_Details tod ON cd.Customer_ID = tod.Customer_ID
    JOIN Sides_Order_Details sod ON tod.Order_ID = sod.Order_ID
    JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    GROUP BY SUBSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), 1, INSTR(SUBSTR(cd.Address, INSTR(cd.Address, ',', -1) + 1), '-', -1) - 1)
)
SELECT V.City, V.Total_Veg_Sides_Revenue, NV.Total_NonVeg_Sides_Revenue
FROM VegSides V
JOIN NonVegSides NV ON V.City = NV.City;


CREATE VIEW Types_of_Toppings AS
    SELECT COUNT(*) AS ToppingsCount FROM topping_details;

INSERT INTO topping_details VALUES('TOP1111', 'Garlic Prawn', 0, 99, 149);

INSERT INTO topping_details VALUES('TOP2222', 'Garlic tempura', 0, 99, 149);



SELECT COUNT(*) AS ToppingsCount FROM topping_details;


WITH PizzaBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(P.base_price * POD.P_Quantity) AS Base_Revenue_Pizza
    FROM Transaction_Order_Details T
    JOIN Pizza_Order_Details POD ON T.Order_ID = POD.Order_ID
    JOIN Pizza_Details P ON POD.Pizza_ID = P.Pizza_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
),
DrinkBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(D.base_price * DOD.D_Quantity) AS Base_Revenue_Drink
    FROM Transaction_Order_Details T
    JOIN Drink_Order_Details DOD ON T.Order_ID = DOD.Order_ID
    JOIN Drink_Details D ON DOD.Drink_ID = D.Drink_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
),
SidesBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(S.base_price * SOD.S_Quantity) AS Base_Revenue_Sides
    FROM Transaction_Order_Details T
    JOIN Sides_Order_Details SOD ON T.Order_ID = SOD.Order_ID
    JOIN Sides_Details S ON SOD.Sides_ID = S.Sides_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
),
ComboBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(C.base_price * COD.C_Quantity) AS Base_Revenue_Combo
    FROM Transaction_Order_Details T
    JOIN Combo_Order_Details COD ON T.Order_ID = COD.Order_ID
    JOIN Combo_Details C ON COD.Combo_ID = C.Combo_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
)
SELECT
    P.Year,
    P.Month,
    NVL(P.Base_Revenue_Pizza, 0) AS Base_Revenue_Pizza,
    NVL(D.Base_Revenue_Drink, 0) AS Base_Revenue_Drink,
    NVL(S.Base_Revenue_Sides, 0) AS Base_Revenue_Sides,
    NVL(C.Base_Revenue_Combo, 0) AS Base_Revenue_Combo,
    NVL(P.Base_Revenue_Pizza, 0) +
    NVL(D.Base_Revenue_Drink, 0) +
    NVL(S.Base_Revenue_Sides, 0) +
    NVL(C.Base_Revenue_Combo, 0) AS Total_Base_Revenue
FROM PizzaBaseRevenue P
FULL JOIN DrinkBaseRevenue D ON P.Year = D.Year AND P.Month = D.Month
FULL JOIN SidesBaseRevenue S ON P.Year = S.Year AND P.Month = S.Month
FULL JOIN ComboBaseRevenue C ON P.Year = C.Year AND P.Month = C.Month
ORDER BY P.Year, P.Month;



WITH PizzaBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(P.base_price * POD.P_Quantity) AS Base_Revenue_Pizza,
        SUM(P.Price * POD.P_Quantity) AS Price_Revenue_Pizza
    FROM Transaction_Order_Details T
    JOIN Pizza_Order_Details POD ON T.Order_ID = POD.Order_ID
    JOIN Pizza_Details P ON POD.Pizza_ID = P.Pizza_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
),
DrinkBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(D.base_price * DOD.D_Quantity) AS Base_Revenue_Drink,
        SUM(D.Price * DOD.D_Quantity) AS Price_Revenue_Drink
    FROM Transaction_Order_Details T
    JOIN Drink_Order_Details DOD ON T.Order_ID = DOD.Order_ID
    JOIN Drink_Details D ON DOD.Drink_ID = D.Drink_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
),
SidesBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(S.base_price * SOD.S_Quantity) AS Base_Revenue_Sides,
        SUM(S.Price * SOD.S_Quantity) AS Price_Revenue_Sides
    FROM Transaction_Order_Details T
    JOIN Sides_Order_Details SOD ON T.Order_ID = SOD.Order_ID
    JOIN Sides_Details S ON SOD.Sides_ID = S.Sides_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
),
ComboBaseRevenue AS (
    SELECT
        TO_CHAR(T.Transaction_Date, 'YYYY') AS Year,
        TO_CHAR(T.Transaction_Date, 'MM') AS Month,
        SUM(C.base_price * COD.C_Quantity) AS Base_Revenue_Combo,
        SUM(C.Price * COD.C_Quantity) AS Price_Revenue_Combo
    FROM Transaction_Order_Details T
    JOIN Combo_Order_Details COD ON T.Order_ID = COD.Order_ID
    JOIN Combo_Details C ON COD.Combo_ID = C.Combo_ID
    GROUP BY TO_CHAR(T.Transaction_Date, 'YYYY'), TO_CHAR(T.Transaction_Date, 'MM')
)
SELECT
    P.Year,
    P.Month,
    NVL(P.Base_Revenue_Pizza, 0) AS Base_Revenue_Pizza,
    NVL(D.Base_Revenue_Drink, 0) AS Base_Revenue_Drink,
    NVL(S.Base_Revenue_Sides, 0) AS Base_Revenue_Sides,
    NVL(C.Base_Revenue_Combo, 0) AS Base_Revenue_Combo,
    NVL(P.Price_Revenue_Pizza, 0) AS Price_Revenue_Pizza,
    NVL(D.Price_Revenue_Drink, 0) AS Price_Revenue_Drink,
    NVL(S.Price_Revenue_Sides, 0) AS Price_Revenue_Sides,
    NVL(C.Price_Revenue_Combo, 0) AS Price_Revenue_Combo,
    NVL(P.Base_Revenue_Pizza, 0) + NVL(D.Base_Revenue_Drink, 0) + NVL(S.Base_Revenue_Sides, 0) + NVL(C.Base_Revenue_Combo, 0) AS Total_Base_Revenue,
    NVL(P.Price_Revenue_Pizza, 0) + NVL(D.Price_Revenue_Drink, 0) + NVL(S.Price_Revenue_Sides, 0) + NVL(C.Price_Revenue_Combo, 0) AS Total_Price_Revenue
FROM PizzaBaseRevenue P
FULL JOIN DrinkBaseRevenue D ON P.Year = D.Year AND P.Month = D.Month
FULL JOIN SidesBaseRevenue S ON P.Year = S.Year AND P.Month = S.Month
FULL JOIN ComboBaseRevenue C ON P.Year = C.Year AND P.Month = C.Month
ORDER BY P.Year, P.Month;







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
    ROUND((Price - Base_Price) / Base_Price * 100,2) AS ProfitPercentage
FROM PizzaOrderCounts
WHERE ROWNUM <= 10;



SELECT b.Name AS BakeName, COUNT(po.Pizza_ID) AS PizzaCount
FROM Bake_Details b
LEFT JOIN Pizza_Details p ON b.Bake_ID = p.Bake_ID
LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
GROUP BY b.Name;


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


SELECT b.Name AS BakeName, COUNT(po.Pizza_ID) AS PizzaCount
FROM Bake_Details b
LEFT JOIN Pizza_Details p ON b.Bake_ID = p.Bake_ID
LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
GROUP BY b.Name;

