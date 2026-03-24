-- 1. Add Password to the Student table
ALTER TABLE Student 
ADD Password NVARCHAR(100) NOT NULL DEFAULT '123456';
GO

-- 2. Add Password to the Instructor table
ALTER TABLE Instructor 
ADD Password NVARCHAR(100) NOT NULL DEFAULT '123456';
GO

