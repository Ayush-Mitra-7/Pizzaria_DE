import streamlit as st
import psycopg2
import pandas as pd
import cx_Oracle
import random

pizza_data = pd.read_csv(r'data\Pizza_data_with_prices.csv')
sides_data=pd.read_csv(r'data\Sides_data.csv')
drink_data=pd.read_csv(r'data\Drink_data.csv')
combo_data=pd.read_csv(r'data\combo_details_with_price.csv')
coupon_data=pd.read_csv(r'data\Coupon_data.csv')

def calculate_final_price(price,cp_name):

    p=list(coupon_data[coupon_data['NAME']==cp_name]['DISCOUNTED_PERCENTAGE'])[0]
    dp=price*(p/100)

    if dp>list(coupon_data[coupon_data['NAME']=='Summer Sale']['MAXIMUM_AMOUNT'])[0]:
        dp=list(coupon_data[coupon_data['NAME']=='Summer Sale']['MAXIMUM_AMOUNT'])[0]

    price=price-dp

    tx=0.18*price

    fp=round(tx+price,2)

    return fp,tx,dp




def Execute_query_transaction_order_details(mod,cp_id,dp,tx,fp,tp,drink_id,d_q,d_p,pizza_id,p_q,p_p,sides_id,s_q,s_p,combo_id,c_q,c_p):
    try:
        conn = cx_Oracle.connect('pizza_data/pizz@localhost:1521/xe')
        print(conn.version)
        cursor = conn.cursor()
    except cx_Oracle.DatabaseError as e:
        print("There is a problem with Oracle", e)

    insert_query = """
        INSERT INTO Transaction_Order_Details (ORDER_ID, CUSTOMER_ID, TOTAL_PRICE, MODE_OF_TRANSACTION, TRANSACTION_ID, COUPON_ID, DISCOUNTED_AMOUNT, TAX_AMOUNT, FINAL_PRICE, TRANSACTION_DATE, TRANSACTION_TIME)
        VALUES (:order_id, :customer_id, :total_price, :mode_of_transaction, :transaction_id, :coupon_id, :discounted_amount, :tax_amount, :final_price, TO_DATE(:transaction_date, 'DD-MM-YY'), TO_TIMESTAMP(:transaction_time, 'DD-MM-YY HH:MI:SS.FF PM'))
    """

  ##### PUT A QUERY TRACKING TXT FILE ######

    order_id=random.randint(1,100)
    transc_id=random.randint(1,100)
    ordd='New_order'+str(order_id)
    trns='New_trans'+str(transc_id)

    new_values = {
        'order_id':ordd,
        'customer_id': 'CUS60479',
        'total_price': tp,
        'mode_of_transaction': mod,
        'transaction_id':trns,
        'coupon_id': cp_id,
        'discounted_amount': dp,
        'tax_amount': tx,
        'final_price': fp,
        'transaction_date': '12-09-2023',
        'transaction_time': '15-10-23 12:34:56.000000000 PM'

    }

    # Execute the query with the values
    cursor.execute(insert_query, new_values)


    # Define the INSERT query
    insert_query_drink = """
        INSERT INTO drink_order_details (ORDER_ID, CUSTOMER_ID, DRINK_ID, D_QUANTITY, TOTAL_PRICE)
        VALUES (:order_id, :customer_id, :drink_id, :d_quantity, :total_price)
    """

    # Define the values to insert
    values = {
        'order_id':ordd,
        'customer_id': 'CUS60479',
        'drink_id':drink_id,
        'd_quantity': d_q,  # Adjust the quantity as needed
        'total_price': d_p  # Adjust the price as needed
    }

    cursor.execute(insert_query_drink, values)

    insert_query_pizza = """
    INSERT INTO pizza_order_details (ORDER_ID, CUSTOMER_ID, PIZZA_ID, P_QUANTITY, TOTAL_PRICE)
    VALUES (:order_id, :customer_id, :pizza_id, :p_quantity, :total_price)
    """

    # Define the values to insert
    values = {
        'order_id': ordd,
        'customer_id': 'CUS60479',
        'pizza_id': pizza_id,
        'p_quantity': p_q,  # Adjust the quantity as needed
        'total_price': p_p  # Adjust the price as needed
    }

    cursor.execute(insert_query_pizza, values)

    insert_query_sides = """
    INSERT INTO sides_order_details (ORDER_ID, CUSTOMER_ID, SIDES_ID, S_QUANTITY, TOTAL_PRICE)
    VALUES (:order_id, :customer_id, :sides_id, :s_quantity, :total_price)
    """

    # Define the values to insert
    values = {
        'order_id': ordd,
        'customer_id': 'CUS60479',
        'sides_id': sides_id,
        's_quantity': s_q,  # Adjust the quantity as needed
        'total_price': s_p  # Adjust the price as needed
    }
    cursor.execute(insert_query_sides, values)

    insert_query_combo = """
    INSERT INTO combo_order_details (ORDER_ID, CUSTOMER_ID, COMBO_ID, C_QUANTITY, TOTAL_PRICE)
    VALUES (:order_id, :customer_id, :combo_id, :c_quantity, :total_price)
    """

    # Define the values to insert
    values = {
        'order_id': ordd,
        'customer_id': 'CUS60479',
        'combo_id': combo_id,
        'c_quantity': c_q,  # Adjust the quantity as needed
        'total_price': c_p  # Adjust the price as needed
    }
    cursor.execute(insert_query_combo, values)

    # Commit the changes to the database
    conn.commit()

    # Close the database connection
    conn.close()

    return ordd

def execute_all_views():
    try:
        conn = cx_Oracle.connect('pizza_data/pizz@localhost:1521/xe')
        print(conn.version)
        cursor = conn.cursor()
    except cx_Oracle.DatabaseError as e:
        print("There is a problem with Oracle", e)
    
    Q1="""
        CREATE OR REPLACE VIEW Total_FoodItems_Sold AS
        SELECT
            SUM(DOD.D_Quantity) AS Total_Drinks_Sold,
            SUM(SOD.S_Quantity) AS Total_Side_Dishes_Sold,
            SUM(POD.P_Quantity) AS Total_Pizzas_Sold
        FROM Drink_Order_Details DOD
        LEFT JOIN Sides_Order_Details SOD ON DOD.Order_ID = SOD.Order_ID
        LEFT JOIN Pizza_Order_Details POD ON DOD.Order_ID = POD.Order_ID
    """
    cursor.execute(Q1)

    Q2="""
        CREATE OR REPLACE VIEW Average_Order_Cost AS
        SELECT ROUND(AVG(Total_Price), 2) AS Average_Order_Value
        FROM Transaction_Order_Details
    """
    cursor.execute(Q2)


    Q3="""
        CREATE OR REPLACE VIEW Total_Revenue AS
        SELECT SUM(Total_Price) AS Total_Revenue
        FROM Transaction_Order_Details
    """
    cursor.execute(Q3)


    Q4="""
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
            )
    """
    cursor.execute(Q4)

    Q5="""
        CREATE OR REPLACE VIEW Food_Titemwise_Revenue AS
        SELECT
            ROUND(SUM(TOD.Total_Price), 2) AS Total_Revenue,
            ROUND(SUM(CASE WHEN PIZZA.Pizza_ID IS NOT NULL THEN TOD.Total_Price ELSE 0 END), 2) AS Pizza_Revenue,
            ROUND(SUM(CASE WHEN DRINKS.Drink_ID IS NOT NULL THEN TOD.Total_Price ELSE 0 END), 2) AS Drink_Revenue,
            ROUND(SUM(CASE WHEN SIDES.Sides_ID IS NOT NULL THEN TOD.Total_Price ELSE 0 END), 2) AS Sides_Revenue
        FROM Transaction_Order_Details TOD
        LEFT JOIN Pizza_Order_Details PIZZA ON TOD.Order_ID = PIZZA.Order_ID
        LEFT JOIN Drink_Order_Details DRINKS ON TOD.Order_ID = DRINKS.Order_ID
        LEFT JOIN Sides_Order_Details SIDES ON TOD.Order_ID = SIDES.Order_ID
    """
    cursor.execute(Q5)


    Q6="""
        CREATE OR REPLACE VIEW Total_Pizza_Revenue AS
        SELECT (SUM(po.Total_Price)/2) AS TotalPizzaRevenue
        FROM Pizza_Order_Details po
        JOIN Pizza_Details pd ON po.Pizza_ID = pd.Pizza_ID
    """
    cursor.execute(Q6)


    Q7="""
        CREATE OR REPLACE VIEW Veg_Nonveg_Pizza_Sold AS
        SELECT
            SUM(CASE WHEN pd.Is_Veg = 1 THEN pod.P_Quantity ELSE 0 END) AS Total_Veg_Pizzas_Sold,
            SUM(CASE WHEN pd.Is_Veg = 0 THEN pod.P_Quantity ELSE 0 END) AS Total_NonVeg_Pizzas_Sold
        FROM Pizza_Order_Details pod
        JOIN Pizza_Details pd ON pod.Pizza_ID = pd.Pizza_ID
    """
    cursor.execute(Q7)


    Q8="""
        CREATE OR REPLACE VIEW Quaterly_Sales AS
        SELECT
            TO_CHAR(Transaction_Date, 'YYYY') AS Year,
            'Q' || TO_CHAR(Transaction_Date, 'Q') AS Quarter,
            COUNT(Order_ID) AS OrderCount
        FROM Transaction_Order_Details
        GROUP BY TO_CHAR(Transaction_Date, 'YYYY'), TO_CHAR(Transaction_Date, 'Q')
        ORDER BY Year, Quarter
    """
    cursor.execute(Q8)


    Q9="""
        CREATE OR REPLACE VIEW Top_10_Pizza_Sales AS
        SELECT * 
        FROM (
            SELECT pd.Name AS Pizza_Name, COUNT(po.Pizza_ID) AS OrderCount
            FROM Pizza_Details pd
            JOIN Pizza_Order_Details po ON pd.Pizza_ID = po.Pizza_ID
            GROUP BY pd.Name
            ORDER BY OrderCount DESC
        ) 
        WHERE ROWNUM <=10
    """
    cursor.execute(Q9)


    Q10="""
        CREATE OR REPLACE VIEW Top_10_Drinks_Sales AS
        SELECT * 
        FROM (
            SELECT dd.Name AS Drink_Name, COUNT(do.Drink_ID) AS OrderCount
            FROM Drink_Details dd
            JOIN Drink_Order_Details do ON dd.Drink_ID = do.Drink_ID
            GROUP BY dd.Name
            ORDER BY OrderCount DESC
        ) 
        WHERE ROWNUM <= 10
    """
    cursor.execute(Q10)


    Q11="""
        CREATE OR REPLACE VIEW Top_10_Sides_Sales AS
        SELECT * 
        FROM (
            SELECT sd.Name AS Sides_Name, COUNT(so.Sides_ID) AS OrderCount
            FROM Sides_Details sd
            JOIN Sides_Order_Details so ON sd.Sides_ID = so.Sides_ID
            GROUP BY sd.Name
            ORDER BY OrderCount DESC
        ) 
        WHERE ROWNUM <= 10
    """
    cursor.execute(Q11)


    Q12="""
        CREATE OR REPLACE VIEW Veg_Nonveg_Sides_Sold AS
        SELECT
            SUM(CASE WHEN sd.Is_Veg = 1 THEN sod.S_Quantity ELSE 0 END) AS Total_Veg_Sides_Sold,
            SUM(CASE WHEN sd.Is_Veg = 0 THEN sod.S_Quantity ELSE 0 END) AS Total_NonVeg_Sides_Sold
        FROM Sides_Order_Details sod
        JOIN Sides_Details sd ON sod.Sides_ID = sd.Sides_ID
    """
    cursor.execute(Q12)


    Q13="""
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
        WHERE ROWNUM = 1
    """
    cursor.execute(Q13)


    Q14="""
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
        ORDER BY Year, Quarter
    """
    cursor.execute(Q14)


    Q15="""
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
        ON CityCount.City = CityCountOrdered.City
    """
    cursor.execute(Q15)


    Q16="""
        CREATE OR REPLACE VIEW Top_10_Cust_Rev AS
        SELECT CustomerName, TotalSpending
        FROM (
            SELECT First_Name || ' ' || Last_Name AS CustomerName, Round(SUM(Final_Price)/100) AS TotalSpending
            FROM Customer_Details c
            INNER JOIN Transaction_Order_Details t ON c.Customer_ID = t.Customer_ID
            GROUP BY First_Name, Last_Name
            ORDER BY TotalSpending DESC
        )
        WHERE ROWNUM <= 10
    """
    cursor.execute(Q16)


    Q17="""
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
            END
    """
    cursor.execute(Q17)


    Q18="""
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
        GROUP BY City
    """
    cursor.execute(Q18)


    Q19="""
        CREATE OR REPLACE VIEW Total_Cust AS
        SELECT COUNT(*) AS TotalCustomers
        FROM Customer_Details
    """
    cursor.execute(Q19)


    Q20="""
        CREATE OR REPLACE VIEW New_Cust AS
        SELECT Round(COUNT(*)/6) AS TotalCustomers
        FROM Customer_Details
    """
    cursor.execute(Q20)


    Q21="""
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
            END
    """
    cursor.execute(Q21)

    Q22="""
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
        WHERE ROWNUM <= 10
    """
    cursor.execute(Q22)


    Q22="""
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
        )
    """
    cursor.execute(Q22)


    Q23="""
        CREATE OR REPLACE VIEW Bake_Prefeneces AS
        SELECT b.Name AS BakeName, COUNT(po.Pizza_ID) AS PizzaCount
        FROM Bake_Details b
        LEFT JOIN Pizza_Details p ON b.Bake_ID = p.Bake_ID
        LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
        GROUP BY b.Name
    """
    cursor.execute(Q23)


    Q24="""
        CREATE OR REPLACE VIEW Crust_Preferences AS
        SELECT c.Name AS CrustName, COUNT(po.Pizza_ID) AS PizzaCount
        FROM Crust_Details c
        LEFT JOIN Pizza_Details p ON c.Crust_ID = p.Crust_ID
        LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
        GROUP BY c.Name
    """
    cursor.execute(Q24)


    Q25="""
        CREATE OR REPLACE VIEW Size_Preferences AS
        SELECT s.Name AS SizeName, COUNT(po.Pizza_ID) AS PizzaCount
        FROM Size_Details s
        LEFT JOIN Pizza_Details p ON s.Size_ID = p.Size_ID
        LEFT JOIN Pizza_Order_Details po ON p.Pizza_ID = po.Pizza_ID
        GROUP BY s.Name
    """
    cursor.execute(Q25)


    Q26="""
        CREATE OR REPLACE VIEW AVG_PIZZA_stats AS
        SELECT Round(AVG(base_price),2) AS Avg_BP, Round(AVG(price),2) AS AVG_P, Round(AVG(Price-base_price),2) AS Avg_pf, Round(AVG((price-base_price)/price*100),2)||'%' AS Avg_pm
        FROM Pizza_Details
    """
    cursor.execute(Q26)


    Q27="""
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
            END
    """
    cursor.execute(Q27)

    conn.commit()
    conn.close()
     
# Define the Streamlit app
company_logo = 'logo_2.png'  # Replace with the actual path to your logo
st.image(company_logo,width=190)
st.write(f"<span style='font-size: 20px; color:white'><b>\"From Our Oven To Your Heart\"</b></span>", unsafe_allow_html=True)
st.write(f"<span style='font-size: 40px; color:Red'><b>Food Ordering System</b></span>", unsafe_allow_html=True)


# Create two columns for layout
col1, col2, col3 = st.columns(3)

with col1:
    pizza = st.selectbox('Choose a type of Pizza', pizza_data['NAME'].unique(),key='pizza_type')

with col2:
    pizza_quantity = st.number_input("Quantity:", min_value=0, value=0,key='pizza_quan')

with col3:
    prc_p=list(pizza_data[pizza_data['NAME']==pizza]['PRICE'])[0]
    pp_p=  prc_p * pizza_quantity
    pizza_price = st.write("Price: ₹{}".format(pp_p))

col4, col5,col6 = st.columns(3)

with col4:
    sides = st.selectbox('Choose a type of Side dish', sides_data['NAME'].unique(),key='sides_type')

with col5:
    sides_quantity = st.number_input("Quantity:", min_value=0, value=0,key='sides_quan')

with col6:
    prc_s=list(sides_data[sides_data['NAME']==sides]['PRICE'])[0]
    pp_s=  prc_s * sides_quantity
    sides_price = st.write("Price: ₹{}".format(pp_s))


col7, col8,col9 = st.columns(3)

with col7:
    drink = st.selectbox('Choose a type of Drink', drink_data['NAME'].unique(),key='drink_type')

with col8:
    drink_quantity = st.number_input("Quantity:", min_value=0, value=0,key='drink_quan')

with col9:
    prc_d=list(drink_data[drink_data['NAME']==drink]['PRICE'])[0]
    pp_d=  prc_d * drink_quantity
    drink_price = st.write("Price: ₹{}".format(pp_d))


col10, col11,col12 = st.columns(3)

with col10:
    combo = st.selectbox('Choose a type of combo', combo_data['NAME'].unique(),key='combo_type')

with col11:
    combo_quantity = st.number_input("Quantity:", min_value=0, value=0,key='combo_quan')

with col12:
    prc_c=list(combo_data[combo_data['NAME']==combo]['PRICE'])[0]
    pp_c=  prc_c * combo_quantity
    combo_price = st.write("Price: ₹{}".format(pp_c))


tp=pp_p+pp_s+pp_d+pp_c
st.write(f"<span style='font-size: 20px;'>Total Price: ₹{tp}</span>", unsafe_allow_html=True)

coup= st.selectbox('Choose a coupon',coupon_data['NAME'].unique())

fp,tx,dp=calculate_final_price(tp,coup)
st.write(f"<span style='font-size: 20px;'>Final Price(Including Tax): ₹{fp}</span>", unsafe_allow_html=True)

MODD = st.selectbox('Choose Mode of Transaction', ['UPI', 'COD','NB'])

if st.button("Place Order"):

    pizza_id=list(pizza_data[pizza_data['NAME']==pizza]['PIZZA_ID'])[0]
    sides_id=list(sides_data[sides_data['NAME']==sides]['SIDES_ID'])[0]
    drink_id=list(drink_data[drink_data['NAME']==drink]['DRINK_ID'])[0]
    combo_id=list(combo_data[combo_data['NAME']==combo]['COMBO_ID'])[0]
    coupon_id=list(coupon_data[coupon_data['NAME']==coup]['COUPON_ID'])[0]

    ordd=Execute_query_transaction_order_details(MODD,coupon_id,dp,tx,fp,tp,drink_id,drink_quantity,pp_d,pizza_id,pizza_quantity,pp_p,sides_id,sides_quantity,pp_s,combo_id,combo_quantity,pp_c)
    execute_all_views()
    print(ordd)
    st.write(f"<span style='font-size: 20px; color:green'>Order have been sucessfully placed! Thank You</span>", unsafe_allow_html=True)