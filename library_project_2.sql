DROP TABLE IF EXISTS branch;

CREATE TABLE branch
				(branch_id VARCHAR(10) PRIMARY KEY,
				manager_id VARCHAR(10),
				branch_address VARCHAR(30),
				contact_no VARCHAR(15)
				);

DROP TABLE IF EXISTS employees;

CREATE TABLE EMPLOYEES
					(emp_id VARCHAR(10) PRIMARY KEY,
					emp_name VARCHAR(40),
					designation VARCHAR(30),
					salary INT,
					branch_id VARCHAR(10) -- FK
					);
					
DROP TABLE IF EXISTS books;

CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

DROP TABLE IF EXISTS members;

CREATE TABLE members
					(member_id VARCHAR(10) PRIMARY KEY,
					member_name VARCHAR(25),
					member_address VARCHAR(75),
					reg_date DATE
					);

DROP TABLE IF EXISTS issued_status;

CREATE TABLE issued_status
						(issued_id VARCHAR(10) PRIMARY KEY,
						issued_member_id VARCHAR(10), -- FK
						issued_book_name VARCHAR(75),
						issued_date DATE,
						issued_book_isbn VARCHAR(25), -- FK
						issued_emp_id VARCHAR(10) -- FK
						);
						
DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status
						(return_id VARCHAR(10) PRIMARY KEY,
						issued_id VARCHAR(10), -- FK
						return_book_name VARCHAR(75),
						return_date DATE,
						return_book_isbn VARCHAR(20)
						);

-- FOREIGN KEYS
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY(issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY(issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY(issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY(branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY(issued_id)
REFERENCES issued_status(issued_id);

SELECT*FROM books;

-- CRUD OPERATIONS

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn,
					book_title,
					category,
					rental_price,
					status,
					author,
					publisher)
VALUES
					('978-1-60129-456-2', 
					'To Kill a Mockingbird', 
					'Classic', 
					6.00, 
					'yes', 
					'Harper Lee', 
					'J.B. Lippincott & Co.');

 SELECT*FROM books;

-- Task 2: Update an Existing Member's Address
 SELECT*FROM members;
 
 UPDATE members
 SET member_address='125 Main St'
 WHERE member_id='C101';

 -- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status
WHERE issued_id = 'IS121'; 

DELETE FROM issued_status
WHERE issued_id='IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT*FROM issued_status 
WHERE issued_emp_id = 'E101';

--END OF CRUD OPERATIONS



-- Task 5: List employees Who Have Issued More Than One Book 

SELECT emp_name
FROM employees t1
JOIN 
issued_status t2
ON t1.emp_id=t2.issued_emp_id
GROUP BY 1
HAVING
COUNT(emp_id)>1;

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables
-- based on query results - each book and total book_issued_cnt**

CREATE TABLE book_ct
AS
SELECT
	issued_book_name,
	COUNT (issued_id) AS count_of_books
	FROM issued_status
	GROUP BY 1;

SELECT* FROM book_ct;	

DROP TABLE IF EXISTS book_ct;

--  OR

CREATE TABLE book_cnts
AS    
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM
book_cnts;

-- Task 7. Retrieve All Books in a Specific Category:

SELECT* FROM books
WHERE category = 'Horror';

-- Task 8: Find Total Rental Income by Category:

SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1

--List Members Who Registered in the Last 700 Days:
--(a)POSTGRESQL
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '700 days' ;   

--(b) MYSQL
SELECT * FROM members
WHERE reg_date >= CURDATE - INTERVAL 700 day ;

-- task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT * FROM branch;
SELECT * FROM  employees;

SELECT t2.branch_id,
t1.emp_id,
t1.emp_name,
t2.manager_id,
t3.emp_name AS manager_name,
t2.branch_address
FROM
employees t1
LEFT JOIN
branch t2
USING (branch_id) 
JOIN employees t3
ON t2.manager_id=t3.emp_id;


-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE books_price_greater_than_seven
AS
SELECT * FROM books
WHERE 
rental_price> 7.00;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT * FROM issued_status;
SELECT* FROM return_status;

SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;