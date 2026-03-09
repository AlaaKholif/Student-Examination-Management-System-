-- Drop database if it exists 
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'ITI_ExamSystem')
BEGIN
    ALTER DATABASE ITI_ExamSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ITI_ExamSystem;
END
GO

-- Create the database
CREATE DATABASE ITI_ExamSystem;
GO