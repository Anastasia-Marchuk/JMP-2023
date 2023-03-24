---- REQUIREMENTS---------------
1. Design database for CDP program. Your DB should store information about students (name, surname, date of birth, phone numbers, primary skill, created_datetime, updated_datetime etc.), subjects (subject name, tutor, etc.) and exam results (student, subject, mark).
2. Please add appropriate constraints (primary keys, foreign keys, indexes, etc.).
3. Design such kind of database for PostrgeSQL. Show your design in some suitable way (PDF, PNG, etc). (1 point)


---- FUNCTION CREATION----------
--1. GETTING RANDOM STUDENT NAME 
CREATE FUNCTION generate_student_random_name() RETURNS varchar LANGUAGE SQL AS $$ 
select (array['Anastasiya', 'Volha', 'Siri','Jim','Peter','Tony','Rosa','Sam', 'Don','Ron','Fred', 'Sasha','Sara', 'Ron','Dima','Pavel'])[random()*(16-1)+1];
$$;
--2. GETTING RANDOM STUDENT SURNAME
CREATE FUNCTION generate_random_surname () RETURNS varchar LANGUAGE SQL AS $$ 
Select (array['Marchuk', 'Petrov', 'Solviev','Pupkin','Zajcev','Shyshko','Osipov', 'Bobrov', 'Petrosiuk','Sorokin','S', 'Michaluk','M.','Yard'])[random()*(14-1)+1];
$$;

--3 GETTING RANDOM STUDENT_ID:
CREATE FUNCTION generate_max_id () RETURNS int LANGUAGE SQL AS $$ 
SELECT max(id) 
FROM student;
$$;

--4. GETTING RANDOM SUBJECT_ID:
CREATE FUNCTION generate_random_subject_id() RETURNS INT LANGUAGE SQL AS $$ 
Select subject_id from subject 
order by random() limit 1; 
$$;

--5. GETTING RANDOM PRIMARY_SKILL:
CREATE FUNCTION generate_random_primary_skill () RETURNS varchar LANGUAGE SQL AS $$ 
Select (array['creativity', 'critical thinking', 'active listening','communication','teamwork','stress management','organization', 'kindness', 'Adaptability'])[random()*(9-1)+1];
$$;

--6.INSERT DATA INTO TABLE STUDENT:
CREATE OR REPLACE FUNCTION insert_data_into_students_table() RETURNS VOID LANGUAGE PLPGSQL AS $$
DECLARE id int= generate_max_id()+1;
DECLARE name varchar= generate_student_random_name();
DECLARE surname varchar= INITCAP(generate_random_surname ());
DECLARE dob DATE= NOW();
DECLARE primary_skill varchar= INITCAP(generate_random_primary_skill());
DECLARE created_datetime timestamp= CURRENT_TIMESTAMP;
DECLARE updated_datetime  timestamp= null;

BEGIN
INSERT INTO student (id,name, surname, dob , primary_skill,created_datetime,updated_datetime)
VALUES (id,name, surname, dob , primary_skill,created_datetime,updated_datetime);
END;

--7. GETTING RANDOM SUBJECT
CREATE OR REPLACE FUNCTION generate_random_subject() RETURNS varchar LANGUAGE SQL AS $$ 
select (array['economics', 'medecine', 'computer science','mathematics','algebra','biology', 'chemistry'])[ random()*(7-1)+1];
$$;

--8. GETTING RANDOM TUTOR NAME
CREATE OR REPLACEFUNCTION generate_random_tutor() RETURNS varchar LANGUAGE SQL AS $$ 
select (array['Alex A.', 'Alex B.', 'Alex', 'John Mos', 'Sara A.', 'Sara','Jimmy K.','Kate Liuk','Leyla N.'])[random()*(9-1)+1]; 
$$;

--9. FILLING TABLE ‘SUBJECT’ 
CREATE OR REPLACE FUNCTION insert_data_into_subject_table() 
RETURNS void AS 
' DECLARE name varchar= INITCAP(generate_random_subject());
DECLARE tutor varchar= generate_random_tutor();
BEGIN 
INSERT INTO subject (name, tutor ) VALUES (name, tutor); 
END;' LANGUAGE plpgsql;

--10. GETTING RANDOM MARK:
CREATE FUNCTION get_random_mark() RETURNS INT LANGUAGE SQL AS $$ 
Select floor (random()*(10-1+1)+1); 
$$;

--11. GETTING RANDOM SUBJECT_ID:
CREATE FUNCTION generate_random_subject_id() RETURNS INT LANGUAGE SQL AS $$ 
Select id from subject 
order by random() limit 1; 
$$;

--12 GETTING RANDOM STUDENT_ID:
CREATE FUNCTION generate_random_student_id() RETURNS INT LANGUAGE SQL AS $$ 
Select id from student 
order by random() limit 1; 
$$;


--13 FILLING TABLE ‘exam_result’ 
CREATE OR REPLACE FUNCTION insert_data_into_exam_result() 
RETURNS void AS 
' DECLARE student_id INT= generate_random_student_id();
DECLARE subject_id INT= generate_random_subject_id();
DECLARE mark INT= get_random_mark();
BEGIN 
INSERT INTO exam_result (student_id, subject_id,mark ) 
VALUES (student_id, subject_id,mark); 
END;' LANGUAGE plpgsql;


---- EXECUTION ---------------
--1.Select all primary skills that contain more than one word (please note that both ‘-‘ and ‘ ’ could be used as a separator)
Select distinct primary_skill from student
where primary_skill like '% %' or primary_skill like '%-%';


--2.Select all students who does not have second name (it is absent or consists from only one letter/letter with dot)
Select * from student
where surname is null or surname like '_' or surname like '_.';


--3.Select number of students passed exams for each subject and order result by number of student descending.
Select count(*) from (
Select student.name,student.surname 
    From student 
	left join exam_result e on e.student_id=student.id
    left join subject sub on e.subject_id=sub.id
    where mark> 3
    Group by student.name,student.surname  having count(distinct sub.name) =5)as t;


--4. Select number of students with the same exam marks for each subject
Select count(*) from (
Select s.id,s.name,s.surname,sub.name
    From student s
	left join exam_result e on e.student_id=s.id
    left join subject sub on e.subject_id=sub.id
	where e.mark>3
	Group by s.id,s.name,s.surname,sub.name 
	Having count(sub.name)>=2
	order by 1) as t;


--5. Select students who passed at least two exams for different subject. 
Select student.name,student.surname 
    From student 
	left join exam_result e on e.student_id=student.id
    left join subject sub on e.subject_id=sub.id
    where mark> 3
    Group by student.name,student.surname  having count(distinct sub.name) >1


--6. Select students who passed at least two exams for the same subject.
Select s.id,s.name,s.surname
    From student s
	left join exam_result e on e.student_id=s.id
    left join subject sub on e.subject_id=sub.id
	where e.mark>3
	Group by s.id,s.name,s.surname
	Having count(distinct sub.name)>=2
	order by 1;


--7. Select all subjects which exams passed only students with the same primary skills.   
Select name, count(name)  from(
select s.primary_skill,sub.name as "name"  from exam_result e
inner join subject sub on sub.id=e.subject_id
inner join student s on s.id=e.student_id
Where e.mark>3
Group by s.primary_skill,sub.name 
order by 2) as t
GROUP BY name
HAVING count(name)=1;


--8.Select all subjects which exams passed only students with the different primary skills. It means that all students passed the exam for the one subject must have different primary skill.
Select sub_name from(
    Select subjet_name as "sub_name", count(distinct primary_skill) as "num_diff_skills" from(	
	Select  s.primary_skill as "primary_skill",sub.name as "subjet_name", e.mark
    from student s
	left join exam_result e on e.student_id=s.id
        left join subject sub on e.subject_id=sub.id
	left join exam_result skill on skill.student_id=s.id
	where e.mark>3 
	Group by s.id,s.name,s.surname,	primary_skill,sub.name,e.mark 
	order by 2,1) as t
	Group by subjet_name) as t8
	Full  join 
   (Select count(*) as "num_students_passed_exam", subjet_name from(
    Select  s.name as "name",s.surname,sub.name as "subjet_name"
    from student s
	left join exam_result e on e.student_id=s.id
        left join subject sub on e.subject_id=sub.id
	left join exam_result skill on skill.student_id=s.id
	where e.mark>3 
	Group by s.name,s.surname,sub.name
	order by 3,2) as t
	Group by subjet_name order by 1)as t9 on t9.subjet_name=t8.sub_name
	where num_diff_skills=num_students_passed_exam;


--9. Select students who does not pass any exam using each the following operator.
-Outer join
-Subquery with ‘not in’ clause
-Subquery with ‘any ‘ clause Check which approach is faster for 1000, 10K, 100K exams and 10, 1K, 100K students

--Number all exams for each student:
select s.name,s.surname,count(sub.name) as "num_all_exam" from exam_result e
inner join subject sub on sub.id=e.subject_id
inner join student s on s.id=e.student_id
Group by s.name,s.surname
order by 1;

--Number all failed exam for each student;
select s.name,s.surname,count(sub.name) as "num_failed_exam" from exam_result e
inner join subject sub on sub.id=e.subject_id
inner join student s on s.id=e.student_id
Where e.mark<3
Group by s.name,s.surname
order by 1;

--OUTER JOIN
Select id_student,name,num_failed_exam from(
select s.id as "id_student",s.name as "name",s.surname,count(sub.name) as "num_failed_exam" from exam_result e
inner join subject sub on sub.id=e.subject_id
inner join student s on s.id=e.student_id
Where e.mark<4
Group by s.id,s.name,s.surname
order by 1) as t2
FULL JOIN
(Select id, name_student,num_all_exam from(
select s.id as "id",s.name as "name_student",s.surname,count(sub.name) as "num_all_exam" from exam_result e
inner join subject sub on sub.id=e.subject_id
inner join student s on s.id=e.student_id
Group by s.id,s.name,s.surname
order by 1) as t1) as t4
on t4.id=t2.id_student
where num_failed_exam=num_all_exam;

--NOT IN
Select distinct student.id, student.name, student.surname from student
inner join exam_result e on student.id=e.student_id
where student.id not in (
Select distinct s.id from student s
inner join exam_result e on s.id=e.student_id
Where e.mark>3);


--10. Select all students whose average mark is bigger than overall average mark
Select AVG(mark) from exam_result;
Select s.name,s.surname, avg(e.mark) as "student_AVG_mark"
from student s
inner join exam_result e on e.student_id=s.id
GROUP BY s.name,s.surname having avg(e.mark)>(Select AVG(mark) from exam_result);


--11. Select top 5 students who passed their last exam better than average students.
Select id,name from(
	Select
    distinct s.id
	,s.name,s.surname,e.mark
    from student s
	left join exam_result e on e.student_id=s.id
    left join subject sub on e.subject_id=sub.id
	Where e.mark is not null
	Group by  s.id,e.mark
	,s.name,s.surname
	order by e.mark desc) as t
	Group by 1,2
	LIMIT 5;


--12.Select biggest mark for each student and add text description for the mark (use COALESCE and WHEN operators) 
--In case if student has not passed any exam ‘not passed' should be returned.
--If student mark is 1,2,3 – it should be returned as ‘BAD’
--If student mark is 4,5,6 – it should be returned as ‘AVERAGE’
--If student mark is 7,8 – it should be returned as ‘GOOD’
--If student mark is 9,10 – it should be returned as ‘EXCELLENT’
Select distinct student.id, student.name, student.surname,MAX(e.mark) from student
inner join exam_result e on student.id=e.student_id
GROUP by student.id, student.name, student.surname
order by 1;

SELECT name, surname,best_mark,
CASE best_mark WHEN 1 THEN 'bad'
       WHEN 2 THEN 'bad'
	   WHEN 3 THEN 'bad'
	   WHEN 4 THEN 'AVERAGE'
	   WHEN 5 THEN 'AVERAGE'
	   WHEN 6 THEN 'AVERAGE'
	   WHEN 7 THEN 'GOOD'
	   WHEN 8 THEN 'GOOD'
	   WHEN 9 THEN 'EXCELLENT'
	   WHEN 10 THEN 'EXCELLENT'
              ELSE 'NOT PASSED'
END
from (
Select distinct student.id, student.name as "name", student.surname as "surname",MAX(e.mark) as "best_mark" from student
inner join exam_result e on student.id=e.student_id
GROUP by student.id, student.name, student.surname
order by 1) as t;


--13.Select number of all marks for each mark type (‘BAD’, ‘AVERAGE’,…) 
Select view, count (view) as "number_of_marks" from
(SELECT mark, 
CASE mark  WHEN 1 THEN 'BAD'
           WHEN 2 THEN 'BAD'
	   WHEN 3 THEN 'BAD'
	   WHEN 4 THEN 'AVERAGE'
	   WHEN 5 THEN 'AVERAGE'
	   WHEN 6 THEN 'AVERAGE'
	   WHEN 7 THEN 'GOOD'
	   WHEN 8 THEN 'GOOD'
	   WHEN 9 THEN 'EXCELLENT'
	   WHEN 10 THEN 'EXCELLENT'
           ELSE 'NOT PASSED' 
END AS "view"
from (Select mark from exam_result) as t) as t2
GROUP BY  "view"
Order by 1;



















