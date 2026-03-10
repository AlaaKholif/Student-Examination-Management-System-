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
