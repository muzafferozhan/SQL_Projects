'INTRODUCTION
- To fulfill management requests regarding the trade at a restaurant as a workplace scenario,
restaurant sales data and employees data are analysed and the required outputs are created.
- The following are the related tables where data is queried.
'
CREATE SCHEMA `Restaurant_Sales` ;

CREATE TABLE Customers (
CustomerID INT NOT NULL auto_increment,
FirstName varchar(255) NOT NULL,
LastName varchar(255) NOT NULL,
Email varchar(255) NOT NULL,
Address varchar(255) NOT NULL,
City varchar(255) NOT NULL,
State char(2) NOT NULL,
Phone varchar(255) NOT NULL,
Birthday date NOT NULL,
FavoriteDish int NOT NULL,
PRIMARY KEY (CustomerID)
);

CREATE TABLE `Restaurant_Sales`.`Orders` (
  `OrderID` INT NOT NULL,
  `CustomerID` INT NOT NULL,
  `OrderDate` DATETIME NOT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  CONSTRAINT `CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `Restaurant_Sales`.`Customers` (`CustomerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


CREATE TABLE `Restaurant_Sales`.`Dishes` (
  `DishID` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Description` VARCHAR(45) NOT NULL,
  `Price` DECIMAL(2) NOT NULL,
  `DishType` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`DishID`));

CREATE TABLE Restaurant_Sales.OrdersDishes (
    OrdersDishesID INT NOT NULL,
    OrderID INT NOT NULL,
    DishID INT,
    PRIMARY KEY (OrdersDishesID),
    FOREIGN KEY (DishID) REFERENCES Dishes(DishID)
    );

' Due to not null being missed here, the table is updated as follows:
'
ALTER TABLE `Restaurant_Sales`.`OrdersDishes` 
DROP FOREIGN KEY `ordersdishes_ibfk_1`;
ALTER TABLE `Restaurant_Sales`.`OrdersDishes` 
CHANGE COLUMN `DishID` `DishID` INT NOT NULL ;
ALTER TABLE `Restaurant_Sales`.`OrdersDishes` 
ADD CONSTRAINT `ordersdishes_ibfk_1`
FOREIGN KEY (`DishID`)
REFERENCES `Restaurant_Sales`.`Dishes` (`DishID`);


CREATE TABLE `Restaurant_Sales`.`EmployeesData` (
  `EmployeeID` INT NOT NULL,
  `First_Name` VARCHAR(255) NOT NULL,
  `Last_Name` VARCHAR(255) NOT NULL,
  `Department` VARCHAR(255) NOT NULL,
  `Role` VARCHAR(255) NOT NULL,
  `User_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`EmployeeID`));


CREATE TABLE `Restaurant_Sales`.`Reservations_Info` (
  `ReservationID` INT NOT NULL,
  `CustomerID` INT NOT NULL,
  `ReservationDate` DATETIME NOT NULL,
  `PartySize` INT NOT NULL,
  PRIMARY KEY (`ReservationID`));


CREATE TABLE `Restaurant_Sales`.`Employees` (
  `EmployeeID` INT NOT NULL,
  `FirstName` VARCHAR(45) NOT NULL,
  `LastName` VARCHAR(45) NOT NULL,
  `Department` VARCHAR(45) NOT NULL,
  `Position` VARCHAR(45) NOT NULL,
  `Weekly_Pay` INT NOT NULL,
  `Username` VARCHAR(45) NULL,
  PRIMARY KEY (`EmployeeID`));


'REQUEST 1
- Customers with the highest spending are needed to be offered tickets to a concert, so we need
to know them.
- Three tables needed to be joined in order that each customer can be matched with their orders
 and their prices, which is executed as follows:'

SELECT
o.CUSTOMERID, 
sum(d.price) total_spend
FROM Orders o JOIN ordersdishes od
ON O.OrderID=od.ORDERID
JOIN Dishes d 
on od.DISHID=d.DISHID
JOIN customers c on o.customerid=c.customerid
WHERE o.ORDERDATE > '2020-01-01'
group by o.customerid 
having sum(d.price) > 200
ORDER BY total_spend desc

----------------------------
| CUSTOMERID | TOTAL_SPEND |
----------------------------
| 100        | 468.85      |
| 27         | 416.81      |
| 76         | 371.86      |
| 80         | 327.87      |
| 35         | 321.89      |

'REQUEST 2
- To be able to plan a suitable marketing campaign, dishes that each order contains need to 
be queried, allowing us to explore the dishes that are ordered together.
- Similar to the above query, three tables are joined and an output report that returns orders 
(OrderID) and dishes within each order is created.
- The query also filters and shows the orders from June 01, 2022.'

SELECT O.OrderID,
Group_Concat(d.Name Order by d.Name) Items
FROM Orders o
JOIN Ordersdishes od on o.ORDERID=od.ORDERID
JOIN Dishes d on d.DISHID=od.dishid 
where o.orderdate >= '2022-06-01'
GROUP BY O.OrderID 

----------------------------------------------------------------------------------------------------------------------------------------------------------
| ORDERID | ITEMS                                                                                                                                        |
----------------------------------------------------------------------------------------------------------------------------------------------------------
| 973     | Chocolate Chip Brownie,Handcrafted Pizza,Parmesan Deviled Eggs                                                                               |
| 974     | Artichokes with Garlic Aioli,Chef's Salad,Creme Brulee,Tomato Bruschetta Tortellini,Tropical Blue Smoothie                                   |
| 975     | Quinoa Salmon Salad,Quinoa Salmon Salad                                                                                                      |
| 976     | House Salad,Tomato Bruschetta Tortellini                                                                                                     |
| 977     | Apple Pie,Panko Stuffed Mushrooms,Quinoa Salmon Salad                                                          

''REQUEST 3
- To explore whether the demand for certain product (house salad) is constant, we need to 
know how many times it is ordered a day.
- As for this purpose we are not interested in datetime as a whole, we use cast function, 
so that a grouping is done as needed.'

SELECT
count(d.name) "Number of House Salad Sold",
CAST(orderdate AS DATE) Day
FROM Dishes d
JOIN OrdersDishes od on d.dishid=od.DISHID
JOIN Orders o on od.orderid=o.ORDERID
Where d.name = 'House Salad'
GROUP BY Day
ORDER BY Day

-------------------------------------------
| Number of House Salad Sold | DAY        |
-------------------------------------------
| 1                          | 2018-06-14 |
| 1                          | 2018-06-16 |
| 1                          | 2018-06-18 |
| 1                          | 2018-06-24 |
| 1                          | 2018-06-28 |

'REQUEST 4
- As part of plans for introducing a sale, varying levels of discounts need to be applied to 
items according to which price range they fall into.
- While items below £8 should attract a discount rate of 6.5%, those priced at £8-11 are 
discounted by 11.5%.
- Any item above £11 then attracts 16.5% as the discount rate.
- Execution of the following returns the expected outcome, which is an updated list of items, 
showing the discount rate applied and the affected price'

SELECT 
Name Dishname,
Price OriginalPrice,

CASE 
WHEN
price < 8 THEN '6.5%'
WHEN price BETWEEN 8 AND 11 THEN '11.5%'
ELSE '16.5%'
END DiscountPercent,

ROUND( 
price *(
1 - CASE 
WHEN Price <8 THEN 0.065
WHEN Price BETWEEN 8 AND 11 THEN 0.115
ELSE 0.165
END) ,2) 
DiscountedPrice

FROM 
Dishes
ORDER BY DishName

------------------------------------------------------------------------------------
| DISHNAME                     | ORIGINALPRICE | DISCOUNTPERCENT | DISCOUNTEDPRICE |
------------------------------------------------------------------------------------
| Apple Pie                    | 5.00          | 6.5%            | 4.68            |
| Artichokes with Garlic Aioli | 9.00          | 11.5%           | 7.97            |
| Barbecued Tofu Skewers       | 9.99          | 11.5%           | 8.84            |
| Cafe Latte                   | 6.00          | 6.5%            | 5.61            |
| Cheesecake                   | 9.00          | 11.5%           | 7.97            |

'REQUEST 5
- Some of the employee information need to be shared with a third party, vendor, to receive a 
service. 
- To this end, the data in the EmployeesData table from the database will be queried.

The output should include:
- Employee ID as a six-digit number,
- Employee names,
- Login that is made up of fhe first initial of first name and up to 8 characters of last name,
- Email that is constructed using Username + company email domain.'

SELECT
LPAD(EmployeeID, 6, 0) ID,

CONCAT(Last_Name, ', ', First_Name) Name,

LOWER(
CONCAT(
SUBSTRING(FirstName, 1,1),
SUBSTRING(LastName, 1,8))
)
Login,

CONCAT(User_name, '@kelvety-restaurant.com') Email

FROM EmployeesData
ORDER BY Name


'REQUEST 6
- Restaurant management is now asking for the record of reservations since February 2022. 
The running total number of people served should be listed alongside date and party size.'

SELECT
ReservationDate,
PartySize,
SUM(PartySize) OVER (ORDER BY Date) Running_Total
FROM Reservations_Info
WHERE Reservations_Info.ReservationDate >= '2022-02-01'

-----------------------------------------------------
| DATE                  | PARTYSIZE | RUNNING_TOTAL |
-----------------------------------------------------
| 2022-02-02 14:30:00.0 | 7         | 7             |
| 2022-02-03 09:30:00.0 | 2         | 9             |
| 2022-02-03 10:00:00.0 | 4         | 13            |
| 2022-02-04 10:00:00.0 | 1         | 14            |
| 2022-02-04 10:30:00.0 | 7         | 21            |

'REQUEST 7
- Total amount of weekly payments by department is needed as output from the data in the 
Employees table. Management asked to exclude Culinary department from this evaluation.'

SELECT distinct
EmployeeID,
Department,
Position,
WeeklyPay Weekly_Pay,
SUM(WeeklyPay) OVER (PARTITION BY Department) Department_Total
FROM Employees
WHERE Department != 'Culinary'
ORDER BY Department, WeeklyPay


----------------------------------------------------------------------------------
| EMPLOYEEID | DEPARTMENT  | POSITION            | WEEKLY_PAY | DEPARTMENT_TOTAL |
----------------------------------------------------------------------------------
| 115        | Delivery    | Delivery Driver I   | 860        | 1720             |
| 116        | Delivery    | Delivery Driver I   | 860        | 1720             |
| 107        | Executive   | Executive Assistant | 1900       | 9500             |
| 100        | Executive   | Co-Founder          | 3800       | 9500             |
| 101        | Executive   | Co-Founder          | 3800       | 9500             |


'REQUEST 8
We now need to rank each employee\'s weekly pay within their respective department. A new column
named 'Department_Rank' will  list this information. The ranking will make sure the employees
with lowest pays are shown on top:'

SELECT 
EmployeeID,
WeeklyPay, 
Department,
DENSE_RANK() OVER (PARTITION BY DEPARTMENT ORDER BY WeeklyPay desc) AS Department_Rank
FROM Employees
ORDER BY Department, WEEKLYPAY asc

----------------------------------------------------------
| EMPLOYEEID | WEEKLYPAY | DEPARTMENT  | DEPARTMENT_RANK |
----------------------------------------------------------
| 109        | 1250      | Culinary    | 4               |
| 110        | 1300      | Culinary    | 3               |
| 111        | 1300      | Culinary    | 3               |
| 103        | 2500      | Culinary    | 2               |
| 104        | 2500      | Culinary    | 2               |



'REQUEST 9
To address this request, we need information from three different tables. 
Our output should display orderID with total amount of the order and a difference column,
which shows the difference in amount of an order with the previous one. We only look at 
data since June 2022'

SELECT O.OrderID,
SUM(D.Price) AS ThisOrderPrice,
SUM(D.Price) - LAG(SUM(D.Price),1) OVER (
    ORDER BY O.OrderID) AS DiffFromPrev
FROM Orders o
JOIN OrdersDishes od on O.OrderID=od.ORDERID
JOIN Dishes d on od.DISHID=d.dishid
WHERE OrderDate >= '2022-06-01'
GROUP BY O.OrderID
-------------------------------------------
| ORDERID | THISORDERPRICE | DIFFFROMPREV |
-------------------------------------------
| 973     | 24.99          | null         |
| 974     | 42.99          | 18.00        |
| 975     | 19.98          | -23.01       |
| 976     | 16.99          | -2.99        |
| 977     | 21.99          | 5.00         |

'As OrderID 887 is the first order in 2022, difference value is null for that. '

'REQUEST 10
I am now asked to return moving averages for each customer\'s orders, as this will work 
as an indicator of a customer\'s spending pattern.'

SELECT 
o.CustomerID,
o.OrderID,

sum(d.PRICE) AS OrderPrice,

ROUND(AVG(SUM(D.PRICE)) 
OVER (PARTITION BY O.CustomerID 
ORDER BY O.OrderID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
AS MovingAvg, 

FROM Orders o
JOIN OrdersDishes od on O.OrderID=od.ORDERID
JOIN Dishes d on od.DISHID=d.dishid
WHERE OrderDate > '2021-01-01'
GROUP BY o.customerid, O.ORDERID
---------------------------------------------------
| CUSTOMERID | ORDERID | ORDER_PRICE | MOVING_AVG |
---------------------------------------------------
| 1          | 645     | 28.99       | 28.99      |
| 1          | 683     | 16.00       | 22.50      |
| 1          | 762     | 36.97       | 27.32      |
| 1          | 789     | 38.00       | 30.32      |
| 1          | 907     | 30.99       | 35.32      |


