
-- Drop existing tables if they exist
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS teachers CASCADE;
DROP TABLE IF EXISTS courses CASCADE;

-- Create tables
CREATE TABLE teachers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    subject VARCHAR(100)
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    teacher_id INTEGER REFERENCES teachers(id),
    syllabus TEXT
);

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INTEGER,
    course_id INTEGER REFERENCES courses(id)
);

-- Insert data into teachers
INSERT INTO teachers (name, subject) VALUES
('Mr. Smith', 'Mathematics'),
('Ms. Rose', 'Physics'),
('Dr. Green', 'Chemistry');

-- Insert data into courses
INSERT INTO courses (title, teacher_id, syllabus) VALUES
('Algebra I', 1, 'Introduction to algebraic expressions and equations'),
('Quantum Mechanics', 2, 'Advanced topics in quantum theory'),
('Organic Chemistry', 3, 'Structures, reactions, and synthesis of organic compounds');

-- Insert data into students
INSERT INTO students (name, age, course_id) VALUES
('Alice Johnson', 20, 1),
('Bob Carter', 22, 2),
('Clara Oswald', 21, 3),
('David Tennant', 23, 1);
