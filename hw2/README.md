# Домашнее задание №2. Дополнение схемы и демонстрация ограничений

**Вариант №1. Онлайн-курсы (EdTech)**

**Выполнил:** [Твоё ФИО]  
**Группа:** [Твоя группа]

---

## Часть 1. Дополнение схемы

### Новые таблицы

#### Payment — платежи студентов за курсы

**Зачем:** бизнес-требование «Преподаватели получают отчисления от продаж».  
Без таблицы платежей нельзя посчитать сумму вознаграждения преподавателю (частый запрос №5 из ДЗ №1).

**Атрибуты:** id, student_id, course_id, amount, status, created_at, paid_at.

**Ограничения:**
- FK на User и Course — платёж всегда привязан к реальному студенту и курсу.
- CHECK (amount >= 0) — сумма не может быть отрицательной.
- CHECK (status IN ('pending','paid','refunded')) — только 3 допустимых статуса.

**Индексы:** idx_payment_student_id, idx_payment_course_id, idx_payment_status — ускоряют запросы о платежах по студенту, курсу и статусу.

#### LessonCompletion — прохождение уроков

**Зачем:** бизнес-требование «Продумайте, как хранить статус завершения урока».  
Даёт детальную историю: какой урок какой студент прошёл и когда. В Enrollment есть только прогресс курса (0–100%), а не детализация по урокам.

**Атрибуты:** id, student_id, lesson_id, completed_at.

**Ограничения:**
- FK на User и Lesson.
- UNIQUE (student_id, lesson_id) — один урок нельзя пройти дважды.
- ON DELETE CASCADE при удалении урока.

**Индексы:** idx_lesson_completion_student_id, idx_lesson_completion_lesson_id.

### M:N-связи в схеме

Все M:N реализованы через промежуточные таблицы:

| M:N-связь | Промежуточная таблица | Что хранит |
|---|---|---|
| Студент ↔ Курс (запись) | Enrollment | прогресс, дата записи |
| Студент ↔ Курс (платёж) | Payment | сумма, статус, дата |
| Студент ↔ Урок | LessonCompletion | дата прохождения |

**Почему через промежуточную таблицу:** в реляционной модели M:N напрямую невозможно. Промежуточная таблица позволяет хранить атрибуты самой связи и накладывать ограничения (UNIQUE, CHECK).

### Что будет при DROP TABLE Course CASCADE

PostgreSQL каскадно удалит:
- все `Lesson` этого курса,
- все `LessonCompletion` этих уроков,
- все `Enrollment`, `Review`, `Payment`, ссылающиеся на курс.

**Вывод:** удобно для тестовой среды, но опасно в продакшене — обычно используют `RESTRICT`.

### Скриншоты

Список всех 7 таблиц (`\dt`):
![Список таблиц](screenshots/dt_v2.png)

Структура Payment (`\d payment`):
![Payment](screenshots/payment.png)

Структура LessonCompletion (`\d lessoncompletion`):
![LessonCompletion](screenshots/lessoncompletion.png)

---

## Часть 2. Скрипт с демонстрацией нарушений

Файл: [`demo_violations.sql`](demo_violations.sql)

Скрипт содержит 5 блоков `DO $$ ... EXCEPTION ... END $$`, каждый демонстрирует одно нарушение ограничения:

1. **CHECK** — попытка поставить оценку 10 (разрешено 1–5).
2. **FOREIGN KEY** — попытка записать несуществующего студента.
3. **UNIQUE** — повторная запись студента на тот же курс.
4. **NOT NULL** — создание курса без названия.
5. **PRIMARY KEY** — вставка пользователя с существующим id.

Скриншот вывода:
![Нарушения](screenshots/violations.png)

---

## Часть 3. Документирование нарушений

| № | Ограничение | Выполняемый запрос (SQL) | Сообщение СУБД | Понятное сообщение для пользователя | Как исправить |
|---|---|---|---|---|---|
| 1 | CHECK | `INSERT INTO Review (id_course, id_student, rating) VALUES (1, 2, 10)` | `new row for relation "review" violates check constraint "review_rating_check"` | Оценка должна быть от 1 до 5 | Указать rating из диапазона 1–5 |
| 2 | FOREIGN KEY | `INSERT INTO Enrollment (progress, student_id, course_id) VALUES (0, 9999, 1)` | `insert or update on table "enrollment" violates foreign key constraint "enrollment_student_id_fkey"` | Нельзя записать студента, которого нет в базе | Сначала создать пользователя, потом использовать его id |
| 3 | UNIQUE | `INSERT INTO Enrollment (progress, student_id, course_id) VALUES (0, 2, 1)` | `duplicate key value violates unique constraint "enrollment_student_id_course_id_key"` | Студент уже записан на этот курс | Проверить факт записи перед вставкой |
| 4 | NOT NULL | `INSERT INTO Course (title, price, description, teacher_id) VALUES (NULL, 3000, 'Описание', 1)` | `null value in column "title" of relation "course" violates not-null constraint` | У курса обязательно должно быть название | Указать title |
| 5 | PRIMARY KEY | `INSERT INTO "User" (id, password, role, name) VALUES (1, 'hash3', 'student', 'Дубликат')` | `duplicate key value violates unique constraint "User_pkey"` | Пользователь с таким id уже существует | Не указывать id вручную, пусть SERIAL генерирует |

## Выводы

- Ограничения работают на уровне СУБД — данные не могут стать некорректными даже при ошибке в коде приложения.
- Блоки `DO $$ ... EXCEPTION ... END $$` позволяют перехватывать ошибки и выдавать пользователю понятные сообщения.
- Все 5 типов ограничений, заложенных в схему ДЗ №1, сработали корректно.
