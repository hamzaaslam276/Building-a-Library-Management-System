-- Step 01  (Basic Database Setup & Data Insertion)
-- Create Database
create database LibraryDB;
-- Use Database
use librarydb;
-- Create Table Books
create table Books(book_id INT Primary Key,title VARCHAR(50),
author VARCHAR(50),
genre VARCHAR(50),
year_published INT);
-- Insert Data into Books Table
INSERT INTO books (book_id, title, author, genre, year_published) VALUES
(1, 'Python Crash Course', 'Eric Matthes', 'Python', 2019),
(2, 'Python for Data Analysis', 'Wes McKinney', 'Data Science', 2017),
(3, 'Hands-On Machine Learning', 'Aurélien Géron', 'Data Science', 2019),
(4, 'Fundamentals of Data Engineering', 'Joe Reis and Matt Housley', 'Data Engineering', 2022),
(5, 'Learning MySQL', 'Vinicius M. Grippa and Sergey Kuzmichev', 'MySQL', 2021);

-- Step 02   (Simple Queries & Data Retrieval)
-- Retrieve all books
select * from books; 
-- Find books by a specific author
select * from books where author = 'eric matthes';
-- Find books published after 2019
select * from books where year_published > 2019;
-- Count the number of books in each genre
select genre, count(*) from books group by genre;

-- Step 03   (Adding Constraints & Modifying Data)
-- Modify the Books Table to add constraints
alter table books add unique (title);
alter table books modify year_published int not null;
-- Update genre for a specific book
update books set genre = 'Advance Python' where genre = 'python';
-- Delete a book by book_id
delete from books where book_id = 2;

-- Step 04  (Advanced Queries with Joins)
-- Create a new Authors table
Create table Authors(author_id INT Primary Key,name VARCHAR(50),birth_year INT);
-- Insert Data into Authors Table
INSERT INTO Authors (author_id, name, birth_year) VALUES
(1, 'Bano Qudsia', 1928),
(2, 'Ashfaq Ahmed', 1925),
(3, 'Intizar Hussain', 1923),
(4, 'Mohsin Hamid', 1971),
(5, 'Kamila Shamsie', 1973);
-- Add author_id column to Books table as foreign key
ALTER TABLE Books ADD author_id INT;
-- Add a foreign key to the Books table, linking the author_id in Authors to the Books table.
ALTER TABLE Books
ADD CONSTRAINT fk_author
FOREIGN KEY (author_id)
REFERENCES Authors(author_id);
-- INNER JOIN: Retrieve books with their authors
select * from books as a inner join authors as b on a.book_id = b.author_id;
-- LEFT JOIN: Retrieve all books and authors
select * from books as a left join authors as b on a.book_id = b.author_id;

-- Step 05 Data Integrity with Constraints & Foreign Keys
Create table Borrowers(borrower_id INT Primary Key,
borrower_name VARCHAR(30),
borrow_date DATE);
-- Add foreign key to Books table
ALTER TABLE Books ADD COLUMN borrower_id INT;
-- Create foreign key relationship
ALTER TABLE Books
ADD CONSTRAINT fk_borrower FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id) ON DELETE CASCADE;
-- Insert Borrowers data
insert into Borrowers (borrower_id, borrower_name, borrow_date) 
values 
(1, 'Hamza', '2025-02-09'),
(2, 'Majid', '2025-02-08'),
(3, 'Saleem', '2025-02-07');
-- Assign borrowed books to borrowers
UPDATE Books SET borrower_id = 1 WHERE book_id = 3;
UPDATE Books SET borrower_id = 2 WHERE book_id = 4;
-- Retrieve books borrowed by a specific borrower
SELECT Books.title, Borrowers.borrower_name 
FROM Books 
JOIN Borrowers ON Books.borrower_id = Borrowers.borrower_id 
WHERE Borrowers.borrower_name = 'hamza';

-- Step 06. Subqueries and Aggregation 
-- Find the average year of publication for books in each genre
select genre, avg(year_published) as avg_year from books group by genre;
-- Find the book with the highest year_published
select * from books where year_published = (select max(year_published) from books);
-- Find books with marks greater than the average year published
select * from books where year_published > (select avg(year_published) from Books);
-- View Creation & Data Manipulation
-- Create a view book_id, title, author_name, and borrower_name for all books
create view BookBorrowerDetails as select books.book_id, books.title,
 authors.name as author_name, borrowers.borrower_name
from Books 
join Authors on books.author_id = Authors.author_id
left join Borrowers on books.book_id = Borrowers.borrower_id;
-- Retrieve data from the view
select * from BookBorrowerDetails;
-- Drop the view
drop view BookBorrowerDetails;
-- Step 08. Stored Procedures & Triggers
-- Create a stored procedure to update book genre by book_id
DELIMITER //
CREATE PROCEDURE UpdateBookGenre(IN book_id INT, IN new_genre VARCHAR(30))
BEGIN
    UPDATE Books SET genre = new_genre WHERE book_id = book_id;
END //
DELIMITER ;

-- Call the stored procedure
CALL UpdateBookGenre(1, 'Fantasy/Adventure');

-- Create a trigger to automatically update borrow_date when a new borrower is added
DELIMITER //
CREATE TRIGGER UpdateBorrowDate 
AFTER INSERT ON Borrowers
FOR EACH ROW 
BEGIN
    UPDATE Books SET borrow_date = NOW() WHERE borrower_id = NEW.borrower_id;
END //
DELIMITER ;
-- Step 09. Normalization
-- Given BookDetails table (un-normalized)
CREATE TABLE BookDetails (
    book_id INT,
    title VARCHAR(50),
    author_name VARCHAR(50),
    genre VARCHAR(20),
    publisher_name VARCHAR(50),
    publisher_address VARCHAR(50),
    borrower_name VARCHAR(50),
    borrow_date DATE
);

-- Normalize: Create separate tables for Books, Authors, Publishers, Borrowers
CREATE TABLE Book (
    book_id INT PRIMARY KEY,
    title VARCHAR(50),
    genre VARCHAR(20),
    publisher_id INT,
    author_id INT
);

CREATE TABLE Author (
    author_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Publishers (
    publisher_id INT PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255)
);

CREATE TABLE Borrower (
    borrower_id INT PRIMARY KEY,
    name VARCHAR(255),
    borrow_date DATE
);

-- Create foreign key relationships
ALTER TABLE Book ADD FOREIGN KEY (author_id) REFERENCES Author(author_id);
ALTER TABLE Book ADD FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id);

-- Insert data into normalized tables and query them
select * from books