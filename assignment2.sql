-- Part I – Working with an existing database
-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT * FROM chinook.employee
-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM chinook.employee
WHERE lastname = 'King'
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM chinook.employee
WHERE firstname = 'Andrew' AND reportsto IS NULL
-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM chinook.album
ORDER BY title DESC
-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM chinook.customer
ORDER BY city ASC
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO chinook.genre VALUES (26, 'Orchestra')
INSERT INTO chinook.genre VALUES (27, 'Universal')
-- Task – Insert two new records into Employee table
INSERT INTO chinook.employee VALUES (9, 'Miller', 'John', 'Sales Staff', 7, '1971-05-21', '2005-02-15', '111 Jeffersion Mill RD', 'Calgary', 'AB', 'Canada', 'T1K 2N9', '+1 (403) 568-3304', '+1 (403) 856-2113', 'miller@chinookcorp.com')
INSERT INTO chinook.employee VALUES (10, 'Wathz', 'Kevin', 'Sales Staff', 7, '1971-05-21', '2005-02-15', '111 Jeffersion Mill RD', 'Calgary', 'AB', 'Canada', 'T1K 2N9', '+1 (403) 568-3304', '+1 (403) 856-2113', 'wathz@chinookcorp.com')
-- Task – Insert two new records into Customer table
INSERT INTO chinook.customer VALUES (60, 'Ajup', 'Avatsavirs', null, '3,Raj Bhavan Road', 'Bangalore', null, 'India', '560001', '+91 080 22289999', null, 'ajup_avatsavirs@yahoo.in', 4)
INSERT INTO chinook.customer VALUES (61, 'Nojam', 'Reekpa', null, '12,Community Centre', 'Delhi', null, 'India', '110017', '+91 080 22289999', null, 'nojam_reekpa@yahoo.in', 3)
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE chinook.customer
SET firstname = 'Robert', lastname = 'Walter'
WHERE firstname = 'Aaron' AND lastname = 'Mitchell'
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE chinook.artist
SET name = 'CCR'
WHERE name = 'Creedence Clearwater Revival'
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM chinook.invoice
WHERE billingaddress LIKE 'T%'
-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM chinook.invoice
WHERE total BETWEEN 15 AND 50
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM chinook.employee
WHERE hiredate BETWEEN 'June 1 2003' AND 'March 1 2004'
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM chinook.invoiceline
 WHERE invoiceline.invoiceid IN (
	 SELECT invoice.invoiceid
 FROM chinook.customer
 			INNER JOIN chinook.invoice
 	ON
 		customer.customerid = (
 			SELECT customerid FROM chinook.customer
 			WHERE firstname = 'Robert' AND lastname = 'Walter'
 		)
 		AND
 		invoice.customerid = (
 			SELECT customerid FROM chinook.customer
 			WHERE firstname = 'Robert' AND lastname = 'Walter'
 		)
 );
DELETE FROM chinook.invoice
 WHERE 
 	invoice.customerid = (
 		SELECT customerid FROM chinook.customer
 		WHERE firstname = 'Robert' AND lastname = 'Walter'
 	);
DELETE FROM chinook.customer
 WHERE firstname = 'Robert' AND lastname = 'Walter'
-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE FUNCTION get_time()
RETURNS TIME AS $$
	BEGIN
		RETURN CURRENT_TIME;
	END;
$$ LANGUAGE plpgsql;
-- Task – create a function that returns the length of a mediatype from the mediatype table
 CREATE FUNCTION media_length()
 RETURNS TABLE(length BIGINT) AS $$
 BEGIN 
  RETURN QUERY SELECT COUNT(*) FROM chinook.mediatype;
 END;
 $$ LANGUAGE plpgsql;
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
 CREATE FUNCTION avg_invoices()
 RETURNS TABLE(average NUMERIC) AS $$
 BEGIN 
  RETURN QUERY SELECT AVG(total) FROM chinook.invoice;
 END;
 $$ LANGUAGE plpgsql;
-- Task – Create a function that returns the most expensive track
CREATE FUNCTION expensive_track()
	RETURNS TABLE(most_expensive NUMERIC) AS $$
	BEGIN
		RETURN QUERY SELECT MAX(unitprice) FROM chinook.track;
	END;
	$$ LANGUAGE plpgsql;
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE FUNCTION avg_invoiceprice()
	RETURNS TABLE(avg_price NUMERIC) AS $$
	BEGIN
		RETURN QUERY SELECT AVG(unitprice) FROM chinook.invoiceline;
	END;
	$$ LANGUAGE plpgsql;
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
CREATE FUNCTION employee_age()
	RETURNS TABLE(ln VARCHAR, fn VARCHAR) AS $$
	BEGIN
		RETURN QUERY SELECT lastname, firstname FROM chinook.employee
						WHERE hiredate NOT BETWEEN 'January 1 1900' AND 'January 1 1968';
	END;
	$$ LANGUAGE plpgsql;
-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE FUNCTION select_names()
	RETURNS TABLE(f_name VARCHAR, l_name VARCHAR) AS $$
	BEGIN
		RETURN QUERY SELECT lastname, firstname FROM chinook.employee;
	END;
	$$ LANGUAGE plpgsql;
	
SELECT select_names();
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE FUNCTION updates_employee_personal_information(old_name VARCHAR, new_name VARCHAR, OUT nul INTEGER)
	AS $$
	BEGIN
		UPDATE chinook.employee
		SET firstname = new_name -- lastname = newlast_name ...
		WHERE firstname = old_name;
	END;
	$$ LANGUAGE plpgsql;
-- Task – Create a stored procedure that returns the managers of an employee.
CREATE FUNCTION get_managers_of_an_employee()
	RETURNS TABLE(ml VARCHAR, tl VARCHAR, mf VARCHAR, sl VARCHAR, sf VARCHAR, tl2 VARCHAR) AS $$
	BEGIN
		RETURN QUERY SELECT tb1.lastname AS managers_lastname, tb1.firstname AS managers_firstname, tb1.title,
							tb2.lastname AS subordinate_lastname, tb2.firstname AS subordinate_firstname, tb2.title
					FROM chinook.employee tb1, chinook.employee tb2
					WHERE
						tb1.employeeid = tb2.reportsto
					ORDER BY tb1.lastname;
	END;
	$$ LANGUAGE plpgsql;
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE FUNCTION get_customer_name_company()
	RETURNS TABLE(cl VARCHAR, cf VARCHAR, cc VARCHAR) AS $$
	BEGIN
		RETURN QUERY SELECT customer.lastname, customer.firstname, customer.company FROM chinook.customer;
	END;
	$$ LANGUAGE plpgsql;
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
CREATE FUNCTION delete_invoice(id INTEGER)
	RETURNS VOID AS $$
	BEGIN
		DELETE FROM chinook.invoiceline
		WHERE invoiceline.invoiceid = id;

		DELETE FROM chinook.invoice
		WHERE invoice.invoiceid = id;
	END;
	$$ LANGUAGE plpgsql;
-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE FUNCTION set_record_customer(id INTEGER, f_name VARCHAR, l_name VARCHAR,
										e_mail VARCHAR, OUT nul INTEGER)
	AS $$
	BEGIN
		INSERT INTO chinook.customer (customerid, firstname, lastname, email)
									VALUES (id, f_name, l_name, e_mail);
	END;
	$$ LANGUAGE plpgsql;
-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
CREATE FUNCTION log_trigger_employee_record()
RETURNS TRIGGER AS $$
BEGIN
	DELETE FROM chinook.employee
	WHERE employee.employeeid = NEW.employeeid;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER employee_record_trigger
AFTER INSERT ON chinook.employee
FOR EACH ROW
EXECUTE PROCEDURE log_trigger_employee_record();
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE FUNCTION log_trigger_album_record()
RETURNS TRIGGER AS $$
BEGIN
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER album_record_trigger
AFTER UPDATE ON chinook.album
FOR EACH ROW
EXECUTE PROCEDURE log_trigger_album_record();
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
DELETE FROM chinook.customer
WHERE customer.customerid = 2;
ROLLBACK;
CREATE FUNCTION log_delete_customer()
	RETURNS TRIGGER AS $$
	BEGIN
		RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;
CREATE TRIGGER delete_customer_trigger
AFTER DELETE ON chinook.customer
FOR EACH ROW
EXECUTE PROCEDURE log_delete_customer();
s
-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE FUNCTION log_invoice_over_priced()
	RETURNS TRIGGER AS $$
	BEGIN
		RETURN NULL;
	END;
	$$ LANGUAGE plpgsql;
	
CREATE TRIGGER invoice_over_fifty_trigger
BEFORE DELETE ON chinook.invoice
FOR EACH ROW
WHEN(OLD.total > 50)
EXECUTE PROCEDURE log_invoice_over_priced();
-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT customer.firstname, customer.lastname, invoice.invoiceid FROM chinook.customer INNER JOIN chinook.invoice
ON customer.customerid = invoice.customerid
-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT customer.customerid, customer.firstname, customer.lastname, invoice.invoiceid, invoice.total
FROM chinook.customer FULL OUTER JOIN chinook.invoice
ON customer.customerid = invoice.customerid
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT artist.name, album.title
FROM chinook.album RIGHT JOIN chinook.artist
ON album.artistid = artist.artistid
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM chinook.album CROSS JOIN chinook.artist
ORDER BY artist.name ASC
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT * FROM chinook.employee AS employee_tb1, chinook.employee AS employee_tb2
WHERE employee_tb1.employeeid = employee_tb2.reportsto
