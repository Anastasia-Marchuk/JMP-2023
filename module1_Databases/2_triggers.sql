--Requirements:
5. Add trigger that will update column updated_datetime to current date in case of updating any of student. 
6. Add validation on DB level that will check username on special characters (reject student name with next characters '@', '#', '$')
7. Create snapshot that will contain next data: student name, student surname, subject name, mark (snapshot means that in case of changing some data in source table – your snapshot should not change). 
8. Create function that will return average mark for input user. 
9. Create function that will return avarage mark for input subject name. 
10. Create function that will return student at "red zone" (red zone means at least 2 marks <=3).

--EXECUTION
5.
CREATE TRIGGER update_students_on_update_date
     AFTER UPDATE ON students
     BEGIN
    NEW.updated_date = now();
    RETURN NEW;
END;

6. 
name  TEXT CHECK (name ~ '^[a-zA-Z]+$')

7. 
CREATE table data_snap_march 
as 
Select s.student_id, s.name,s.surname, sub.subject_name, exr.mark 
from students s
left join exam_result exr on s.student_id=exr.student_id
left join subject sub on sub.subject_id=exr.subject_id
order by s.student_id;

8.
CREATE OR REPLACE FUNCTION student_avg_mark (studentname TEXT, studentsurname VARCHAR) 
    RETURNS TABLE (
        student_id INT,
        name TEXT,
		surname VARCHAR,
		avg_scope NUMERIC
) 
AS $$
BEGIN
    RETURN QUERY 
	Select s.student_id, s.name,s.surname,round(CAST(AVG(mark) AS dec(12,6)),2) as avg_scope 
from exam_result er
left join students s on s.student_id=er.student_id
Where s.name=studentname and s.surname=studentsurname
Group by s.student_id,s.name,s.surname;
END; $$ 

LANGUAGE 'plpgsql';

9.
CREATE OR REPLACE FUNCTION subject_avg_mark (name VARCHAR) 
    RETURNS TABLE (
		subject_name VARCHAR,
		avg_scope DECIMAL
) 
AS $$
BEGIN
    RETURN QUERY 
	Select s.subject_name, CAST(AVG(mark) AS dec(12,2)) as avg_scope
from exam_result exr
inner join subject s on s.subject_id=exr.subject_id
where s.subject_name=name
Group by s.subject_name;
END; $$ 

LANGUAGE 'plpgsql';

10. 
CREATE OR REPLACE FUNCTION red_zone_students () 
    RETURNS TABLE (
        student_id INT,
        name TEXT,
		surname VARCHAR,
		num_failed_exam BIGINT
) 
AS $$
BEGIN
    RETURN QUERY 
	Select s.student_id, s.name,s.surname,count (s.student_id) as num_failed_exam from exam_result er
left join students s on s.student_id=er.student_id
Where er.mark<=3 
Group by s.student_id, er.mark,s.name,s.surname
HAVING COUNT(s.student_id) > 2;
END; $$ 

LANGUAGE 'plpgsql';


