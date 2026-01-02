DROP TABLE IF EXISTS employees;
CREATE TABLE
IF NOT EXISTS employees
(
    id INT
    AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR
(100) NOT NULL,
    position VARCHAR
(100) NOT NULL,
    salary DECIMAL
(10,2) NOT NULL,
    hire_date DATE NOT NULL,
    UNIQUE KEY
(full_name)
);

TRUNCATE TABLE employees;

INSERT INTO employees
    (full_name, position, salary, hire_date)
VALUES
    ('Alice Johnson', 'Software Engineer', 75000.00, '2022-03-15'),
    ('Bob Smith', 'Data Analyst', 65000.00, '2021-07-22'),
    ('Charlie Brown', 'Project Manager', 85000.00, '2020-11-05'),
    ('Diana Prince', 'UX Designer', 70000.00, '2023-01-10'),
    ('Ethan Hunt', 'DevOps Engineer', 80000.00, '2019-09-30'),
    ('Fiona Gallagher', 'QA Tester', 60000.00, '2022-06-18'),
    ('George Martin', 'Business Analyst', 72000.00, '2021-12-01'),
    ('Hannah Lee', 'Frontend Developer', 68000.00, '2020-04-25'),
    ('Ian Somerhalder', 'Backend Developer', 77000.00, '2019-08-14'),
    ('Jenna Fischer', 'HR Manager', 90000.00, '2018-05-03');
