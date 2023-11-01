'INTRODUCTION
- To fulfill management requests regarding the trade at a restaurant, restaurant sales data is analysed.
- The following are four related tables where data is queried.
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

'REQUEST 1
- Customers with the highest spending will be invited to a lunch event. 
- Three tables needed to be joined in order that each customer can be matched with their orders and their prices, which is executed as follows:'

SELECT
o.CUSTOMERID, 
c.firstname,
c.lastname,
sum(d.price) total_spend
FROM Orders o JOIN ordersdishes od
ON O.OrderID=od.ORDERID
JOIN Dishes d 
on od.DISHID=d.DISHID
JOIN customers c on o.customerid=c.customerid
group by o.customerid 
having sum(d.price) > 500
ORDER BY total_spend desc

'REQUEST 2
- To be able to plan a suitable marketing campaign, dishes that each order contains need to be queried, allowing us to explore the dishes that are ordered together.
- Similar to the above query, three tables are joined and an output report that returns orders (OrderID) and dishes within each order is created.
- The query also filters and shows the orders from June 23, 2022.'

SELECT O.OrderID,
Group_Concat(d.Name Order by d.Name) Items
FROM Orders o
JOIN Ordersdishes od on o.ORDERID=od.ORDERID
JOIN Dishes d on d.DISHID=od.dishid 
where o.orderdate >= '2022-06-23'
GROUP BY O.OrderID 

'REQUEST 3
- To explore whether the demand for certain product (house salad) is constant, we need to know how many times it is ordered a day.
- As for this purpose we are not interested in datetime as a whole, we use cast function, so that a grouping is done as needed.
'

SELECT
count(d.name) "Number of House Salad Sold",
CAST(orderdate AS DATE) Day
FROM Dishes d
JOIN OrdersDishes od on d.dishid=od.DISHID
JOIN Orders o on od.orderid=o.ORDERID
Where d.name = 'House Salad'
GROUP BY Day
ORDER BY Day

'REQUEST 4
- As part of plans for introducing a sale, varying levels of discounts need to be applied to items according to which
price range they fall into.
- While items below £8 should attract a discount rate of 6.5%, those priced at £8-11 are discounted by 11.5%.
- Any item above £11 then attracts 16.5% as the discount rate.
- Execution of the following returns the expected outcome, which is an updated list of items, showing the discount rate
applied and the affected price'

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

'REQUEST 5
- Some of the employee information need to be shared with a third party, vendor, to receive a service. 
- To this end, the data in the Employees table, of which fields are provided below, will be queried.
'
CREATE TABLE `Restaurant_Sales`.`EmployeesData` (
  `EmployeeID` INT NOT NULL,
  `First_Name` VARCHAR(255) NOT NULL,
  `Last_Name` VARCHAR(255) NOT NULL,
  `Department` VARCHAR(255) NOT NULL,
  `Role` VARCHAR(255) NOT NULL,
  `User_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`EmployeeID`));
'
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

FROM Employees
ORDER BY Name


'REQUEST 6'

SELECT
Date,
PartySize,
SUM(PartySize) OVER (ORDER BY Date) Running_Total
FROM Reservations
WHERE Reservations.Date >= '2022-01-01'

'REQUEST 7'

SELECT distinct
EmployeeID,
Department,
Position,
WeeklyPay,
SUM(WeeklyPay) OVER (PARTITION BY Department) DeptTotal
FROM Employees
ORDER BY Department, WeeklyPay

'REQUEST 8'

SELECT 
FirstName,
LastName, 
WeeklyPay, 
Department,
DENSE_RANK() OVER (PARTITION BY DEPARTMENT ORDER BY WeeklyPay desc) AS DeptRank
FROM Employees
ORDER BY Department, WEEKLYPAY desc

'REQUEST 9'

SELECT O.OrderID,
SUM(D.Price) AS ThisOrderPrice,
SUM(D.Price) - LAG(SUM(D.Price),1) OVER (
    ORDER BY O.OrderID) AS DiffFromPrev
FROM Orders o
JOIN OrdersDishes od on O.OrderID=od.ORDERID
JOIN Dishes d on od.DISHID=d.dishid
WHERE OrderDate >= '2022-01-01'
GROUP BY O.OrderID

'REQUEST 10'

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
GROUP BY o.customerid, O.ORDERID





