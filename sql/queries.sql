/*Displaying the User basic info   */
SELECT Users.name,
       Users.surname,
       IIF(P.professor_id IS NOT NULL, 1, 0)      as IsProfessor,
       IIF(S.student_id IS NOT NULL, 1, 0)        as IsStudent,
       IIF(CM.course_mentor_id IS NOT NULL, 1, 0) as IsCourceMentor,
       Addresses.country,
       Addresses.city,
       Addresses.street
FROM Users
         INNER JOIN Addresses ON Users.address_id = Addresses.address_id
         LEFT JOIN Professors P on Users.user_id = P.user_id
         LEFT JOIN Students S on Users.user_id = S.user_id
         LEFT JOIN CourseMentors CM on Users.user_id = CM.user_id;

/* Displaying the submissions of Tasks and their description */
SELECT Users.name,
       Users.surname,
       Submissions.grading_time,
       Submissions.grade,
       Tasks.description,
       Submissions.student_comment,
       Submissions.professor_comment,
       IIF(Submissions.submission_time <= Tasks.deadline, 1, 0) as isSubmittedInTime
FROM Students
         INNER JOIN Users ON Students.user_id = Users.user_id
         INNER JOIN Submissions ON Students.student_id = Submissions.student_id
         INNER JOIN Tasks ON Tasks.task_id = Submissions.task_id
ORDER BY IIF(Submissions.grade IS NULL, 1, 0),
         Students.student_id;


/* Displays the lessons info */

SELECT Users.name    as ProfessorName,
       Users.surname as ProfessorSurname,
       Subjects.name as SubjectName,
       Lessons.location,
       Lessons.start_datetime,
       Lessons.end_datetime
FROM Lessons
         INNER JOIN Subjects ON Subjects.subject_id = Lessons.subject_id
         INNER JOIN Professors ON Professors.professor_id = Lessons.professor_id
         INNER JOIN Users on Professors.user_id = Users.user_id;


/* Hobbies */

SELECT Users.name, Users.surname, Hobbies.name, Hobbies.description
FROM Users
         INNER JOIN user_hobby_relationships ON user_hobby_relationships.user_id = Users.user_id
         INNER JOIN Hobbies ON Hobbies.hobby_id = user_hobby_relationships.hobby_id
ORDER BY Hobbies.hobby_id;

-- Get all student subjects, attendance at this subject and avg grade

SELECT Students.student_id,
       CONCAT(U.name, ' ', U.surname) as User_name_surname,
       C.name                         as student_course,
       Subjects.name,
       (
           SELECT COUNT(*)
           FROM Lessons
           WHERE Lessons.subject_id = csr.subject_id
       )                              as lessons_was,
       (
           SELECT COUNT(*)
           FROM Lessons
                    INNER JOIN student_lesson_relationships slr on Lessons.lesson_id = slr.lesson_id
           WHERE Lessons.subject_id = csr.subject_id
             AND slr.join_datetime < Lessons.end_datetime
       )                              as was_on_lecture_times,
       (
           SELECT AVG(grade)
           FROM Submissions
                    INNER JOIN Tasks T on T.task_id = Submissions.task_id
           WHERE Submissions.student_id = Students.student_id
       )                              as average_grade
FROM Students
         INNER JOIN Users U on Students.user_id = U.user_id
         INNER JOIN student_course_relationships scr on Students.student_id = scr.student_id
         INNER JOIN Courses C on scr.course_id = C.course_id
         INNER JOIN course_subject_relationships csr on C.course_id = csr.course_id
         LEFT JOIN student_subject_relationships ssr on Students.student_id = ssr.student_id
         INNER JOIN Subjects on csr.subject_id = Subjects.subject_id OR ssr.subject_id = Subjects.subject_id
ORDER BY C.name,
         User_name_surname;

-- How many students take subject

SELECT Subjects.name as subject_name,
       (SELECT COUNT(*)
        FROM Students
                 LEFT JOIN student_subject_relationships ssr on Students.student_id = ssr.student_id
                 LEFT JOIN student_course_relationships scr on Students.student_id = scr.student_id
                 LEFT JOIN course_subject_relationships csr on scr.course_id = csr.course_id
        WHERE Subjects.subject_id = csr.subject_id
           OR Subjects.subject_id = ssr.subject_id
       )             as student_counter
FROM Subjects
ORDER BY student_counter DESC;

-- Professors degree distribution on Courses

SELECT Courses.name,
       (SELECT count(*)
        FROM Professors
                 INNER JOIN professor_subject_relationships psr on Professors.professor_id = psr.professor_id
                 INNER JOIN course_subject_relationships csr on psr.subject_id = csr.subject_id
                 INNER JOIN professor_degree_relationships pdr on Professors.professor_id = pdr.professor_id
                 INNER JOIN Degrees on Degrees.degree_id = pdr.degree_id
        WHERE csr.course_id = Courses.course_id
          AND Degrees.name LIKE '%Associate%') as associates_count,
       (SELECT count(*)
        FROM Professors
                 INNER JOIN professor_subject_relationships psr on Professors.professor_id = psr.professor_id
                 INNER JOIN course_subject_relationships csr on psr.subject_id = csr.subject_id
                 INNER JOIN professor_degree_relationships pdr on Professors.professor_id = pdr.professor_id
                 INNER JOIN Degrees on Degrees.degree_id = pdr.degree_id
        WHERE csr.course_id = Courses.course_id
          AND Degrees.name LIKE '%Bachelor%')  as backelors_count,
       (SELECT count(*)
        FROM Professors
                 INNER JOIN professor_subject_relationships psr on Professors.professor_id = psr.professor_id
                 INNER JOIN course_subject_relationships csr on psr.subject_id = csr.subject_id
                 INNER JOIN professor_degree_relationships pdr on Professors.professor_id = pdr.professor_id
                 INNER JOIN Degrees on Degrees.degree_id = pdr.degree_id
        WHERE csr.course_id = Courses.course_id
          AND Degrees.name LIKE '%Master%')    as masters_count,
       (SELECT count(*)
        FROM Professors
                 INNER JOIN professor_subject_relationships psr on Professors.professor_id = psr.professor_id
                 INNER JOIN course_subject_relationships csr on psr.subject_id = csr.subject_id
                 INNER JOIN professor_degree_relationships pdr on Professors.professor_id = pdr.professor_id
                 INNER JOIN Degrees on Degrees.degree_id = pdr.degree_id
        WHERE csr.course_id = Courses.course_id
          AND Degrees.name LIKE '%Doctor%')    as doctors_count
FROM Courses
ORDER BY (Courses.course_id);

-- Count Students on Street

SELECT DISTINCT Addresses.street,
       (
           SELECT COUNT(*)
           FROM Users
           INNER JOIN Addresses A on A.address_id = Users.address_id
           WHERE A.street = Addresses.street
           ) as users_count
FROM Addresses
ORDER BY users_count DESC;
