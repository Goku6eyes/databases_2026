CREATE TABLE Payment (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES "User"(id),
    course_id INTEGER NOT NULL REFERENCES Course(id),
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'paid', 'refunded')),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    paid_at TIMESTAMP
);
CREATE INDEX idx_payment_student_id ON Payment(student_id);
CREATE INDEX idx_payment_course_id ON Payment(course_id);
CREATE INDEX idx_payment_status ON Payment(status);

CREATE TABLE LessonCompletion (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES "User"(id),
    lesson_id INTEGER NOT NULL REFERENCES Lesson(id) ON DELETE CASCADE,
    completed_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, lesson_id)
);
CREATE INDEX idx_lesson_completion_student_id ON LessonCompletion(student_id);
CREATE INDEX idx_lesson_completion_lesson_id ON LessonCompletion(lesson_id);