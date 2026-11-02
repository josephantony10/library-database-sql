-- Library Database - a simple SQL project.
--
-- The idea: a small library keeps track of books, members, and who
-- borrowed which book. This file builds the tables, adds sample data,
-- and then asks the database some questions (queries).
--
-- How to run it (Terminal, inside this folder):
--   sqlite3 library.db < library.sql
-- To explore it yourself afterwards:
--   sqlite3 library.db
--   (type .tables to see the tables, .quit to leave)

-- Start fresh each time we run the file.
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;

-- TABLE 1: members (the people who borrow books)
CREATE TABLE members (
    member_id INTEGER PRIMARY KEY,   -- unique number for each member
    name      TEXT NOT NULL,
    email     TEXT UNIQUE            -- no two members share an email
);

-- TABLE 2: books
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title   TEXT NOT NULL,
    author  TEXT NOT NULL,
    copies  INTEGER NOT NULL CHECK (copies >= 0)
);

-- TABLE 3: loans (links a member to a book)
-- member_id and book_id are FOREIGN KEYS: they must match a real
-- member and a real book.
CREATE TABLE loans (
    loan_id     INTEGER PRIMARY KEY,
    book_id     INTEGER NOT NULL,
    member_id   INTEGER NOT NULL,
    loan_date   TEXT NOT NULL,
    return_date TEXT,                -- empty (NULL) means not returned yet
    FOREIGN KEY (book_id)   REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- Sample data (made-up people and loans, only for practice)
INSERT INTO members (member_id, name, email) VALUES
    (1, 'Aisha Khan',   'aisha@example.com'),
    (2, 'Rahul Nair',   'rahul@example.com'),
    (3, 'Maria Santos', 'maria@example.com');

INSERT INTO books (book_id, title, author, copies) VALUES
    (1, 'Python Crash Course',          'Eric Matthes',        3),
    (2, 'Computer Networking Basics',   'Sam Taylor',          2),
    (3, 'Introduction to Databases',    'Priya Sharma',        2),
    (4, 'Staying Safe Online',          'Omar Haddad',         1),
    (5, 'Web Design Basics',            'Lena Fischer',        2);

INSERT INTO loans (loan_id, book_id, member_id, loan_date, return_date) VALUES
    (1, 1, 1, '2026-09-01', '2026-09-15'),
    (2, 2, 1, '2026-09-20', NULL),
    (3, 1, 2, '2026-10-02', '2026-10-12'),
    (4, 4, 3, '2026-10-05', NULL),
    (5, 3, 2, '2026-10-10', NULL);

-- Make the output easy to read in Terminal.
.headers on
.mode column

-- QUERY 1: Show all books.
SELECT '--- Query 1: All books ---' AS info;
SELECT book_id, title, author, copies FROM books;

-- QUERY 2: Who borrowed which book? (JOIN combines the three tables)
SELECT '--- Query 2: Who borrowed what ---' AS info;
SELECT members.name, books.title, loans.loan_date
FROM loans
JOIN members ON loans.member_id = members.member_id
JOIN books   ON loans.book_id   = books.book_id
ORDER BY loans.loan_date;

-- QUERY 3: Books that have NOT been returned yet.
SELECT '--- Query 3: Not returned yet ---' AS info;
SELECT members.name, books.title, loans.loan_date
FROM loans
JOIN members ON loans.member_id = members.member_id
JOIN books   ON loans.book_id   = books.book_id
WHERE loans.return_date IS NULL;

-- QUERY 4: How many books has each member borrowed?
SELECT '--- Query 4: Loans per member ---' AS info;
SELECT members.name, COUNT(loans.loan_id) AS total_loans
FROM members
LEFT JOIN loans ON members.member_id = loans.member_id
GROUP BY members.member_id
ORDER BY total_loans DESC;

-- QUERY 5: Books that nobody has ever borrowed.
SELECT '--- Query 5: Never borrowed ---' AS info;
SELECT title
FROM books
WHERE book_id NOT IN (SELECT book_id FROM loans);
