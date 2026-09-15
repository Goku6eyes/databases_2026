TRUNCATE Review, Enrollment, LessonCompletion, Payment, Lesson, Course, "User"
    RESTART IDENTITY CASCADE;

INSERT INTO "User" (password, role, name)
VALUES ('hash1', 'teacher', 'Иван Петров');

INSERT INTO "User" (password, role, name)
VALUES ('hash2', 'student', 'Анна Сидорова');

INSERT INTO Course (title, price, description, teacher_id)
VALUES ('SQL для начинающих', 5000.00, 'Базовый курс по SQL', 1);

INSERT INTO Lesson (title, price, content, course_id)
VALUES ('Введение в SQL', 0, 'Что такое SQL', 1);

INSERT INTO Enrollment (progress, student_id, course_id)
VALUES (0, 2, 1);

INSERT INTO Review (id_course, id_student, rating)
VALUES (1, 2, 5);

DO $$
BEGIN
    INSERT INTO Review (id_course, id_student, rating)
    VALUES (1, 2, 10);
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '[CHECK] Нельзя поставить оценку 10. Рейтинг должен быть от 1 до 5. Техническая ошибка: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    INSERT INTO Enrollment (progress, student_id, course_id)
    VALUES (0, 9999, 1);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE '[FOREIGN KEY] Нельзя записать на курс несуществующего студента (student_id=9999). Техническая ошибка: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    INSERT INTO Enrollment (progress, student_id, course_id)
    VALUES (0, 2, 1);
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '[UNIQUE] Студент уже записан на этот курс. Повторная запись невозможна. Техническая ошибка: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    INSERT INTO Course (title, price, description, teacher_id)
    VALUES (NULL, 3000.00, 'Описание', 1);
EXCEPTION
    WHEN not_null_violation THEN
        RAISE NOTICE '[NOT NULL] У курса обязательно должно быть название. Техническая ошибка: %', SQLERRM;
END;
$$;

DO $$
BEGIN
    INSERT INTO "User" (id, password, role, name)
    VALUES (1, 'hash3', 'student', 'Дубликат');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '[PRIMARY KEY] Пользователь с id=1 уже существует. Первичный ключ должен быть уникальным. Техническая ошибка: %', SQLERRM;
END;
$$;