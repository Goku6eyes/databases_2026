# ДЗ №2. Часть 3. Документирование нарушений

| № | Ограничение | Выполняемый запрос (SQL) | Сообщение СУБД | Понятное сообщение для пользователя | Как исправить |
|---|---|---|---|---|---|
| 1 | CHECK | `INSERT INTO Review (id_course, id_student, rating) VALUES (1, 2, 10)` | `new row for relation "review" violates check constraint "review_rating_check"` | Оценка должна быть от 1 до 5 | Указать rating из диапазона 1–5 |
| 2 | FOREIGN KEY | `INSERT INTO Enrollment (progress, student_id, course_id) VALUES (0, 9999, 1)` | `insert or update on table "enrollment" violates foreign key constraint "enrollment_student_id_fkey"` | Нельзя записать студента, которого нет в базе | Сначала создать пользователя, потом использовать его id |
| 3 | UNIQUE | `INSERT INTO Enrollment (progress, student_id, course_id) VALUES (0, 2, 1)` | `duplicate key value violates unique constraint "enrollment_student_id_course_id_key"` | Студент уже записан на этот курс. Повторная запись невозможна | Проверить факт записи перед вставкой |
| 4 | NOT NULL | `INSERT INTO Course (title, price, description, teacher_id) VALUES (NULL, 3000, 'Описание', 1)` | `null value in column "title" of relation "course" violates not-null constraint` | У курса обязательно должно быть название | Указать title |
| 5 | PRIMARY KEY | `INSERT INTO "User" (id, password, role, name) VALUES (1, 'hash3', 'student', 'Дубликат')` | `duplicate key value violates unique constraint "User_pkey"` | Пользователь с таким id уже существует | Не указывать id вручную, пусть SERIAL генерирует |

## Выводы

- Ограничения работают на уровне СУБД — данные не могут стать некорректными, даже если в коде приложения есть ошибка.
- Блоки `DO $$ ... EXCEPTION ... END $$` позволяют перехватывать ошибки и выдавать пользователю понятные сообщения вместо технических.
- Все 5 типов ограничений, заложенных в схему ДЗ 1, сработали корректно.
