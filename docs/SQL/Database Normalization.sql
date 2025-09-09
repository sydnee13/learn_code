CREATE TABLE Projects(
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Value DECIMAL(5,2),
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE Employees(
    ID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    HourlyWage DECIMAL(5,2),
    HireDate DATE
);

CREATE TABLE ProjectEmployees(
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectID INT,
    EmployeeID INT,
    Hours DECIMAL(5,2),
    CONSTRAINT FK_ProjectEmployees_Projects FOREIGN KEY (ProjectID) REFERENCES Projects(ID),
    CONSTRAINT FK_ProjectEmployees_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(ID)
);

CREATE TABLE JobOrders(
    ID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    ProjectID INT,
    Description TEXT,
    OrderDateTime DATETIME,
    Quantity INT,
    Price DECIMAL(5,2),
    CONSTRAINT FK_JobOrders_Projects FOREIGN KEY (ProjectID) REFERENCES Projects(ID),
    CONSTRAINT FK_JobOrders_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(ID)
);

CREATE TABLE Customers(
    NAME VARCHAR(100),
    INDUSTRY VARCHAR(100),
    Project1_ID INT,
    Project1_Feedback TEXT,
    Project2_ID INT,
    Project2_Feedback TEXT,
    ContactPersonID INT,
    ContactPersonAndRole VARCHAR(255),
    PhoneNumber VARCHAR(12),
    Address VARCHAR(255),
    City VARCHAR(255),
    Zip VARCHAR(5)
);

INSERT INTO Customers
(
    NAME,
    INDUSTRY,
    Project1_ID,
    Project1_Feedback,
    Project2_ID,
    Project2_Feedback,
    ContactPersonID,
    ContactPersonAndRole,
    PhoneNumber,
    Address,
    City,
    Zip
)
VALUES
("Zydus Cadilla", "Pharma", 2455, "Amazing Work!", NULL, NULL, 133, "Dave, HoD", "555-55-5555", "1, Landing Street", "York", "23456"),
("HDFC", "Finance", 9855, "Nice job!", 4924, "Fantastic!", 146, "Mark, Ops Lead", "222-22-2222", "2, Times Square", "London", "86421"),
("ICICI" ,"Finance", 3965, "Well done.", NULL, NULL, 122, "Peter, Analyst", "444-44-4444", "3, Garden Street", "Brussels", "53864");

# Customers table violates all three fules of first normal form
# 1. We do not see a Primary key
# 2. The data is not found in its most reduced form
# 3. There are two repeating groups of columns (Project1_ID, Project1_Feedback) and (Project2_ID, Project2_Feedback)

# First step: add a primary key by adding column ID with datatype INT
ALTER TABLE Customers
ADD COLUMN ID INT PRIMARY KEY AUTO_INCREMENT;
# Now, Customers satisfies the first rule of the First Normal Form

# Second step: split ContactPersonAndRole into two individual columns
ALTER TABLE Customers
CHANGE COLUMN ContactPersonAndRole ContactPerson VARCHAR(255),
ADD COLUMN ContactPersonRole VARCHAR(20);

# Third step: create new table ProjectFeedbacks and link it back with Customers and Projects tåble
ALTER TABLE Customers
DROP COLUMN Project1_ID,
DROP COLUMN Project1_Feedback,
DROP COLUMN Project2_ID,
DROP COLUMN Project2_Feedback;

CREATE TABLE ProjectFeedback(
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectID INT,
    CustomerID INT,
    Feedback TEXT,
    CONSTRAINT FK_ProjectFeedbacks_Projects FOREIGN KEY (ProjectID) REFERENCES Projects(ID),
    CONSTRAINT FK_ProjectFeedbacks_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(ID)
);
# Customers table now supports 1NF

# now to satisfy 2NF, we need to create ContactPersons table because they are not related to the primary key Customer ID
ALTER TABLE Customers
DROP COLUMN ContactPerson,
DROP COLUMN ContactPersonRole,
DROP COLUMN PhoneNumber;

CREATE TABLE ContactPersons(
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ContactPerson VARCHAR(100),
    ContactPersonRole VARCHAR(20),
    PhoneNumber VARCHAR(12)
);

ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_ContactPersons FOREIGN KEY (ContactPersonID) REFERENCES ContactPersons(ID);

# to satisfy 3NF, need to create new ZipCodes table to store Zip and City because while City may depend on primary key
# City also depends on Zip
ALTER TABLE Customers
DROP COLUMN City;

CREATE TABLE ZipCodes(
    ZipID VARCHAR(5) PRIMARY KEY,
    City VARCHAR(255)
);

ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_ZipCodes FOREIGN KEY (Zip) REFERENCES ZipCodes(ZipID);
