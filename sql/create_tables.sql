IF
    db_id('university_db') IS NULL
CREATE
    DATABASE university_db

GO

use university_db

drop table if exists Files
drop table if exists Submissions
drop table if exists Tasks
drop table if exists student_lesson_relationships
drop table if exists Lessons
drop table if exists student_subject_relationships
drop table if exists professor_subject_relationships
drop table if exists course_subject_relationships
drop table if exists Subjects
drop table if exists student_course_relationships
drop table if exists Courses
drop table if exists CourseMentors
drop table if exists Students
drop table if exists professor_degree_relationships
drop table if exists Professors
drop table if exists Degrees
drop table if exists user_hobby_relationships
drop table if exists Hobbies
drop table if exists Users
drop table if exists Addresses
drop table if exists PostalCodes
drop table if exists Streets
drop table if exists Cites
drop table if exists States
drop table if exists Countries


CREATE TABLE Countries
(
    country_id   int IDENTITY (1, 1) PRIMARY KEY,
    country_name nvarchar(30) NOT NULL UNIQUE,
)

CREATE TABLE States
(
    state_id   int IDENTITY (1, 1) PRIMARY KEY,
    state_name nvarchar(50),
    country_id int NOT NULL,
    CONSTRAINT FK_country_id FOREIGN KEY (country_id)
        REFERENCES Countries (country_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE Cites
(
    city_id   int IDENTITY (1, 1) PRIMARY KEY,
    city_name nvarchar(50) NOT NULL UNIQUE,
    state_id  int         NOT NULL,
    CONSTRAINT FK_state_id FOREIGN KEY (state_id)
        REFERENCES States (state_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE Streets
(
    street_id   int IDENTITY (1, 1) PRIMARY KEY,
    street_name nvarchar(120) NOT NULL UNIQUE,
    city_id     int          NOT NULL,
    CONSTRAINT FK_city_id FOREIGN KEY (city_id)
        REFERENCES Cites (city_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE PostalCodes
(
    postal_id   int IDENTITY (1, 1) PRIMARY KEY,
    postal_code nvarchar(12) NOT NULL UNIQUE,
)

CREATE TABLE Addresses
(
    address_id int IDENTITY (1, 1) PRIMARY KEY,
    building_num  nvarchar(12) NOT NULL,
    flat_num   int,
    postal_id  int          NOT NULL,
    CONSTRAINT FK_postal_id FOREIGN KEY (postal_id)
        REFERENCES PostalCodes (postal_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    street_id  int          NOT NULL,
    CONSTRAINT FK_street_id FOREIGN KEY (street_id)
        REFERENCES Streets (street_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE Users
(
    user_id           int IDENTITY (1, 1) PRIMARY KEY,
    name              nvarchar(255) NOT NULL,
    surname           nvarchar(255) NOT NULL,
    phone             varchar(20)  NOT NULL,
    email             varchar(255) NOT NULL,
    registration_time datetime     NOT NULL,
    is_active         bit DEFAULT 0,
    address_id        int          NOT NULL,
    CONSTRAINT FK_address_id FOREIGN KEY (address_id)
        REFERENCES Addresses (address_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE Hobbies
(
    hobby_id    int IDENTITY (1, 1) PRIMARY KEY,
    name        varchar(40) NOT NULL,
    description varchar(420)
)

CREATE TABLE user_hobby_relationships
(
    user_id  int NOT NULL,
    CONSTRAINT FK_user_id_0 FOREIGN KEY (user_id)
        REFERENCES Users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    hobby_id int NOT NULL,
    CONSTRAINT FK_hobby_id FOREIGN KEY (hobby_id)
        REFERENCES Hobbies (hobby_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (user_id, hobby_id)
)

CREATE TABLE Degrees
(
    degree_id int identity (1,1) PRIMARY KEY,
    name      varchar(120) NOT NULL
)

CREATE TABLE Professors
(
    professor_id int identity (1,1) PRIMARY KEY,
    is_active    bit DEFAULT 0,
    user_id      int NOT NULL,
    CONSTRAINT FK_user_id_1 FOREIGN KEY (user_id)
        REFERENCES Users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE professor_degree_relationships
(
    professor_id int NOT NULL,
    CONSTRAINT FK_professor_id_2 FOREIGN KEY (professor_id)
        REFERENCES Professors (professor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    degree_id    int NOT NULL,
    CONSTRAINT FK_degree_id FOREIGN KEY (degree_id)
        REFERENCES Degrees (degree_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (professor_id, degree_id)
)

CREATE TABLE Students
(
    student_id int identity (1,1) PRIMARY KEY,
    study_year TINYINT NOT NULL,
    is_active  bit DEFAULT 0,
    user_id    int     NOT NULL UNIQUE,
    CONSTRAINT FK_user_id_2 FOREIGN KEY (user_id)
        REFERENCES Users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE CourseMentors
(
    course_mentor_id int identity (1,1) PRIMARY KEY,
    is_active        bit DEFAULT 0 NOT NULL,
    user_id          int           NOT NULL,
    CONSTRAINT FK_user_id_3 FOREIGN KEY (user_id)
        REFERENCES Users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE Courses
(
    course_id        int IDENTITY (1, 1) PRIMARY KEY,
    name             varchar(255)   NOT NULL,
    description      nvarchar(2048) NOT NULL,
    course_mentor_id int            NOT NULL,
    CONSTRAINT FK_course_mentor_id FOREIGN KEY (course_mentor_id)
        REFERENCES CourseMentors (course_mentor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE student_course_relationships
(
    student_id int NOT NULL,
    CONSTRAINT FK_student_id_0 FOREIGN KEY (student_id)
        REFERENCES Students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    course_id  int NOT NULL,
    CONSTRAINT FK_course_id_0 FOREIGN KEY (course_id)
        REFERENCES Courses (course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    UNIQUE (student_id, course_id)
)

CREATE TABLE Subjects
(
    subject_id  int IDENTITY (1, 1) PRIMARY KEY,
    name        varchar(255) NOT NULL UNIQUE,
    description nvarchar(1024)
)

--It is Only for some special cases when student takes
--subject which is outside of student course
CREATE TABLE student_subject_relationships
(
    student_id int NOT NULL,
    CONSTRAINT FK_student_id_1 FOREIGN KEY (student_id)
        REFERENCES Students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    subject_id int NOT NULL,
    CONSTRAINT FK_subject_id_0 FOREIGN KEY (subject_id)
        REFERENCES Subjects (subject_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (student_id, subject_id)
)

CREATE TABLE course_subject_relationships
(
    course_id  int NOT NULL,
    CONSTRAINT FK_course_id_1 FOREIGN KEY (course_id)
        REFERENCES Courses (course_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    subject_id int NOT NULL,
    CONSTRAINT FK_subject_id_1 FOREIGN KEY (subject_id)
        REFERENCES Subjects (subject_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (course_id, subject_id)
)

CREATE TABLE professor_subject_relationships
(
    professor_id int NOT NULL,
    CONSTRAINT FK_professor_id_0 FOREIGN KEY (professor_id)
        REFERENCES Professors (professor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    subject_id   int NOT NULL,
    CONSTRAINT FK_subject_id_2 FOREIGN KEY (subject_id)
        REFERENCES Subjects (subject_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (professor_id, subject_id)
)

CREATE TABLE Lessons
(
    lesson_id      int identity (1,1) PRIMARY KEY,
    purpose        nvarchar(240) NOT NULL,
    start_datetime datetime      NOT NULL,
    end_datetime   datetime      NOT NULL,
    location       nvarchar(128) NOT NULL,
    record         varchar(128),
    subject_id     int           NOT NULL,
    CONSTRAINT FK_subject_id_3 FOREIGN KEY (subject_id)
        REFERENCES Subjects (subject_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    professor_id   int           NOT NULL,
    CONSTRAINT FK_professor_id_1 FOREIGN KEY (professor_id)
        REFERENCES Professors (professor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

CREATE TABLE student_lesson_relationships
(
    join_datetime datetime,

    student_id    int NOT NULL,
    CONSTRAINT FK_student_id_2 FOREIGN KEY (student_id)
        REFERENCES Students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    lesson_id     int NOT NULL,
    CONSTRAINT FK_lesson_id FOREIGN KEY (lesson_id)
        REFERENCES Lessons (lesson_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    UNIQUE (student_id, lesson_id),
)

CREATE TABLE Tasks
(
    task_id          int IDENTITY (1, 1) PRIMARY KEY,
    description      nvarchar(2048) NOT NULL,
    time_of_creating datetime       NOT NULL,
    deadline         datetime,
    is_visible       bit DEFAULT 0,

    subject_id       int            NOT NULL,
    CONSTRAINT FK_subject_id_4 FOREIGN KEY (subject_id)
        REFERENCES Subjects (subject_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
)

CREATE TABLE Submissions
(
    submission_id     int identity (1,1) PRIMARY KEY,
    submission_time   datetime NOT NULL,
    grading_time      datetime,
    grade             tinyint,
    student_comment   nvarchar(320),
    professor_comment nvarchar(320),

    task_id           int      NOT NULL,
    CONSTRAINT FK_task_id FOREIGN KEY (task_id)
        REFERENCES Tasks (task_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    student_id        int      NOT NULL,
    CONSTRAINT FK_student_id_3 FOREIGN KEY (student_id)
        REFERENCES Students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
)

CREATE TABLE Files
(
    file_id       int IDENTITY (1, 1) PRIMARY KEY,
    original_name nvarchar(255) NOT NULL,
    saved_path    varchar(255)  NOT NULL,
    timestamp     timestamp     NOT NULL,

    submission_id int           NOT NULL,
    CONSTRAINT FK_student_id_4 FOREIGN KEY (submission_id)
        REFERENCES Submissions (submission_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
)