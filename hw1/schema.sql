DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Enrollment CASCADE;
DROP TABLE IF EXISTS Lesson CASCADE;
DROP TABLE IF EXISTS Course CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;

CREATE TABLE "User" (
    id SERIAL PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
    name VARCHAR(255) NOT NULL
);

CREATE TABLE Course (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    description TEXT,
    teacher_id INTEGER NOT NULL REFERENCES "User"(id)
);
CREATE INDEX idx_course_teacher_id ON Course(teacher_id);

CREATE TABLE Lesson (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    content TEXT,
    course_id INTEGER NOT NULL REFERENCES Course(id) ON DELETE CASCADE
);
CREATE INDEX idx_lesson_course_id ON Lesson(course_id);

CREATE TABLE Enrollment (
    id SERIAL PRIMARY KEY,
    progress INTEGER NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    student_id INTEGER NOT NULL REFERENCES "User"(id),
    enrolled_at TIMESTAMP NOT NULL DEFAULT NOW(),
    course_id INTEGER NOT NULL REFERENCES Course(id),
    UNIQUE (student_id, course_id)
);
CREATE INDEX idx_enrollment_student_id ON Enrollment(student_id);
CREATE INDEX idx_enrollment_course_id ON Enrollment(course_id);

CREATE TABLE Review (
    id SERIAL PRIMARY KEY,
    id_course INTEGER NOT NULL REFERENCES Course(id),
    id_student INTEGER NOT NULL REFERENCES "User"(id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    UNIQUE (id_student, id_course)
);
CREATE INDEX idx_review_id_course ON Review(id_course);
CREATE INDEX idx_review_id_student ON Review(id_student);