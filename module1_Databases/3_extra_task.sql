--REQUIREMETS:
12 Extra task. Implement immutable data trigger. Create new table student_address. Add several rows with test data and do not give acces to update any information inside it. Hint: you can create trigger that will reject any update operation for target table, but save new row with updated (merged with original) data into separate table.

--EXECUTION
--CREATE 2 TABLES: 
CREATE table student_address_updated
(student_id int,
addres CHAR(50),
FOREIGN KEY (student_id) REFERENCES students (student_id)
ON DELETE CASCADE
);

CREATE table student_updated_address
(student_id int,
addres CHAR(50)
);

--CREATE FUNCTION FOR INSERTING TO SEPERATE TABLE
CREATE FUNCTION insert_into_student_updated_address (studentid INT, studentaddress VARCHAR) 
    RETURNS VOID AS $$
BEGIN 
	Insert into student_updated_address (student_id, address) values (studentid,studentaddress);
END; $$ 
LANGUAGE 'plpgsql';

--CREATE TRIGGER FOR INSERTING TO SEPERATE TABLE
CREATE TRIGGER tr_insert AFTER INSERT ON student_address FOR EACH ROW
      EXECUTE PROCEDURE insert_into_student_updated_address();

--ADD RULE INSTEAD UPDATE DO INSERT INTO SEPERATE TABLE
CREATE OR REPLACE RULE replace_update AS ON UPDATE TO student_address
WHERE NEW.address <> OLD.address
DO INSTEAD INSERT INTO student_updated_address VALUES (
                                    old.student_id,
                                    NEW.address
                                );



