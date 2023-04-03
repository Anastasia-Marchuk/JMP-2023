Requirements:
1. Design database for CDP program. Your DB should store information about students (name, surname, date of birth, phone numbers, primary skill, created_datetime, updated_datetime etc.), subjects (subject name, tutor, etc.) and exam results (student, subject, mark).
2. Please add appropriate constraints (primary keys, foreign keys, indexes, etc.).
3. Design such kind of database for PostrgeSQL. Show your design in some suitable way (PDF, PNG, etc). (1 point)


--CREATION TABLES:
1. TABLE ‘STUDENTS’
CREATE TABLE IF NOT EXISTS students (
student_id SERIAL,
name  TEXT CHECK (name !~ '[@#$]+'),
surname VARCHAR(30) NOT NULL,
birth_date DATE CHECK (birth_date> '1992.01.01'),
phone_number numeric,
created_datetime DATE not null default CURRENT_TIMESTAMP,
PRIMARY KEY (student_id)
ON DELETE CASCADE
);

2. TABLE ‘SUBJECT’
CREATE TABLE IF NOT EXISTS subject(
subject_id SERIAL,
subject_name VARCHAR(30) NOT NULL,
mentor_name TEXT,
PRIMARY KEY (subject_id)	
);

3. TABLE ‘EXAM_RESULT’
CREATE TABLE IF NOT EXISTS exam_result(
student_id int ,
subject_id int,
mark NUMERIC,
CONSTRAINT fk_students
FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
FOREIGN KEY (subject_id) REFERENCES subject(subject_id) ON DELETE CASCADE
FOREIGN KEY (subject_id) REFERENCES subject(subject_id) ON UPDATE CASCADE
);


--CREATION INDEXES:
1 INDEX FOR TABLE ‘STUDENTS’:
CREATE INDEX ix_students_name_surname
ON students (name, surname);

2 INDEX FOR TABLE ‘SUBJECT’:
CREATE INDEX ix_subject_subject_name
ON subject(subject_name);

3 INDEX FOR TABLE ‘EXAM_RESULT’:
CREATE INDEX ix_exam_result_mark
ON exam_result(mark);


--HOW TO CHECK SIZE OF INDEXES?
SELECT pg_size_pretty (pg_indexes_size('students'));

--CHECK SIZE ALL TABLES AND INDEXES:
SELECT
   relname  as name_tables,
   pg_size_pretty(pg_total_relation_size(relid)) As "Total Size",
   pg_size_pretty(pg_indexes_size(relid)) as "Index Size",
   pg_size_pretty(pg_relation_size(relid)) as "Actual Size"
   FROM pg_catalog.pg_statio_user_tables 
ORDER BY pg_total_relation_size(relid) DESC;

-- FUNCTION CREATION
1 GETTING RANDOM STUDENT NAME 
CREATE FUNCTION generate_student_random_name() RETURNS TEXT LANGUAGE SQL AS $$ 
select (array['Anastasiya', 'Volha', 'Siri','Jim','Peter','Tony','Rosa','Sam', 'Don','Ron','Fred', 'Sasha','Sara', 'Ron','Dima','Pavel'])[random()*(16-1)+1];
$$;
2 GETTING RANDOM STUDENT SURNAME
CREATE FUNCTION generate_random_surname () RETURNS TEXT LANGUAGE SQL AS $$ 
Select (array['Marchuk', 'Petrov', 'Solviev','Pupkin','Zajcev','Shyshko','Osipov', 'Bobrov', 'Petrosiuk','Sorokin','Solovej', 'Michaluk','Moroz','Yard'])[random()*(14-1)+1];
$$;

3 GETTING RANDOM STUDENT_ID:
CREATE FUNCTION get_random_student_id() RETURNS INT LANGUAGE SQL AS $$ 
Select student_id from students 
order by random() limit 1; 
$$;

4 GETTING RANDOM SUBJECT_ID:
CREATE FUNCTION generate_random_subject_id() RETURNS INT LANGUAGE SQL AS $$ 
Select subject_id from subject 
order by random() limit 1; 
$$;

5 GETTING RANDOM SUBJECT_ID:
CREATE FUNCTION generate_random_student_id() RETURNS INT LANGUAGE SQL AS $$ 
Select student_id from subject 
order by random() limit 1; 
$$;

6 GETTING RANDOM SUBJECT
CREATE FUNCTION generate_random_subject() RETURNS TEXT LANGUAGE SQL AS $$ 
select (array['economics', 'medecine', 'computer science','mathematics','algebra','biology', 'chemistry'])[ random()*(7-1)+1];
$$;

7 GETTING RANDOM MENTOR NAME
CREATE FUNCTION generate_mentor_random_name() RETURNS TEXT LANGUAGE SQL AS $$ 
select (array['Alex A.', 'Alex B.', 'Alex C.', 'John M.', 'Sara A.', 'Sara B.','Jimmy K.','Kate L.','Leyla N.'])[random()*(9-1)+1]; 
$$;

8 GETTING RANDOM MARK:
CREATE FUNCTION get_random_mark() RETURNS INT LANGUAGE SQL AS $$ 
Select floor (random()*(10-1+1)+1); 
$$;

9 FILLING TABLE ‘STUDENTS’ 
CREATE FUNCTION insert_data_into_students_table() RETURNS VOID LANGUAGE PLPGSQL AS $$
DECLARE name TEXT= INITCAP(generate_student_random_name());
DECLARE surname TEXT= INITCAP(generate_random_surname ());
DECLARE birth_date DATE= CAST( NOW() - INTERVAL '100 year' * RANDOM() AS DATE);
DECLARE phone_number BIGINT=CAST(1000000000 + FLOOR(RANDOM() * 9000000000) AS BIGINT);

BEGIN
INSERT INTO students (name, surname, birth_date , phone_number ) VALUES (first_name, last_name, date_of_birth, mobile_no);
END;

10 FILLING TABLE ‘SUBJECT’ 
CREATE FUNCTION insert_data_into_subject_table() RETURNS VOID LANGUAGE PLPGSQL AS $$
DECLARE subject_name TEXT= INITCAP(generate_random_subject());
DECLARE mentor_name TEXT= INITCAP(generate_mentor_random_name());

BEGIN
INSERT INTO subject (subject_name, mentor_name) VALUES (subject_name, mentor_name);
END;

11 FILLING TABLE ‘EXAM_RESULT’ 
CREATE FUNCTION insert_data_into_exam_result() RETURNS TABLE  LANGUAGE SQL AS $$
DECLARE student_id INT= INITCAP(generate_random_student_id());
DECLARE subject_id INT= INITCAP(generate_random_subject_id());
DECLARE mark INT= INITCAP(generate_random_mark());

BEGIN
INSERT INTO exam_result (student_id, subject_id, mark ) VALUES (student_id, subject_id, mark);
END;






