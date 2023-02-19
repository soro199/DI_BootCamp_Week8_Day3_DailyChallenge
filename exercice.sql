/*1ere partie*/

--1. Create 2 tables : Customer and Customer profile. They have a One to One relationship.

--a)A customer can have only one profile, and a profile belongs to only one customer
--b)The Customer table should have the columns : id, first_name, last_name NOT NULL
--c)The Customer profile table should have the columns : id, isLoggedIn DEFAULT false (a Boolean), customer_id (a reference to the Customer table)

CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

CREATE TABLE CustomerProfile (
    id SERIAL PRIMARY KEY,
    isLoggedIn BOOLEAN DEFAULT false,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

--2. Insert those customers

--a)John, Doe
--b)Jerome, Lalu
--c)Lea, Rive


INSERT INTO Customer (first_name, last_name)
VALUES
    ('Jean', 'Biche'),
    ('Jérôme', 'Lalu'),
    ('Léa', 'Rive');


--3

INSERT INTO CustomerProfile (isLoggedIn, customer_id)
VALUES
    ((SELECT CASE WHEN EXISTS (SELECT 1 FROM Customer WHERE first_name = 'Jean') THEN true ELSE false END), (SELECT customer_id FROM Customer WHERE first_name = 'Jean')),
    ((SELECT CASE WHEN EXISTS (SELECT 1 FROM Customer WHERE first_name = 'Jérôme') THEN false ELSE true END), (SELECT customer_id FROM Customer WHERE first_name = 'Jérôme'));


--4 Use the relevant types of Joins to display:

--a)The first_name of the LoggedIn customers
--b)All the customers first_name and isLoggedIn columns - even the customers those who don’t have a profile.
--c)The number of customers that are not LoggedIn

--To display the first_name of the LoggedIn customers:
SELECT Customer.first_name
FROM Customer
INNER JOIN CustomerProfile ON Customer.customer_id = CustomerProfile.customer_id
WHERE CustomerProfile.isLoggedIn = true;

--To display all the customers first_name and isLoggedIn columns, including those who don't have a profile:

SELECT Customer.first_name, CustomerProfile.isLoggedIn
FROM Customer
LEFT JOIN CustomerProfile ON Customer.customer_id = CustomerProfile.customer_id;

--To display the number of customers that are not LoggedIn:

SELECT COUNT(Customer.customer_id)
FROM Customer
LEFT JOIN CustomerProfile ON Customer.customer_id = CustomerProfile.customer_id
WHERE CustomerProfile.isLoggedIn = false OR CustomerProfile.isLoggedIn IS NULL;

/*2ieme partie*/

--1. Create a table named Book, with the columns : book_id SERIAL PRIMARY KEY, title NOT NULL, author NOT NULL

CREATE TABLE Book (
    book_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL
);

--2. Insert those books :
--a)Alice In Wonderland, Lewis Carroll
--b)Harry Potter, J.K Rowling
--c)To kill a mockingbird, Harper Lee

INSERT INTO Book (title, author)
VALUES ('Alice In Wonderland', 'Lewis Carroll'),
       ('Harry Potter', 'J.K Rowling'),
       ('To kill a mockingbird', 'Harper Lee');


--Create a table named Student, with the columns : student_id SERIAL PRIMARY KEY, name NOT NULL UNIQUE, age. Make sure that the age is never bigger than 15 (Find an SQL method);

CREATE TABLE Student (
    student_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    age INTEGER CHECK (age <= 15)
);

--Insert those students:
--a)John, 12
--b)Lera, 11
--c)Patrick, 10
--d)Bob, 14

INSERT INTO Student (name, age)
VALUES ('John', 12),
       ('Lera', 11),
       ('Patrick', 10),
       ('Bob', 14);


--Create a table named Library, with the columns :
	--a)book_fk_id ON DELETE CASCADE ON UPDATE CASCADE student_id ON DELETE CASCADE ON UPDATE CASCADE borrowed_date
	--This table, is a junction table for a Many to Many relationship with the Book and Student tables : A student can borrow many books, and a book can be borrowed by many children
	--book_fk_id is a Foreign Key representing the column book_id from the Book table
	--student_fk_id is a Foreign Key representing the column student_id from the Student table
	--The pair of Foreign Keys is the Primary Key of the Junction Table

CREATE TABLE Library (
    book_fk_id INTEGER REFERENCES Book(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    student_fk_id INTEGER REFERENCES Student(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
    borrowed_date DATE,
    PRIMARY KEY (book_fk_id, student_fk_id)
);

--Add 4 records in the junction table, use subqueries.
	--a)the student named John, borrowed the book Alice In Wonderland on the 15/02/2022
	--b)the student named Bob, borrowed the book To kill a mockingbird on the 03/03/2021
	--c)the student named Lera, borrowed the book Alice In Wonderland on the 23/05/2021
	--d)the student named Bob, borrowed the book Harry Potter the on 12/08/2021

INSERT INTO Library (book_fk_id, student_fk_id, borrowed_date)
VALUES ((SELECT book_id FROM Book WHERE title = 'Alice In Wonderland'), (SELECT student_id FROM Student WHERE name = 'John'), '2022-02-15'),
       ((SELECT book_id FROM Book WHERE title = 'To kill a mockingbird'), (SELECT student_id FROM Student WHERE name = 'Bob'), '2021-03-03'),
       ((SELECT book_id FROM Book WHERE title = 'Alice In Wonderland'), (SELECT student_id FROM Student WHERE name = 'Lera'), '2021-05-23'),
       ((SELECT book_id FROM Book WHERE title = 'Harry Potter'), (SELECT student_id FROM Student WHERE name = 'Bob'), '2021-08-12');


--Display the data
	--a)Select all the columns from the junction table
	SELECT * FROM Library;

	--b)Select the name of the student and the title of the borrowed books
	SELECT Student.name, Book.title 
	FROM Library 
	JOIN Student ON Library.student_fk_id = Student.student_id 
	JOIN Book ON Library.book_fk_id = Book.book_id;

	--c)Select the average age of the children, that borrowed the book Alice in Wonderland
	SELECT AVG(Student.age) 
	FROM Library 
	JOIN Student ON Library.student_fk_id = Student.student_id 
	JOIN Book ON Library.book_fk_id = Book.book_id 
	WHERE Book.title = 'Alice In Wonderland';

	--d)Delete a student from the Student table, what happened in the junction table ?
	DELETE FROM Student WHERE name = 'Patrick';



