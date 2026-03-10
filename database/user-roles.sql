USE master;
GO

-- ============================================================================
-- STEP 1: CREATE SQL SERVER LOGINS
-- ============================================================================

-- Administrator Login
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'iti_admin')
    CREATE LOGIN iti_admin WITH PASSWORD = 'Admin@ITI2024', CHECK_POLICY = ON;
GO

-- Instructor Login
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'iti_instructor')
    CREATE LOGIN iti_instructor WITH PASSWORD = 'Instructor@ITI2024', CHECK_POLICY = ON;
GO

-- Student Login
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'iti_student')
    CREATE LOGIN iti_student WITH PASSWORD = 'Student@ITI2024', CHECK_POLICY = ON;
GO

-- ============================================================================
-- STEP 2: CREATE DATABASE USERS MAPPED TO THE LOGINS
-- ============================================================================

USE ITI_ExamSystem;
GO

-- Administrator User
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'iti_admin')
    CREATE USER iti_admin FOR LOGIN iti_admin;
GO

-- Instructor User
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'iti_instructor')
    CREATE USER iti_instructor FOR LOGIN iti_instructor;
GO

-- Student User
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'iti_student')
    CREATE USER iti_student FOR LOGIN iti_student;
GO

-- ============================================================================
-- STEP 3: ASSIGN ROLES & PERMISSIONS
-- ============================================================================

-- -------------------------------------------------------
-- ROLE 1: Administrator → db_owner
-- -------------------------------------------------------
ALTER ROLE db_owner ADD MEMBER iti_admin;
GO

-- -------------------------------------------------------
-- ROLE 2: Instructor → Read/Write on exam & question tables
-- -------------------------------------------------------

-- Read access on all tables (to view students, courses, etc.)
ALTER ROLE db_datareader ADD MEMBER iti_instructor;
GO

-- Write access ONLY on exam and question related tables
GRANT INSERT, UPDATE, DELETE ON Question      TO iti_instructor;
GRANT INSERT, UPDATE, DELETE ON [Option]      TO iti_instructor;
GRANT INSERT, UPDATE, DELETE ON ModelAnswer   TO iti_instructor;
GRANT INSERT, UPDATE, DELETE ON Exam          TO iti_instructor;
GRANT INSERT, UPDATE, DELETE ON ExamQuestion  TO iti_instructor;
GO

-- Allow instructor to execute stored procedures
GRANT EXECUTE ON GenerateExam               TO iti_instructor;
GRANT EXECUTE ON CorrectExam                TO iti_instructor;
GRANT EXECUTE ON Report_StudentGrades       TO iti_instructor;
GRANT EXECUTE ON Report_StudentsByDepartment TO iti_instructor;
GRANT EXECUTE ON Report_InstructorCourses   TO iti_instructor;
GRANT EXECUTE ON InsertQuestion             TO iti_instructor;
GRANT EXECUTE ON UpdateQuestion             TO iti_instructor;
GRANT EXECUTE ON DeleteQuestion             TO iti_instructor;
GO

-- -------------------------------------------------------
-- ROLE 3: Student → db_datareader (read only)
-- -------------------------------------------------------

-- Read-only access on all tables
ALTER ROLE db_datareader ADD MEMBER iti_student;
GO

-- Allow student to submit answers and view their own results
GRANT INSERT ON StudentExam   TO iti_student;
GRANT INSERT ON StudentAnswer TO iti_student;
GO

-- Allow student to execute only student-related procedures
GRANT EXECUTE ON SubmitExamAnswers TO iti_student;
GO

-- Deny access to sensitive tables (student cannot see other students' answers)
DENY SELECT ON StudentAnswer TO iti_student;
DENY SELECT ON ModelAnswer   TO iti_student;
GO
