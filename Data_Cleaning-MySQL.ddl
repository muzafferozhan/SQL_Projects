'
INTRODUCTION

- Company\'s employees data is incorrectly formatted, duplicated or lacks granularity which 
could potentially prevent analysing the data as required.
- The goal of this project is to analyse and normalise a database in areas where this is required. 
- The columns on people table are as follows:
id(pk), first_name, last_name, email, education, occupation, salary, department, address

ACTION

STEP 1: Are there any non-atomic fields?'
USE company
SELECT * FROM people;

'This query retrieves 399 rows.'

' 
THE ISSUES

- Address field contains values that are not atomic:
- "Street address, city, State and Zip Code" such as "2967 Barnley Ave; Hanford; CA; 90562"
- It is difficult to query the data when the address field is not atomic. 

HOW TO ADDRESS

- To address this issue, breaking up the address field is required.
- Whether all entries are separated by semi colons delimitor is also checked, as consistency accross all rows is a must and 
the goal is to normalise this database. 

STEP 2: UsingREGEXP to check and clean the address field:

- Regular Expression will be used to detect the expected format and then NOT regexp will be run to detect and fix any 
entries with the incorrect format. '

SELECT address from people where address regexp '^[0-9a-zA_Z' ]+;[a-zA_Z ]'+;[A-Z ]+;[0-9 ]+$';

SELECT count(address) from people where address regexp '^[0-9a-zA_Z' ]+;[a-zA_Z ]'+;[A-Z ]+;[0-9 ]+$';

'
Seeing 171 rows returned out of 399, a period is also added into  regexp as some address values seem to end with "."
as in "ave.", as well as a backslash due to period being a special character.:
'

SELECT count(address) from people where address regexp '^[0-9a-zA_Z\.' ]+;[a-zA_Z ]'+;[A-Z ]+;[0-9 ]+$';
'
396 rows returned'

SELECT address from people where address not regexp '^[0-9a-zA_Z\.' ]+;[a-zA_Z ]'+;[A-Z ]+;[0-9 ]+$';
'
- 3 rows returned with missing semicolumns
- They are then located by filtering the people table and manually updated (semicolumns added and applied 
  to the 3 rows identified). 

STEP 3 
- Now it is time to return the strings that are separated by a delimiter  in  the address field and
name each string.
'
SELECT 
substring_index(address, ';', 1) as Street,
 substring_index(substring_index(address, ';', 2),';', -1) as City,
 substring_index(substring_index(address, ';', 3),';', -1) as State,
 substring_index(substring_index(address, ';', 4),';', -1) as ZipCode 
FROM people;

'
STEP 4
- This step is when a new address table is created out of the address field. 
'
CREATE TABLE address (
id INT NOT NULL auto_increment,
street varchar(255) NOT NULL,
city varchar(255) NOT NULL,
state varchar(2) NOT NULL,
zip varchar(10) NOT NULL,
pfk INT,
primary  key (id)
);
'
- pfk is the foreign key to relate to the people table and match correctly and associate each address with a person.

STEP 5
- This step involves inserting the data into the address table.
'
INSERT INTO address(street, city, state, zip, pfk) VALUES (

 substring_index(substring_index(address, ';', 1),';', -1) as street
 substring_index(substring_index(address, ';', 2),';', -1) as city,
 substring_index(substring_index(address, ';', 3),';', -1) as state,
 substring_index(substring_index(address, ';', 4),';', -1) as zip,
 id  
FROM people);

'
This returns an error saying data too long for column 'state' at row 1, so we run the following to clear spaces:
'
INSERT INTO address(street, city, state, zip, pfk) VALUES (

 trim(substring_index(substring_index(address, ';', 1),';', -1)) as street
 trim(substring_index(substring_index(address, ';', 2),';', -1)) as city,
 trim(substring_index(substring_index(address, ';', 3),';', -1)) as state,
 trim(substring_index(substring_index(address, ';', 4),';', -1)) as zip,
 id  
FROM people);

' We then run the following to return the people and address tables together'
SELECT * from company.people, company.address 
where
people.id=address.pfk

'CONCLUSION
- All the fields are now consistent and address field atomic in a separate table. 
- Original intent and integrity of the database have been maintained.
- Data is cleaned and database is normalised using regular expressions, table creation and data insertion'
