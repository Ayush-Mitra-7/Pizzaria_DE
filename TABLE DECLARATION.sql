--Create database pizza_data;
--use pizza_data;

-- --------------------------------PIZZA TABLE CREATION---------------------------------------- --  

CREATE TABLE Topping_Details (
    Toppings_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Is_Veg INT NOT NULL,
    base_price FLOAT NOT NULL,
    price FLOAT NOT NULL
);

CREATE TABLE Crust_Details (
    Crust_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    base_price FLOAT NOT NULL,
    price FLOAT NOT NULL
);

CREATE TABLE Bake_Details (
    Bake_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    base_price FLOAT NOT NULL,
    price FLOAT NOT NULL
);

CREATE TABLE Size_Details (
    Size_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    base_price FLOAT NOT NULL,
    price FLOAT NOT NULL
);

CREATE TABLE Pizza_Details (
    Pizza_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Topping_1_ID VARCHAR(50) NOT NULL,
    Topping_2_ID VARCHAR(50) NOT NULL,
    Topping_3_ID VARCHAR(50),
    Topping_4_ID VARCHAR(50),
    Crust_ID VARCHAR(50) NOT NULL,
    Bake_ID VARCHAR(50) NOT NULL,
    Size_ID VARCHAR(50) NOT NULL,
    Is_Veg INT NOT NULL,
    base_price FLOAT NOT NULL,
    Price FLOAT NOT NULL,
    FOREIGN KEY (Topping_1_ID) REFERENCES Topping_Details(Toppings_ID),
    FOREIGN KEY (Topping_2_ID) REFERENCES Topping_Details(Toppings_ID),
    FOREIGN KEY (Topping_3_ID) REFERENCES Topping_Details(Toppings_ID),
    FOREIGN KEY (Topping_4_ID) REFERENCES Topping_Details(Toppings_ID),
    FOREIGN KEY (Crust_ID) REFERENCES Crust_Details(Crust_ID),
    FOREIGN KEY (Bake_ID) REFERENCES Bake_Details(Bake_ID),
    FOREIGN KEY (Size_ID) REFERENCES Size_Details(Size_ID)
);

-- --------------------------------PIZZA TABLE CREATION---------------------------------------- --  

-- --------------------------------OTHER CONSUMABLE CREATION------------------------------------- --  

CREATE TABLE Drink_Details (
    Drink_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Liters DECIMAL NOT NULL,
    base_price FLOAT NOT NULL,
    Price FLOAT NOT NULL
);

CREATE TABLE Sides_Details (
    Sides_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Is_Veg INT NOT NULL,
    base_price DECIMAL NOT NULL,
    Price FLOAT NOT NULL
);

CREATE TABLE Combo_Details (
    Combo_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Is_Veg INT NOT NULL,
    Pizza_1_ID VARCHAR(50) NOT NULL,
    P_1_freq INT,
    Pizza_2_ID VARCHAR(50),
    P_2_freq INT,
    Drink_ID VARCHAR(50),
    D_freq INT,
    Sides_ID VARCHAR(50),
    S_freq INT,
    base_price DECIMAL NOT NULL,
    Price DECIMAL NOT NULL,
    FOREIGN KEY (Pizza_1_ID) REFERENCES Pizza_Details(Pizza_ID),
    FOREIGN KEY (Pizza_2_ID) REFERENCES Pizza_Details(Pizza_ID),
    FOREIGN KEY (Drink_ID) REFERENCES Drink_Details(Drink_ID),
    FOREIGN KEY (Sides_ID) REFERENCES Sides_Details(Sides_ID)
);
-- --------------------------------OTHER CONSUMABLE CREATION------------------------------------- --  

-- --------------------------------CUSTOMER TABLE------------------------------------- -- 

CREATE TABLE Customer_Details (
    Customer_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    First_Name VARCHAR(100) NOT NULL,
    Middle_Name VARCHAR(100),
    Last_Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Phone_Number VARCHAR(20) NOT NULL,
    Email_ID VARCHAR(100) NOT NULL
);

-- --------------------------------CUSTOMER TABLE------------------------------------- --  

-- --------------------------------COUPON TABLE------------------------------------- --  

CREATE TABLE Coupon_Details (
    Coupon_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Code VARCHAR(50) NOT NULL,
    Discounted_Percentage FLOAT NOT NULL,
    Maximum_Amount FLOAT NOT NULL
);

-- --------------------------------COUPON TABLE------------------------------------- -- 

-- --------------------------------TRANSACTION TABLE------------------------------------- -- 

CREATE TABLE Transaction_Order_Details (
    Order_ID VARCHAR(50) PRIMARY KEY NOT NULL,
    Customer_ID VARCHAR(50),
    Total_Price FLOAT NOT NULL,
    Mode_of_Transaction VARCHAR(10) NOT NULL, -- Change VARCHAR to VARCHAR2
    Transaction_ID VARCHAR(50),
    Coupon_ID VARCHAR(50),
    Discounted_Amount FLOAT NOT NULL,
    Tax_Amount FLOAT NOT NULL,
    Final_Price FLOAT NOT NULL,
    Transaction_Date DATE,
    Transaction_Time TIMESTAMP,
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Details(Customer_ID),
    FOREIGN KEY (Coupon_ID) REFERENCES Coupon_Details(Coupon_ID)
);


CREATE TABLE Pizza_Order_Details (
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(50),
    Pizza_ID VARCHAR(50),
    P_Quantity INT NOT NULL,
    Total_Price FLOAT NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Transaction_Order_Details(Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Details(Customer_ID),
    FOREIGN KEY (Pizza_ID) REFERENCES Pizza_Details(Pizza_ID)
);

CREATE TABLE Drink_Order_Details (
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(50),
    Drink_ID VARCHAR(50),
    D_Quantity INT NOT NULL,
    Total_Price FLOAT NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Transaction_Order_Details(Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Details(Customer_ID),
    FOREIGN KEY (Drink_ID) REFERENCES Drink_Details(Drink_ID)
);

CREATE TABLE Sides_Order_Details (
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(50),
    Sides_ID VARCHAR(50),
    S_Quantity INT NOT NULL,
    Total_Price FLOAT NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Transaction_Order_Details(Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Details(Customer_ID),
    FOREIGN KEY (Sides_ID) REFERENCES Sides_Details(Sides_ID)
);

CREATE TABLE Combo_Order_Details (
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(50),
    Combo_ID VARCHAR(50),
    C_Quantity INT NOT NULL,
    Total_Price FLOAT NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Transaction_Order_Details(Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Details(Customer_ID),
    FOREIGN KEY (Combo_ID) REFERENCES Combo_Details(Combo_ID)
);

-- --------------------------------TRANSACTION TABLE------------------------------------- --

 CREATE TABLE Expenditure_Monthly (
     year INT,
     month INT,
     Cost_of_Employee DECIMAL,
     Cost_of_Transport DECIMAL,
     Cost_of_Accommodation DECIMAL,
     Cost_of_Products DECIMAL
 );


-- --------------------------------QUERIES------------------------------------- --

-- select * from coupon_details;
--
-- select * from customer_details;
--
-- select * from pizza_details;
--
-- select * from crust_details;
--
-- select * from topping_details;
--
-- select * from size_details;
--
-- select * from sides_details;
-- 
-- select * from drink_details;
-- delete from transaction_order_details where order_id like 'New_order%';
-- select * from combo_details;

select count(*) from Transaction_Order_Details;
-- 
select * from transaction_order_details where order_id like 'New_order%';
  
  delete from sides_order_details where order_id like 'New_order%';
  delete from pizza_order_details where order_id like 'New_order%';
  delete from drink_order_details where order_id like 'New_order%';
  delete from combo_order_details where order_id like 'New_order%';
  delete from transaction_order_details where order_id like 'New_order%';
  
-- 
-- select * from drink_order_details;
-- 
-- select * from pizza_order_details;
-- 
-- select count(*) from combo_order_details;
--
-- select * from bake_details;
 
 
 
 
