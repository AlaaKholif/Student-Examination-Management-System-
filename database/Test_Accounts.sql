-- 1. Create a Test Instructor (Assuming DepartmentNo is an INT)
INSERT INTO Instructor (InstructorName, DepartmentNo, Email, Password)
VALUES ('Ahmed Ali', 1, 'instructor@iti.com', '123456');

PRINT 'Instructor created: instructor@iti.com / 123456';

-- 2. Create a Test Student
INSERT INTO Student (StudentName, Email, Phone, Password)
VALUES ('Sara Mahmoud', 'student@iti.com', '01012345678', '123456');

PRINT 'Student created: student@iti.com / 123456';