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
    photo_url VARCHAR
(255) NOT NULL
);
ORDER BY hire_date DESC

TRUNCATE TABLE employees;

INSERT INTO employees
    (full_name, position, salary, hire_date, photo_url)
VALUES
    ('Alice Johnson', 'Software Engineer', 75000.00, '2022-03-15', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400'),
    ('Bob Smith', 'Data Analyst', 65000.00, '2021-07-22', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400'),
    ('Charlie Brown', 'Project Manager', 85000.00, '2020-11-05', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400'),
    ('Diana Prince', 'UX Designer', 70000.00, '2023-01-10', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400'),
    ('Ethan Hunt', 'DevOps Engineer', 80000.00, '2019-09-30', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400'),
    ('Fiona Gallagher', 'QA Tester', 60000.00, '2022-06-18', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400'),
    ('George Martin', 'Business Analyst', 72000.00, '2021-12-01', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'),
    ('Hannah Lee', 'Frontend Developer', 68000.00, '2020-04-25', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400'),
    ('Ian Somerhalder', 'Backend Developer', 77000.00, '2019-08-14', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400'),
    ('Jenna Fischer', 'HR Manager', 90000.00, '2018-05-03', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400');