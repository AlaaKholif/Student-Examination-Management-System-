USE ITI_ExamSystem;
GO

-- ============================================================================
-- TEST 1: GenerateExam - Valid Inputs (Should Create Exam + ExamQuestion rows)
-- ============================================================================
PRINT '========== TEST 1: GenerateExam - Valid Inputs ==========';
PRINT 'Expected: Exam created with 5 MCQ + 3 TF questions (8 total), no duplicates';
GO

DECLARE @ExamID INT;
EXEC GenerateExam 
    @CourseID = 1,
    @ExamName = N'SQL Fundamentals - Test 1',
    @NumMCQ = 5,
    @NumTF = 3;

-- Verify Exam was created
SELECT 'Exam Created:' AS Test, ExamID, ExamName, CourseID, TotalQuestions, CreatedDate
FROM Exam 
WHERE ExamName = N'SQL Fundamentals - Test 1';

-- Verify ExamQuestion rows were created (should be 8 rows)
SELECT 'ExamQuestion Rows:' AS Test, COUNT(*) AS TotalRows
FROM ExamQuestion eq
WHERE eq.ExamID = (SELECT ExamID FROM Exam WHERE ExamName = N'SQL Fundamentals - Test 1');

-- Verify no duplicate questions
SELECT 'Duplicate Check:' AS Test, COUNT(*) AS DuplicateCount
FROM ExamQuestion eq
WHERE eq.ExamID = (SELECT ExamID FROM Exam WHERE ExamName = N'SQL Fundamentals - Test 1')
GROUP BY eq.QuestionID
HAVING COUNT(*) > 1;

GO

-- ============================================================================
-- TEST 2: GenerateExam - Not Enough Questions (Should Raise Error)
-- ============================================================================
PRINT '========== TEST 2: GenerateExam - Not Enough Questions ==========';
PRINT 'Expected: Error raised, no exam created';
GO

BEGIN TRY
    EXEC GenerateExam 
        @CourseID = 1,
        @ExamName = N'SQL Fundamentals - Test 2 ',
        @NumMCQ = 100,  -- More than available MCQ questions
        @NumTF = 100;   -- More than available TF questions
END TRY
BEGIN CATCH
    SELECT 'Error Caught:' AS Test, ERROR_MESSAGE() AS ErrorMessage;
END CATCH

-- Verify exam was NOT created
SELECT 'Exam NOT Created:' AS Test, COUNT(*) AS ExamCount
FROM Exam 
WHERE ExamName = N'SQL Fundamentals - Test 2 ';

GO

-- ============================================================================
-- TEST 3: SubmitExamAnswers - All Questions Answered (Should Create StudentExam + StudentAnswer rows)
-- ============================================================================
PRINT '========== TEST 3: SubmitExamAnswers - All Questions Answered ==========';
PRINT 'Expected: StudentExam created + 8 StudentAnswer rows (all questions answered)';
GO

DECLARE @StudentExamID INT;
DECLARE @ExamID INT;
DECLARE @Answers XML ;

-- Get the exam we created in Test 1
SELECT @ExamID = ExamID FROM Exam WHERE ExamName = N'SQL Fundamentals - Test 1';

-- Build XML with answers for all 8 questions (using OptionID 1-4 for MCQ, 1-2 for TF)
SET @Answers = '
<Answers>
    <Answer><QuestionID>1</QuestionID><ChosenOptionID>1</ChosenOptionID></Answer>
    <Answer><QuestionID>2</QuestionID><ChosenOptionID>5</ChosenOptionID></Answer>
    <Answer><QuestionID>3</QuestionID><ChosenOptionID>9</ChosenOptionID></Answer>
    <Answer><QuestionID>4</QuestionID><ChosenOptionID>16</ChosenOptionID></Answer>
    <Answer><QuestionID>5</QuestionID><ChosenOptionID>17</ChosenOptionID></Answer>
    <Answer><QuestionID>33</QuestionID><ChosenOptionID>129</ChosenOptionID></Answer>
    <Answer><QuestionID>34</QuestionID><ChosenOptionID>131</ChosenOptionID></Answer>
</Answers>';
-- ============================================================================
-- TEST 4: SubmitExamAnswers - One Question Skipped (WITH XML PARAMETER)
-- Expected: Success — no StudentAnswer row for skipped question
-- ============================================================================
PRINT '';
PRINT '========== TEST 4: SubmitExamAnswers - One Question Skipped ==========';
PRINT 'Expected: StudentExam created + 7 StudentAnswer rows (1 question skipped)';
PRINT 'Skipped question (ChosenOptionID missing) should NOT create a StudentAnswer row';
GO

USE ITI_ExamSystem;
GO

DECLARE @StudentExamID2 INT;
DECLARE @ExamID_T4 INT;
DECLARE @AnswersXML2 XML;
DECLARE @StartTime2 DATETIME;
DECLARE @EndTime2 DATETIME;

-- Create another exam
PRINT 'Creating exam for TEST 4...';
EXEC GenerateExam 
    @CourseID = 1,
    @ExamName = N'SQL Fundamentals - Test 4 (Skip Test)',
    @NumMCQ = 5,
    @NumTF = 3;

SELECT @ExamID_T4 = ExamID FROM Exam WHERE ExamName = N'SQL Fundamentals - Test 4 (Skip Test)';

-- Set start and end times
SET @StartTime2 = GETDATE();
SET @EndTime2 = DATEADD(MINUTE, 30, @StartTime2);

-- Build XML with 8 answers, but QuestionID 3 is SKIPPED (no ChosenOptionID element)
-- This is the correct way to represent a skipped question in XML
SET @AnswersXML2 = N'<Answers>
    <Answer><QuestionID>1</QuestionID><ChosenOptionID>1</ChosenOptionID></Answer>
    <Answer><QuestionID>2</QuestionID><ChosenOptionID>5</ChosenOptionID></Answer>
    <Answer><QuestionID>3</QuestionID></Answer>
    <Answer><QuestionID>4</QuestionID><ChosenOptionID>16</ChosenOptionID></Answer>
    <Answer><QuestionID>5</QuestionID><ChosenOptionID>17</ChosenOptionID></Answer>
    <Answer><QuestionID>33</QuestionID><ChosenOptionID>129</ChosenOptionID></Answer>
    <Answer><QuestionID>34</QuestionID><ChosenOptionID>131</ChosenOptionID></Answer>
    <Answer><QuestionID>35</QuestionID><ChosenOptionID>136</ChosenOptionID></Answer>
</Answers>';

PRINT 'Submitting exam answers with 1 question skipped (no ChosenOptionID element)...';
EXEC SubmitExamAnswers
    @StudentID = 2,
    @ExamID = @ExamID_T4,
    @StartTime = @StartTime2,
    @EndTime = @EndTime2,
    @Answers = @AnswersXML2;

SELECT @StudentExamID2 = StudentExamID FROM StudentExam WHERE StudentID = 2 AND ExamID = @ExamID_T4;

-- Verify StudentExam was created
PRINT '';
PRINT 'StudentExam Record:';
SELECT 'StudentExamID' AS Test, StudentExamID, StudentID, ExamID
FROM StudentExam
WHERE StudentID = 2 AND ExamID = @ExamID_T4;

-- Verify StudentAnswer rows (should be 7, NOT 8)
PRINT '';
PRINT 'StudentAnswer Count (Should be 7, NOT 8):';
SELECT 'Total Answers' AS Test, COUNT(*) AS TotalAnswers
FROM StudentAnswer sa
WHERE sa.StudentExamID = @StudentExamID2;

-- Show all answers - QuestionID 3 should NOT appear
PRINT '';
PRINT 'All Student Answers (QuestionID 3 should be MISSING):';
SELECT 'Question ID' AS Test, QuestionID, ChosenOptionID
FROM StudentAnswer sa
WHERE sa.StudentExamID = @StudentExamID2
ORDER BY QuestionID;

GO
-- ============================================================================
-- TEST 5: CorrectExam - All Answers Correct
-- Expected: TotalGrade = MaxDegree (40 points)
-- ============================================================================
PRINT '========== TEST 5: CorrectExam - All Answers Correct ==========';
PRINT 'Expected: TotalGrade = 40 (8 questions × 5 points each)';
GO

DECLARE @StudentExamID3 INT;
DECLARE @ExamID_T5 INT;
DECLARE @Answers3 XML;
DECLARE @StartTime3 DATETIME;
DECLARE @EndTime3 DATETIME;

-- Create another exam
EXEC GenerateExam 
    @CourseID = 1,
    @ExamName = N'SQL Fundamentals - Test 5 ',
    @NumMCQ = 5,
    @NumTF = 3;

SELECT @ExamID_T5 = ExamID FROM Exam WHERE ExamName = N'SQL Fundamentals - Test 5 ';

-- Set start and end times
SET @StartTime3 = GETDATE();
SET @EndTime3 = DATEADD(MINUTE, 30, @StartTime3);

-- Build XML with CORRECT answers (matching ModelAnswer)
SET @Answers3 = '<Answers>
    <Answer><QuestionID>1</QuestionID><ChosenOptionID>1</ChosenOptionID></Answer>
    <Answer><QuestionID>2</QuestionID><ChosenOptionID>5</ChosenOptionID></Answer>
    <Answer><QuestionID>3</QuestionID><ChosenOptionID>9</ChosenOptionID></Answer>
    <Answer><QuestionID>4</QuestionID><ChosenOptionID>16</ChosenOptionID></Answer>
    <Answer><QuestionID>5</QuestionID><ChosenOptionID>17</ChosenOptionID></Answer>
    <Answer><QuestionID>33</QuestionID><ChosenOptionID>130</ChosenOptionID></Answer>
    <Answer><QuestionID>34</QuestionID><ChosenOptionID>131</ChosenOptionID></Answer>
    <Answer><QuestionID>35</QuestionID><ChosenOptionID>135</ChosenOptionID></Answer>
</Answers>';

EXEC SubmitExamAnswers
    @StudentID = 3,
    @ExamID = @ExamID_T5,
    @StartTime = @StartTime3,
    @EndTime = @EndTime3,
    @Answers = @Answers3;

SELECT @StudentExamID3 = StudentExamID FROM StudentExam WHERE StudentID = 3 AND ExamID = @ExamID_T5;

-- Before correction
SELECT 'StudentExamID' AS Test, StudentExamID, TotalGrade
FROM StudentExam
WHERE StudentExamID = @StudentExamID3;

-- Run CorrectExam
EXEC CorrectExam @StudentExamID = @StudentExamID3;

-- After correction
PRINT 'After CorrectExam (Should be 40):';
SELECT 'StudentExamID' AS Test, StudentExamID, TotalGrade
FROM StudentExam
WHERE StudentExamID = @StudentExamID3;

GO

-- ============================================================================
-- TEST 6: CorrectExam - All Answers Wrong
-- Expected: TotalGrade = 0
PRINT '========== TEST 6: CorrectExam - All Answers Wrong ==========';
PRINT 'Expected: TotalGrade = 0 (all answers incorrect)';
GO

DECLARE @StudentExamID4 INT;
DECLARE @ExamID_T6 INT;
DECLARE @Answers4 XML ;
DECLARE @StartTime4 DATETIME;
DECLARE @EndTime4 DATETIME;

-- Create another exam
EXEC GenerateExam 
    @CourseID = 1,
    @ExamName = N'SQL Fundamentals - Test 6 ',
    @NumMCQ = 5,
    @NumTF = 3;

SELECT @ExamID_T6 = ExamID FROM Exam WHERE ExamName = N'SQL Fundamentals - Test 6 ';

-- Set start and end times
SET @StartTime4 = GETDATE();
SET @EndTime4 = DATEADD(MINUTE, 30, @StartTime4);

-- Build XML with WRONG answers (NOT matching ModelAnswer)
SET @Answers4 = '<Answers>
    <Answer><QuestionID>1</QuestionID><ChosenOptionID>2</ChosenOptionID></Answer>
    <Answer><QuestionID>2</QuestionID><ChosenOptionID>6</ChosenOptionID></Answer>
    <Answer><QuestionID>3</QuestionID><ChosenOptionID>10</ChosenOptionID></Answer>
    <Answer><QuestionID>4</QuestionID><ChosenOptionID>15</ChosenOptionID></Answer>
    <Answer><QuestionID>5</QuestionID><ChosenOptionID>18</ChosenOptionID></Answer>
    <Answer><QuestionID>33</QuestionID><ChosenOptionID>128</ChosenOptionID></Answer>
    <Answer><QuestionID>34</QuestionID><ChosenOptionID>132</ChosenOptionID></Answer>
    <Answer><QuestionID>35</QuestionID><ChosenOptionID>134</ChosenOptionID></Answer>
</Answers>';

EXEC SubmitExamAnswers
    @StudentID = 4,
    @ExamID = @ExamID_T6,
    @StartTime = @StartTime4,
    @EndTime = @EndTime4,
    @Answers = @Answers4;

SELECT @StudentExamID4 = StudentExamID FROM StudentExam WHERE StudentID = 4 AND ExamID = @ExamID_T6;

-- Before correction
SELECT 'StudentExamID' AS Test, StudentExamID, TotalGrade
FROM StudentExam
WHERE StudentExamID = @StudentExamID4;

-- Run CorrectExam
EXEC CorrectExam @StudentExamID = @StudentExamID4;

-- After correction
SELECT 'StudentExamID' AS Test, StudentExamID, TotalGrade
FROM StudentExam
WHERE StudentExamID = @StudentExamID4;

GO

-- ============================================================================
-- TEST 7: Run All 3 Reports
-- Expected: Correct data returned per report spec
-- ============================================================================
PRINT '========== TEST 7: Run All 3 Reports ==========';
PRINT 'Expected: Correct data returned per report spec';
GO


PRINT '--- Report 1: Report_StudentsByDepartment (Branch 1) ---';
EXEC Report_StudentsByDepartment @DepartmentNo = 1;


PRINT '--- Report 2: Report_StudentGrades (Student 3 - All Correct) ---';
EXEC Report_StudentGrades @StudentID = 3;


PRINT '--- Report 3: Report_InstructorCourses (Instructor 1) ---';
EXEC Report_InstructorCourses @InstructorID = 1;

GO

-- ============================================================================
-- TEST 8: Delete Course with Existing Exams
-- Expected: FK constraint error — delete rejected
-- ============================================================================
PRINT '========== TEST 8: Delete Course with Existing Exams ==========';
PRINT 'Expected: FK constraint error — delete rejected';
GO

BEGIN TRY
    DELETE FROM Course WHERE CourseID = 1;
    PRINT ' TEST 8 FAILED: Course was deleted (FK constraint not working)';
END TRY
BEGIN CATCH
    PRINT 'Error Message: ' + ERROR_MESSAGE();
END CATCH

GO