# Домашнее задание №1. От бизнес-требований к физической модели

**Вариант №1. Онлайн-курсы (EdTech)**

**Выполнил:** [Виноградов Алексей Дмитриевич]  
**Группа:** [ДЭ 18-25]

---

## Описание бизнес-домена

Платформа онлайн-образования. Пользователи регистрируются, выбирают курсы и проходят обучение. Каждый курс состоит из нескольких уроков. Преподаватели создают курсы. Студенты записываются на курсы и оставляют отзывы с оценкой от 1 до 5.

---

## 1. Концептуальная модель

### Сущности

- **User** — пользователь платформы (студент, преподаватель или администратор).
- **Course** — курс, созданный преподавателем.
- **Lesson** — урок, входящий в курс.
- **Enrollment** — запись студента на курс.
- **Review** — отзыв студента о курсе.

### Связи

| Связь | Кардинальность | Описание |
|---|---|---|
| User → Course | 1:M | Преподаватель создаёт много курсов |
| Course → Lesson | 1:M | Курс содержит много уроков |
| User → Enrollment | 1:M | Студент имеет много записей на курсы |
| Course → Enrollment | 1:M | На курс записано много студентов |
| User → Review | 1:M | Студент оставляет много отзывов |
| Course → Review | 1:M | Курс получает много отзывов |

**Связь M:N между User и Course** реализована через промежуточную сущность `Enrollment`.

### ER-диаграмма (концептуальная)

![Концептуальная модель](er-diagram.png)

---

## 2. Логическая модель

### User

| Атрибут | Тип | Ключ | Ограничения |
|---|---|---|---|
| id | SERIAL | PK | |
| password | VARCHAR(255) | | NOT NULL |
| role | VARCHAR(20) | | NOT NULL, CHECK IN ('student','teacher','admin') |
| name | VARCHAR(255) | | NOT NULL |

### Course

| Атрибут | Тип | Ключ | Ограничения |
|---|---|---|---|
| id | SERIAL | PK | |
| title | VARCHAR(255) | | NOT NULL |
| price | DECIMAL(10,2) | | NOT NULL, CHECK (price >= 0) |
| description | TEXT | | |
| teacher_id | INTEGER | FK → User(id) | NOT NULL |

### Lesson

| Атрибут | Тип | Ключ | Ограничения |
|---|---|---|---|
| id | SERIAL | PK | |
| title | VARCHAR(255) | | NOT NULL |
| price | DECIMAL(10,2) | | NOT NULL, CHECK (price >= 0) |
| content | TEXT | | |
| course_id | INTEGER | FK → Course(id) | NOT NULL, ON DELETE CASCADE |

### Enrollment

| Атрибут | Тип | Ключ | Ограничения |
|---|---|---|---|
| id | SERIAL | PK | |
| progress | INTEGER | | NOT NULL, CHECK BETWEEN 0 AND 100 |
| student_id | INTEGER | FK → User(id) | NOT NULL |
| enrolled_at | TIMESTAMP | | NOT NULL, DEFAULT NOW() |
| course_id | INTEGER | FK → Course(id) | NOT NULL |
| | | UNIQUE | (student_id, course_id) |

### Review

| Атрибут | Тип | Ключ | Ограничения |
|---|---|---|---|
| id | SERIAL | PK | |
| id_course | INTEGER | FK → Course(id) | NOT NULL |
| id_student | INTEGER | FK → User(id) | NOT NULL |
| rating | INTEGER | | NOT NULL, CHECK BETWEEN 1 AND 5 |
| | | UNIQUE | (id_student, id_course) |

### Кардинальность и тип связей

| Связь | Кардинальность | Тип |
|---|---|---|
| User → Course (teacher_id) | 1:M | Неидентифицирующая |
| Course → Lesson (course_id) | 1:M | Неидентифицирующая |
| User → Enrollment (student_id) | 1:M | Неидентифицирующая |
| Course → Enrollment (course_id) | 1:M | Неидентифицирующая |
| User → Review (id_student) | 1:M | Неидентифицирующая |
| Course → Review (id_course) | 1:M | Неидентифицирующая |

**Почему все связи неидентифицирующие:** каждая сущность имеет собственный суррогатный первичный ключ (`id`). Дочерняя сущность не зависит от родителя в плане идентификации — она может существовать самостоятельно.

### Влияние бизнес-требований на модель

- **«Преподаватели создают курсы»** → поле `teacher_id` в `Course` (FK на User).
- **«Курс состоит из уроков»** → поле `course_id` в `Lesson` (FK на Course).
- **«Студенты записываются на курсы»** → сущность `Enrollment` с FK на User и Course.
- **«Студенты оставляют отзывы и оценивают 1–5»** → сущность `Review` с CHECK на rating.
- **«Прогресс обучения»** → поле `progress` в `Enrollment`.
- **«Разделение на студентов и преподавателей»** → поле `role` в User вместо отдельных таблиц.

### Влияние бизнес-требований на ограничения

- **UNIQUE (student_id, course_id) в Enrollment** — запрет повторной записи на один и тот же курс.
- **UNIQUE (id_student, id_course) в Review** — один студент оставляет не более одного отзыва на курс.
- **CHECK (rating BETWEEN 1 AND 5)** — оценка строго от 1 до 5, как указано в бизнес-требовании.
- **CHECK (progress BETWEEN 0 AND 100)** — прогресс измеряется в процентах.
- **CHECK (price >= 0)** — курс не может стоить отрицательно.
- **DECIMAL(10,2) для price** — точное хранение денежных сумм.
- **ON DELETE CASCADE в Lesson** — при удалении курса его уроки удаляются автоматически.
- **VARCHAR(20) для role вместо отдельных таблиц** — упрощает модель, достаточно для текущих требований.
- **TIMESTAMP для enrolled_at** — фиксирует точное время записи.

---

## 3. Физическая модель

SQL-скрипт для PostgreSQL: [`schema.sql`](schema.sql)

```sql
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
```

### Скриншоты выполнения в папке scrinshots

---

## 4. Частые запросы

1. **Список всех курсов с именем преподавателя и количеством записавшихся студентов.**
2. **Топ-10 курсов по средней оценке отзывов и их количеству.**
3. **Все уроки конкретного курса, отсортированные по порядку.**
4. **История обучения студента: на какие курсы записался, какой прогресс и когда завершил.**
5. **Средняя оценка по каждому курсу и по каждому преподавателю.**

---