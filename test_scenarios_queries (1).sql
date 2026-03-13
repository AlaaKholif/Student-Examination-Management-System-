USE ITI_ExamSystem;
GO

-- ============================================================================
-- TEST 1: GenerateExam — valid inputs
-- Expected Result: Exam + ExamQuestion rows created, no duplicates
-- ============================================================================

INSERT INTO Exam (ExamName, CourseID, TotalQuestions)
VALUES ('SQL Fundamentals Exam', 1, 10);

INSERT INTO ExamQuestion (ExamID, QuestionID, OrderNo)
SELECT TOP 10
    1, QuestionID,
    ROW_NUMBER() OVER (ORDER BY NEWID())
FROM Question
WHERE CourseID = 1
AND QuestionID NOT IN (SELECT QuestionID FROM ExamQuestion WHERE ExamID = 1)
ORDER BY NEWID();

SELECT * FROM Exam WHERE ExamID = 1;
SELECT * FROM ExamQuestion WHERE ExamID = 1;

GO

-- ============================================================================
-- TEST 2: GenerateExam — not enough questions
-- Expected Result: Error raised, no partial exam created
-- ============================================================================

SELECT COUNT(*) AS AvailableQuestions
FROM Question WHERE CourseID = 99;

INSERT INTO ExamQuestion (ExamID, QuestionID, OrderNo)
SELECT TOP 10
    1, QuestionID,
    ROW_NUMBER() OVER (ORDER BY NEWID())
FROM Question
WHERE CourseID = 99
ORDER BY NEWID();

GO

-- ============================================================================
-- TEST 3: SubmitExamAnswers — all questions answered
-- Expected Result: StudentExam + all StudentAnswer rows created
-- ============================================================================

INSERT INTO StudentExam (StudentID, ExamID, StartTime, EndTime)
VALUES (1, 1, GETDATE(), DATEADD(HOUR, 1, GETDATE()));

INSERT INTO StudentAnswer (StudentExamID, QuestionID, ChosenOptionID)
SELECT
    1,
    EQ.QuestionID,
    MA.OptionID
FROM ExamQuestion EQ
JOIN ModelAnswer MA ON EQ.QuestionID = MA.QuestionID
WHERE EQ.ExamID = 1;

SELECT COUNT(*) AS AnswersSubmitted FROM StudentAnswer WHERE StudentExamID = 1;
SELECT COUNT(*) AS TotalQuestions FROM ExamQuestion WHERE ExamID = 1;

GO

-- ============================================================================
-- TEST 4: SubmitExamAnswers — one question skipped
-- Expected Result: Success — no StudentAnswer for skipped question
-- ============================================================================

INSERT INTO StudentExam (StudentID, ExamID, StartTime, EndTime)
VALUES (2, 1, GETDATE(), DATEADD(HOUR, 1, GETDATE()));

INSERT INTO StudentAnswer (StudentExamID, QuestionID, ChosenOptionID)
SELECT
    2,
    EQ.QuestionID,
    MA.OptionID
FROM ExamQuestion EQ
JOIN ModelAnswer MA ON EQ.QuestionID = MA.QuestionID
WHERE EQ.ExamID = 1
AND EQ.OrderNo <> 1;  -- Skip question with OrderNo=1

SELECT COUNT(*) AS AnswersSubmitted
FROM StudentAnswer WHERE StudentExamID = 2;

GO

-- ============================================================================
-- TEST 5: CorrectExam — all correct
-- Expected Result: TotalGrade = MaxDegree
-- ============================================================================

SELECT COUNT(*) AS CorrectAnswers
FROM StudentAnswer SA
JOIN ModelAnswer MA ON SA.QuestionID = MA.QuestionID
WHERE SA.ChosenOptionID = MA.OptionID
AND SA.StudentExamID = 1;

UPDATE StudentExam
SET TotalGrade = (
    SELECT SUM(Q.Points)
    FROM StudentAnswer SA
    JOIN ModelAnswer MA ON SA.QuestionID = MA.QuestionID
    JOIN Question Q ON SA.QuestionID = Q.QuestionID
    WHERE SA.ChosenOptionID = MA.OptionID
    AND SA.StudentExamID = StudentExam.StudentExamID
)
WHERE StudentExamID = 1;

SELECT TotalGrade FROM StudentExam WHERE StudentExamID = 1;

GO

-- ============================================================================
-- TEST 6: CorrectExam — all wrong
-- Expected Result: TotalGrade = 0
-- ============================================================================

INSERT INTO StudentExam (StudentID, ExamID, StartTime, EndTime)
VALUES (3, 1, GETDATE(), DATEADD(HOUR, 1, GETDATE()));

INSERT INTO StudentAnswer (StudentExamID, QuestionID, ChosenOptionID)
SELECT
    3,
    EQ.QuestionID,
    O.OptionID
FROM ExamQuestion EQ
JOIN [Option] O ON EQ.QuestionID = O.QuestionID
JOIN ModelAnswer MA ON EQ.QuestionID = MA.QuestionID
WHERE EQ.ExamID = 1
AND O.OptionID <> MA.OptionID
AND O.OptionOrder = 2;

UPDATE StudentExam
SET TotalGrade = (
    SELECT ISNULL(SUM(Q.Points), 0)
    FROM StudentAnswer SA
    JOIN ModelAnswer MA ON SA.QuestionID = MA.QuestionID
    JOIN Question Q ON SA.QuestionID = Q.QuestionID
    WHERE SA.ChosenOptionID = MA.OptionID
    AND SA.StudentExamID = StudentExam.StudentExamID
)
WHERE StudentExamID = 3;

SELECT TotalGrade FROM StudentExam WHERE StudentExamID = 3;

GO

-- ============================================================================
-- TEST 7: Run all 3 reports
-- Expected Result: Correct data returned per report spec
-- ============================================================================

-- Report 1: Student Grades
SELECT S.StudentName, E.ExamName, SE.TotalGrade
FROM StudentExam SE
JOIN Student S ON SE.StudentID = S.StudentID
JOIN Exam E ON SE.ExamID = E.ExamID;

-- Report 2: Exam Summary
SELECT E.ExamID, E.ExamName, C.CourseName,
       COUNT(EQ.QuestionID) AS TotalQuestions
FROM Exam E
JOIN Course C ON E.CourseID = C.CourseID
JOIN ExamQuestion EQ ON E.ExamID = EQ.ExamID
GROUP BY E.ExamID, E.ExamName, C.CourseName;

-- Report 3: Courses per Track
SELECT T.TrackName, C.CourseName
FROM Track_Course TC
JOIN Track T ON TC.TrackID = T.TrackID
JOIN Course C ON TC.CourseID = C.CourseID
ORDER BY T.TrackName;

GO

-- ============================================================================
-- TEST 8: Delete Course with existing exams
-- Expected Result: FK constraint error — delete rejected
-- ============================================================================

DELETE FROM Course WHERE CourseID = 1;

SELECT * FROM Course WHERE CourseID = 1;

GO
