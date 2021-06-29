/*Displaying the User basic info   */
SELECT Users.name,
       Users.surname,
       IIF(P.professor_id IS NOT NULL, 1, 0)      as IsProfessor,
       IIF(S.student_id IS NOT NULL, 1, 0)        as IsStudent,
       IIF(CM.course_mentor_id IS NOT NULL, 1, 0) as IsCourceMentor,
       CONCAT(country_name, ' ', state_name, ' ', city_name, ' ', street_name, ' - ', building_num)
FROM Users
         INNER JOIN Addresses ON Users.address_id = Addresses.address_id
         INNER JOIN Streets on Streets.street_id = Addresses.street_id
         INNER JOIN Cites on Cites.city_id = Streets.city_id
         INNER JOIN States on States.state_id = Cites.state_id
         INNER JOIN Countries on Countries.country_id = States.country_id
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

-- Count Students on Street
SELECT street_name,
       (
           SELECT COUNT(*)
           FROM Users
                    INNER JOIN Addresses A on A.address_id = Users.address_id
                    INNER JOIN Streets US on US.street_id = A.street_id
           WHERE US.street_name = Streets.street_name
       ) as users_count
FROM Streets
ORDER BY street_name, users_count DESC;

--Count how many professors, students and course mentors is active in percentage
SELECT CAST((
                SELECT AVG(IIF(is_active = 1, 1.0, 0))
                FROM Students
            ) * 100 as INT) as student,
       CAST((
                SELECT AVG(IIF(is_active = 1, 1.0, 0))
                FROM Professors
            ) * 100 as INT) as professors,
       CAST((
                SELECT AVG(IIF(is_active = 1, 1.0, 0))
                FROM CourseMentors
            ) * 100 as INT) as course_mentors

-- Count how many students takes each course
SELECT C.name, COUNT(*) as count
FROM Students
         INNER JOIN student_course_relationships scr on Students.student_id = scr.student_id
         INNER JOIN Courses C on C.course_id = scr.course_id
GROUP BY C.name
ORDER BY count DESC

-- Display student distribution along years
SELECT study_year,
       FORMAT(CAST(COUNT(*) as FLOAT) / (
           SELECT COUNT(*)
           FROM Students
       ), 'P') as percentage
FROM Students
GROUP BY study_year
ORDER BY study_year
