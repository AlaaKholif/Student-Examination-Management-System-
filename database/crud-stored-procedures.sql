-- ============================================================================
-- ITI Exam System - CRUD Stored Procedures
-- ============================================================================

USE ITI_ExamSystem;
GO

-- ============================================================================
-- BRANCH CRUD PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: InsertBranch
-- Purpose: Insert a new branch into the database
-- Inputs: @BranchName (NVARCHAR), @Location (NVARCHAR)
-- Outputs: Returns the newly created BranchID
-- ============================================================================
CREATE PROCEDURE InsertBranch
    @BranchName NVARCHAR(100),
    @Location NVARCHAR(200)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Branch (BranchName, Location)
        VALUES (@BranchName, @Location);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS BranchID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: UpdateBranch
-- Purpose: Update an existing branch
-- Inputs: @BranchID (INT), @BranchName (NVARCHAR), @Location (NVARCHAR)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE UpdateBranch
    @BranchID INT,
    @BranchName NVARCHAR(100),
    @Location NVARCHAR(200)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Branch
        SET BranchName = @BranchName,
            Location = @Location
        WHERE BranchID = @BranchID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: DeleteBranch
-- Purpose: Delete a branch (cascades to related tracks)
-- Inputs: @BranchID (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE DeleteBranch
    @BranchID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Branch
        WHERE BranchID = @BranchID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: SelectBranch
-- Purpose: Retrieve all branches or a specific branch by ID
-- Inputs: @BranchID (INT, optional - NULL returns all)
-- Outputs: Result set of branch records
-- ============================================================================
CREATE PROCEDURE SelectBranch
    @BranchID INT = NULL
AS
BEGIN
    IF @BranchID IS NULL
    BEGIN
        SELECT BranchID, BranchName, Location
        FROM Branch
        ORDER BY BranchID;
    END
    ELSE
    BEGIN
        SELECT BranchID, BranchName, Location
        FROM Branch
        WHERE BranchID = @BranchID;
    END
END;
GO

-- ============================================================================
-- TRACK CRUD PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: InsertTrack
-- Purpose: Insert a new track
-- Inputs: @TrackName (NVARCHAR), @BranchID (INT), @DurationMonths (INT)
-- Outputs: Returns the newly created TrackID
-- ============================================================================
CREATE PROCEDURE InsertTrack
    @TrackName NVARCHAR(100),
    @BranchID INT,
    @DurationMonths INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Track (TrackName, BranchID, DurationMonths)
        VALUES (@TrackName, @BranchID, @DurationMonths);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS TrackID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: UpdateTrack
-- Purpose: Update an existing track
-- Inputs: @TrackID (INT), @TrackName (NVARCHAR), @BranchID (INT), @DurationMonths (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE UpdateTrack
    @TrackID INT,
    @TrackName NVARCHAR(100),
    @BranchID INT,
    @DurationMonths INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Track
        SET TrackName = @TrackName,
            BranchID = @BranchID,
            DurationMonths = @DurationMonths
        WHERE TrackID = @TrackID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: DeleteTrack
-- Purpose: Delete a track (cascades to related courses and students)
-- Inputs: @TrackID (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE DeleteTrack
    @TrackID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Track
        WHERE TrackID = @TrackID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: SelectByBranch
-- Purpose: Retrieve all tracks for a specific branch
-- Inputs: @BranchID (INT)
-- Outputs: Result set of track records
-- ============================================================================
CREATE PROCEDURE SelectByBranch
    @BranchID INT
AS
BEGIN
    SELECT TrackID, TrackName, BranchID, DurationMonths
    FROM Track
    WHERE BranchID = @BranchID
    ORDER BY TrackID;
END;
GO

-- ============================================================================
-- COURSE CRUD PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: InsertCourse
-- Purpose: Insert a new course
-- Inputs: @CourseName (NVARCHAR), @MinDegree (INT), @MaxDegree (INT)
-- Outputs: Returns the newly created CourseID
-- ============================================================================
CREATE PROCEDURE InsertCourse
    @CourseName NVARCHAR(100),
    @MinDegree INT,
    @MaxDegree INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Course (CourseName, MinDegree, MaxDegree)
        VALUES (@CourseName, @MinDegree, @MaxDegree);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS CourseID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: UpdateCourse
-- Purpose: Update an existing course
-- Inputs: @CourseID (INT), @CourseName (NVARCHAR), @MinDegree (INT), @MaxDegree (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE UpdateCourse
    @CourseID INT,
    @CourseName NVARCHAR(100),
    @MinDegree INT,
    @MaxDegree INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Course
        SET CourseName = @CourseName,
            MinDegree = @MinDegree,
            MaxDegree = @MaxDegree
        WHERE CourseID = @CourseID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: DeleteCourse
-- Purpose: Delete a course (cascades to exams and questions)
-- Inputs: @CourseID (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE DeleteCourse
    @CourseID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Course
        WHERE CourseID = @CourseID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

--============================================================================
-- Procedure: SelectByTrack
-- ============================================================================
CREATE PROCEDURE SelectByTrack
    @TrackID INT = NULL
AS
BEGIN
    IF @TrackID IS NULL
    BEGIN
        PRINT 'Error: TrackID is required. Please provide a valid TrackID.';
        RETURN;
    END

    SELECT
        C.CourseID,
        C.CourseName,
        C.MinDegree,
        C.MaxDegree
    FROM Course C
    INNER JOIN Track_Course TC ON TC.CourseID = C.CourseID
    WHERE TC.TrackID = @TrackID
    ORDER BY C.CourseName;
END;
GO

-- ============================================================================
-- INSTRUCTOR CRUD PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: InsertInstructor
-- Purpose: Insert a new instructor
-- Inputs: @InstructorName (NVARCHAR), @Email (NVARCHAR), @DepartmentNo (INT)
-- Outputs: Returns the newly created InstructorID
-- ============================================================================
CREATE PROCEDURE InsertInstructor
    @InstructorName NVARCHAR(100),
    @Email NVARCHAR(100),
    @DepartmentNo INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Instructor (InstructorName, Email, DepartmentNo)
        VALUES (@InstructorName, @Email, @DepartmentNo);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS InstructorID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: UpdateInstructor
-- Purpose: Update an existing instructor
-- Inputs: @InstructorID (INT), @InstructorName (NVARCHAR), @Email (NVARCHAR), @DepartmentNo (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE UpdateInstructor
    @InstructorID INT,
    @InstructorName NVARCHAR(100),
    @Email NVARCHAR(100),
    @DepartmentNo INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Instructor
        SET InstructorName = @InstructorName,
            Email = @Email,
            DepartmentNo = @DepartmentNo
        WHERE InstructorID = @InstructorID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: AssignInstructorToCourse
-- Purpose: Assign an instructor to teach a course
-- Inputs: @InstructorID (INT), @CourseID (INT)
-- Outputs: None
-- ============================================================================
CREATE PROCEDURE AssignInstructorToCourse
    @InstructorID INT,
    @CourseID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Instructor_Course 
                       WHERE InstructorID = @InstructorID AND CourseID = @CourseID)
        BEGIN
            INSERT INTO Instructor_Course (InstructorID, CourseID)
            VALUES (@InstructorID, @CourseID);
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- STUDENT CRUD PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: InsertStudent
-- Purpose: Insert a new student
-- Inputs: @StudentName (NVARCHAR), @Email (NVARCHAR), @Phone (NVARCHAR)
-- Outputs: Returns the newly created StudentID
-- ============================================================================
CREATE PROCEDURE InsertStudent
    @StudentName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Student (StudentName, Email, Phone)
        VALUES (@StudentName, @Email, @Phone);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS StudentID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: UpdateStudent
-- Purpose: Update an existing student
-- Inputs: @StudentID (INT), @StudentName (NVARCHAR), @Email (NVARCHAR), @Phone (NVARCHAR)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE UpdateStudent
    @StudentID INT,
    @StudentName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Student
        SET StudentName = @StudentName,
            Email = @Email,
            Phone = @Phone
        WHERE StudentID = @StudentID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: DeleteStudent
-- Purpose: Delete a student (cascades to exam records)
-- Inputs: @StudentID (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE DeleteStudent
    @StudentID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Student
        WHERE StudentID = @StudentID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: AssignStudentToTrack
-- Purpose: Enroll a student in a track
-- Inputs: @StudentID (INT), @TrackID (INT)
-- Outputs: None
-- ============================================================================
CREATE PROCEDURE AssignStudentToTrack
    @StudentID INT,
    @TrackID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Student_Track 
                       WHERE StudentID = @StudentID AND TrackID = @TrackID)
        BEGIN
            INSERT INTO Student_Track (StudentID, TrackID)
            VALUES (@StudentID, @TrackID);
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- QUESTION CRUD PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: InsertQuestion
-- Purpose: Insert a new question (MCQ or True/False)
-- Inputs: @CourseID (INT), @QuestionText (NVARCHAR), @QuestionType (NVARCHAR), @Points (INT)
-- Outputs: Returns the newly created QuestionID
-- ============================================================================
CREATE PROCEDURE InsertQuestion
    @CourseID INT,
    @QuestionText NVARCHAR(MAX),
    @QuestionType NVARCHAR(10),
    @Points INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Question (CourseID, QuestionText, QuestionType, Points)
        VALUES (@CourseID, @QuestionText, @QuestionType, @Points);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS QuestionID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: UpdateQuestion
-- Purpose: Update an existing question
-- Inputs: @QuestionID (INT), @QuestionText (NVARCHAR), @Points (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE UpdateQuestion
    @QuestionID INT,
    @QuestionText NVARCHAR(MAX),
    @Points INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        UPDATE Question
        SET QuestionText = @QuestionText,
            Points = @Points
        WHERE QuestionID = @QuestionID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- Procedure: DeleteQuestion
-- Purpose: Delete a question (cascades to options and model answers)
-- Inputs: @QuestionID (INT)
-- Outputs: None (returns affected row count)
-- ============================================================================
CREATE PROCEDURE DeleteQuestion
    @QuestionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Question
        WHERE QuestionID = @QuestionID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- OPTION CRUD PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: InsertOption
-- Purpose: Insert a new option for a question (4 per MCQ, 2 per T/F)
-- Inputs: @QuestionID (INT), @OptionText (NVARCHAR), @OptionOrder (INT)
-- Outputs: Returns the newly created OptionID
-- ============================================================================
CREATE PROCEDURE InsertOption
    @QuestionID INT,
    @OptionText NVARCHAR(MAX),
    @OptionOrder INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO [Option] (QuestionID, OptionText, OptionOrder)
        VALUES (@QuestionID, @OptionText, @OptionOrder);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS OptionID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- MODEL ANSWER PROCEDURES
-- ============================================================================

-- ============================================================================
-- Procedure: SetModelAnswer
-- Purpose: Set the correct answer for a question (one per question)
-- Inputs: @QuestionID (INT), @OptionID (INT)
-- Outputs: Returns the newly created ModelAnswerID
-- ============================================================================
CREATE PROCEDURE SetModelAnswer
    @QuestionID INT,
    @OptionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Delete existing model answer if existed
        DELETE FROM ModelAnswer WHERE QuestionID = @QuestionID;
        
        -- Insert new model answer
        INSERT INTO ModelAnswer (QuestionID, OptionID)
        VALUES (@QuestionID, @OptionID);
        
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS ModelAnswerID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
