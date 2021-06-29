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

-- How many students take subject and what is avg grade among students in subject
SELECT *,
       FORMAT((
                      CAST(student_counter as FLOAT) / (SELECT COUNT(*) FROM Students WHERE is_active = 1)
                  ), 'P') as percents_from_over_all
FROM (SELECT Subjects.name                              as subject_name,
             (SELECT COUNT(*)
              FROM Students
                       LEFT JOIN student_subject_relationships ssr on Students.student_id = ssr.student_id
                       LEFT JOIN student_course_relationships scr on Students.student_id = scr.student_id
                       LEFT JOIN course_subject_relationships csr on scr.course_id = csr.course_id
              WHERE Subjects.subject_id = csr.subject_id
                 OR Subjects.subject_id = ssr.subject_id
             )                                          as student_counter,
             (SELECT AVG(grade)
              FROM Submissions
                       INNER JOIN Tasks T on T.task_id = Submissions.task_id
              WHERE T.subject_id = Subjects.subject_id) as avg_grade
      FROM Subjects) as snscag
ORDER BY student_counter DESC;

-- Get subject average attendance
SELECT name,
       ROUND((
                         CAST((
                             SELECT COUNT(*)
                             FROM Lessons
                                      INNER JOIN student_lesson_relationships slr
                                                 on Lessons.lesson_id = slr.lesson_id and
                                                    slr.join_datetime < Lessons.end_datetime
                             WHERE Lessons.subject_id = Subjects.subject_id
                         ) as FLOAT) / NULLIF(
                                 ((SELECT COUNT(*) FROM Lessons WHERE Lessons.subject_id = Subjects.subject_id) *
                                  (SELECT COUNT(*)
                                   FROM Students
                                            LEFT JOIN student_subject_relationships ssr
                                                      on Students.student_id = ssr.student_id
                                            LEFT JOIN student_course_relationships scr on Students.student_id = scr.student_id
                                            LEFT JOIN course_subject_relationships csr on scr.course_id = csr.course_id
                                   WHERE Subjects.subject_id = csr.subject_id
                                      OR Subjects.subject_id = ssr.subject_id
                                  ))
                             , 0)
                     * 100), 2) as [attendance_%]
FROM Subjects
ORDER BY [attendance_%] DESC;


-- Get student info with best avg grade on subject
SELECT Sbj.name                       as sbj_name,
       avg_sbj_grade                  as max_sbj_grade,
       CONCAT(U.name, ' ', U.surname) as top_student_name,
       St.student_id                  as top_student_id
FROM (SELECT *,
             RANK() OVER ( PARTITION BY tt2S.subject_id ORDER BY tt2S.avg_sbj_grade DESC) as rank
      FROM (
               SELECT student_id, subject_id, AVG(max_grade) as avg_sbj_grade
               FROM (
                        SELECT T.task_id,
                               S.student_id,
                               T.subject_id,
                               MAX(S.grade) OVER ( PARTITION BY S.student_id) as max_grade
                        FROM Tasks T
                                 INNER JOIN Submissions S on T.task_id = S.task_id
                    ) as tt1S
               GROUP BY student_id, subject_id
           ) as tt2S) as tt3S
         INNER JOIN Subjects Sbj on tt3S.subject_id = Sbj.subject_id
         INNER JOIN Students St on St.student_id = tt3S.student_id
         INNER JOIN Users U on U.user_id = St.user_id
WHERE tt3S.rank = 1
ORDER BY tt3S.subject_id;