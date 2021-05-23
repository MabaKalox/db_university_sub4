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
         LEFT JOIN CourseMentors CM on Users.user_id = CM.user_id

/* Displaying the submissions of Tasks and their descrition */
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
         INNER JOIN Users on Professors.user_id = Users.user_id


/* Hobbies */

SELECT Users.name, Users.surname, Hobbies.name, Hobbies.description
FROM Users
         INNER JOIN user_hobby_relationships ON user_hobby_relationships.user_id = Users.user_id
         INNER JOIN Hobbies ON Hobbies.hobby_id = user_hobby_relationships.hobby_id

-- Get all student subjects

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
       )                              as was_on_lecture_times
FROM Students
         INNER JOIN Users U on Students.user_id = U.user_id
         INNER JOIN student_course_relationships scr on Students.student_id = scr.student_id
         INNER JOIN Courses C on scr.course_id = C.course_id
         INNER JOIN course_subject_relationships csr on C.course_id = csr.course_id
         LEFT JOIN student_subject_relationships ssr on Students.student_id = ssr.student_id
         INNER JOIN Subjects on csr.subject_id = Subjects.subject_id OR ssr.subject_id = Subjects.subject_id
ORDER BY C.name,
         User_name_surname
