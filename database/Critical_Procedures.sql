USE ITI_ExamSystem;
GO


-- ============================================================================
-- Purpose: Generates a random exam for a specific course (REQ-09)
-- Inputs:  @CourseID (INT) - The ID of the course
--          @ExamName (NVARCHAR) - The name of the new exam
--          @NumMCQ (INT) - Number of Multiple Choice questions required
--          @NumTF (INT) - Number of True/False questions required
-- Outputs: Inserts 1 row into Exam table
--          Inserts N rows into ExamQuestion table (randomized)
-- ============================================================================
CREATE OR ALTER PROCEDURE GenerateExam
    @CourseID INT,
    @ExamName NVARCHAR(150),
    @NumMCQ INT,
    @NumTF INT,
    @DurationMinutes INT = 60 -- Added the Duration parameter with a 1-hour default
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if enough questions exist before starting
    DECLARE @AvailableMCQ INT, @AvailableTF INT;

    SELECT @AvailableMCQ = COUNT(*) FROM Question 
    WHERE CourseID = @CourseID AND QuestionType = 'MCQ';

    SELECT @AvailableTF = COUNT(*) FROM Question 
    WHERE CourseID = @CourseID AND QuestionType = 'TF';

    IF (@AvailableMCQ < @NumMCQ OR @AvailableTF < @NumTF)
    BEGIN
        RAISERROR('Insufficient questions: Course %d has %d MCQ and %d TF available.', 16, 1, @CourseID, @AvailableMCQ, @AvailableTF);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TotalQuestions INT = @NumMCQ + @NumTF;

        -- Updated Insert to include DurationMinutes
        INSERT INTO Exam (ExamName, CourseID, TotalQuestions, DurationMinutes)
        VALUES (@ExamName, @CourseID, @TotalQuestions, @DurationMinutes);

        DECLARE @NewExamID INT = SCOPE_IDENTITY();

        -- Select random questions and insert into ExamQuestion
        INSERT INTO ExamQuestion (ExamID, QuestionID, OrderNo)
        SELECT 
            @NewExamID, 
            QuestionID, 
            ROW_NUMBER() OVER (ORDER BY NEWID()) AS OrderNo
        FROM (
            (SELECT TOP (@NumMCQ) QuestionID 
             FROM Question 
             WHERE CourseID = @CourseID AND QuestionType = 'MCQ' 
             ORDER BY NEWID())
            UNION ALL
            (SELECT TOP (@NumTF) QuestionID 
             FROM Question 
             WHERE CourseID = @CourseID AND QuestionType = 'TF' 
             ORDER BY NEWID())
        ) AS SelectedQuestions;

        COMMIT TRANSACTION;
        PRINT 'Exam "' + @ExamName + '" generated successfully with ExamID: ' + CAST(@NewExamID AS VARCHAR) + ' (Duration: ' + CAST(@DurationMinutes AS VARCHAR) + ' mins)';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO



-- ============================================================================
-- Purpose: Records a student's exam attempt and parses their answers from an 
--          XML string into the database (REQ-10). Skipped questions are stored as NULL.
-- Inputs:  @StudentID (INT) - ID of the student taking the exam
--          @ExamID (INT) - ID of the exam being taken
--          @StartTime (DATETIME) - When the student started the exam
--          @EndTime (DATETIME) - When the student finished the exam
--          @Answers (XML) - The student's chosen answers in XML format
-- Outputs: Inserts 1 row into StudentExam table (TotalGrade remains NULL)
--          Inserts N rows into StudentAnswer table
-- ============================================================================
CREATE OR ALTER PROCEDURE SubmitExamAnswers
    @StudentID INT,
    @ExamID INT,
    @StartTime DATETIME,
    @EndTime DATETIME,
    @Answers XML
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Insert the main record into StudentExam
        INSERT INTO StudentExam (StudentID, ExamID, StartTime, EndTime)
        VALUES (@StudentID, @ExamID, @StartTime, @EndTime);

        -- Capture the generated StudentExamID
        DECLARE @NewStudentExamID INT = SCOPE_IDENTITY();

        -- 2. Parse the XML and insert into StudentAnswer
        -- Using element-based XQuery to match REQ-10 exact format
        INSERT INTO StudentAnswer (StudentExamID, QuestionID, ChosenOptionID)
        SELECT 
            @NewStudentExamID,
            AnsNode.Col.value('(QuestionID)[1]', 'INT') AS QuestionID,
            -- If ChosenOptionID is missing (skipped), this safely returns NULL
            AnsNode.Col.value('(ChosenOptionID)[1]', 'INT') AS ChosenOptionID
        FROM @Answers.nodes('/Answers/Answer') AS AnsNode(Col);

        COMMIT TRANSACTION;
        PRINT 'Exam submitted successfully for StudentID ' + CAST(@StudentID AS VARCHAR);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        -- Raise the original error
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO

-- ============================================================================
-- Purpose: Calculates and saves the total grade for a student's exam attempt (REQ-11).
--          Compares student answers against the ModelAnswer table and sums the points.
-- Inputs:  @StudentExamID (INT) - The unique ID of the student's exam session
-- Outputs: UPDATES the TotalGrade column in the StudentExam table
-- ============================================================================
CREATE OR ALTER PROCEDURE CorrectExam
    @StudentExamID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Safety check
    IF NOT EXISTS (SELECT 1 FROM StudentExam WHERE StudentExamID = @StudentExamID)
    BEGIN
        RAISERROR('StudentExamID %d does not exist.', 16, 1, @StudentExamID);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CalculatedGrade INT;

        -- Logic: If ChosenOptionID = ModelAnswer.OptionID -> add Points, else 0
        SELECT @CalculatedGrade = ISNULL(SUM(Q.Points), 0)
        FROM StudentAnswer SA
        INNER JOIN ModelAnswer MA ON SA.QuestionID = MA.QuestionID
        INNER JOIN Question Q ON SA.QuestionID = Q.QuestionID
        WHERE SA.StudentExamID = @StudentExamID
          AND SA.ChosenOptionID = MA.OptionID; 

        -- Output: UPDATE StudentExam SET TotalGrade = sum
        UPDATE StudentExam
        SET TotalGrade = @CalculatedGrade
        WHERE StudentExamID = @StudentExamID;

        COMMIT TRANSACTION;
        
        PRINT 'Exam corrected successfully! Total Grade for StudentExamID ' 
              + CAST(@StudentExamID AS VARCHAR) + ' is: ' + CAST(@CalculatedGrade AS VARCHAR);

    END TRY
    BEGIN CATCH
        -- Wrap in transaction (ROLLBACK on error)
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO
-- ============================================================================
-- Purpose: Retrieves a list of students and their track details filtered by 
--          a specific Department/Branch (REQ-12).
-- Inputs:  @DepartmentNo (INT) - The ID of the department/branch to filter by
-- Outputs: Returns a result set containing:
--          StudentID, Name, Email, Phone, TrackName, BranchName
-- ============================================================================
CREATE OR ALTER PROCEDURE Report_StudentsByDepartment
    @DepartmentNo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.StudentID, 
        s.StudentName AS Name, 
        s.Email, 
        s.Phone, 
        t.TrackName, 
        b.BranchName
    FROM Student s
    INNER JOIN Student_Track st ON s.StudentID = st.StudentID
    INNER JOIN Track t ON st.TrackID = t.TrackID
    INNER JOIN Branch b ON t.BranchID = b.BranchID
    WHERE b.BranchID = @DepartmentNo
    ORDER BY s.StudentID; 
END;
GO


-- ============================================================================
-- Purpose: Retrieves all graded exams for a specific student and calculates 
--          their percentage score for each course (REQ-13).
-- Inputs:  @StudentID (INT) - The ID of the student to generate the report for
-- Outputs: Returns a result set containing:
--          CourseName, ExamName, TotalGrade, MaxDegree, Percentage
-- ============================================================================
CREATE OR ALTER PROCEDURE Report_StudentGrades
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        C.CourseName,
        E.ExamName,
        SE.TotalGrade,
        C.MaxDegree,
        -- Exact formula from REQ-13 (with NULLIF for safety against divide-by-zero)
        (CAST(SE.TotalGrade AS FLOAT) / NULLIF(C.MaxDegree, 0)) * 100 AS Percentage
    FROM StudentExam SE
    INNER JOIN Exam E ON SE.ExamID = E.ExamID
    INNER JOIN Course C ON E.CourseID = C.CourseID
    WHERE SE.StudentID = @StudentID
      AND SE.TotalGrade IS NOT NULL; -- Only graded exams
END;
GO

-- ============================================================================
-- Purpose: Retrieves a list of courses taught by a specific instructor, 
--          along with the tracks those courses belong to and the count of 
--          students enrolled in each track (REQ-14).
-- Inputs:  @InstructorID (INT) - The ID of the instructor to run the report for
-- Outputs: Returns a result set containing:
--          CourseName, TrackName, StudentCount
-- ============================================================================
CREATE OR ALTER PROCEDURE Report_InstructorCourses
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        C.CourseName,
        T.TrackName,
        -- Count DISTINCT students to ensure accuracy
        COUNT(DISTINCT ST.StudentID) AS StudentCount
    FROM Instructor_Course IC
    INNER JOIN Course C ON IC.CourseID = C.CourseID
    -- Connect courses to tracks
    INNER JOIN Track_Course TC ON C.CourseID = TC.CourseID
    INNER JOIN Track T ON TC.TrackID = T.TrackID
    -- LEFT JOIN to students so a track with 0 students still shows up
    LEFT JOIN Student_Track ST ON T.TrackID = ST.TrackID
    WHERE IC.InstructorID = @InstructorID
    GROUP BY C.CourseName, T.TrackName
    ORDER BY C.CourseName, T.TrackName;
END;
GO
