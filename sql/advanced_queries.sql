-- Professors degree distribution on Courses
SELECT csr.course_id as course_id, Degrees.name as degree_name
INTO tmp_table
FROM Professors
         INNER JOIN professor_subject_relationships psr on Professors.professor_id = psr.professor_id
         INNER JOIN course_subject_relationships csr on psr.subject_id = csr.subject_id
         INNER JOIN professor_degree_relationships pdr on Professors.professor_id = pdr.professor_id
         INNER JOIN Degrees on Degrees.degree_id = pdr.degree_id;
SELECT Courses.name,
       (SELECT count(*)
        FROM tmp_table
        WHERE tmp_table.course_id = Courses.course_id
          AND tmp_table.degree_name LIKE '%Associate%') as associates_count,
       (SELECT count(*)
        FROM tmp_table
        WHERE tmp_table.course_id = Courses.course_id
          AND tmp_table.degree_name LIKE '%Bachelor%')  as backelors_count,
       (SELECT count(*)
        FROM tmp_table
        WHERE tmp_table.course_id = Courses.course_id
          AND tmp_table.degree_name LIKE '%Master%')    as masters_count,
       (SELECT count(*)
        FROM tmp_table
        WHERE tmp_table.course_id = Courses.course_id
          AND tmp_table.degree_name LIKE '%Doctor%')    as doctors_count
FROM Courses
ORDER BY doctors_count DESC, masters_count DESC, backelors_count DESC;
DROP TABLE tmp_table;

-- Get all student subjects, attendance at this subject and avg grade
SELECT Students.student_id,
       CONCAT(U.name, ' ', U.surname) as User_name_surname,
       C.name                         as student_course,
       Subjects.name,
       FORMAT(COALESCE((SELECT AVG(IIF(slr.join_datetime < Lessons.end_datetime, 1.0, 0))
                        FROM Lessons
                                 INNER JOIN student_lesson_relationships slr on Lessons.lesson_id = slr.lesson_id
                        WHERE Lessons.subject_id = csr.subject_id), 0)
           , 'P')                     as attendance,
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

-- How many percent of submission for tasks were made in time
SELECT Subjects.name,
       FORMAT(
               AVG(CASE
                       WHEN S.submission_time < Tasks.deadline THEN 1.0
                       ELSE 0 END),
               'P') as percentage
FROM Subjects
         INNER JOIN Tasks on Subjects.subject_id = Tasks.subject_id
         INNER JOIN Submissions S on Tasks.task_id = S.task_id
GROUP BY Subjects.name
ORDER BY AVG(
                 IIF(S.submission_time < Tasks.deadline, 1.0, 0.0)
             ) DESC
