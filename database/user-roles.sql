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