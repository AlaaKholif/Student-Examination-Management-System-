-- Switch to the new database
USE ITI_ExamSystem;
GO

-- ============================================================================
-- TABLE 1: Branch
-- ============================================================================
CREATE TABLE Branch (
    BranchID INT PRIMARY KEY IDENTITY(1,1),
    BranchName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(200) NOT NULL
);
GO

-- ============================================================================
-- TABLE 2: Track
-- ============================================================================
CREATE TABLE Track (
    TrackID INT PRIMARY KEY IDENTITY(1,1),
    TrackName NVARCHAR(100) NOT NULL,
    BranchID INT NOT NULL,
    DurationMonths INT NOT NULL,
    CONSTRAINT FK_Track_Branch FOREIGN KEY (BranchID) 
        REFERENCES Branch(BranchID) ON DELETE CASCADE
);
GO

-- ============================================================================
-- TABLE 3: Course
-- ============================================================================
CREATE TABLE Course (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(100) NOT NULL,
    MinDegree INT NOT NULL,
    MaxDegree INT NOT NULL
);
GO

-- ============================================================================
-- TABLE 4: Track_Course
-- ============================================================================
CREATE TABLE Track_Course (
    TrackID INT NOT NULL,
    CourseID INT NOT NULL,
    CONSTRAINT PK_Track_Course PRIMARY KEY (TrackID, CourseID),
    CONSTRAINT FK_TrackCourse_Track FOREIGN KEY (TrackID) 
        REFERENCES Track(TrackID) ON DELETE CASCADE,
    CONSTRAINT FK_TrackCourse_Course FOREIGN KEY (CourseID) 
        REFERENCES Course(CourseID) ON DELETE CASCADE
);
GO

-- ============================================================================
-- TABLE 5: Instructor
-- ============================================================================
CREATE TABLE Instructor (
    InstructorID INT PRIMARY KEY IDENTITY(1,1),
    InstructorName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    DepartmentNo INT NOT NULL
);
GO

-- ============================================================================
-- TABLE 6: Instructor_Course
-- ============================================================================
CREATE TABLE Instructor_Course (
    InstructorID INT NOT NULL,
    CourseID INT NOT NULL,
    CONSTRAINT PK_Instructor_Course PRIMARY KEY (InstructorID, CourseID),
    CONSTRAINT FK_InstructorCourse_Instructor FOREIGN KEY (InstructorID) 
        REFERENCES Instructor(InstructorID) ON DELETE CASCADE,
    CONSTRAINT FK_InstructorCourse_Course FOREIGN KEY (CourseID) 
        REFERENCES Course(CourseID) ON DELETE CASCADE
);
GO
-- ============================================================================
-- TABLE 7: Student
-- ============================================================================
CREATE TABLE Student (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    StudentName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NOT NULL
);
GO

-- ============================================================================
-- TABLE 8: Student_Track 
-- ============================================================================
CREATE TABLE Student_Track (
    StudentID INT NOT NULL,
    TrackID INT NOT NULL,
    CONSTRAINT PK_Student_Track PRIMARY KEY (StudentID, TrackID),
    CONSTRAINT FK_StudentTrack_Student FOREIGN KEY (StudentID) 
        REFERENCES Student(StudentID) ON DELETE CASCADE,
    CONSTRAINT FK_StudentTrack_Track FOREIGN KEY (TrackID) 
        REFERENCES Track(TrackID) ON DELETE CASCADE
);
GO

-- ============================================================================
-- TABLE 9: Question
-- ============================================================================
CREATE TABLE Question (
    QuestionID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    QuestionText NVARCHAR(MAX) NOT NULL,
    QuestionType NVARCHAR(10) NOT NULL,
    Points INT NOT NULL,
    CONSTRAINT FK_Question_Course FOREIGN KEY (CourseID) 
        REFERENCES Course(CourseID) ON DELETE CASCADE,
    CONSTRAINT CK_Question_Type CHECK (QuestionType IN ('MCQ', 'TF'))
);
GO

-- ============================================================================
-- TABLE 10: Option
-- ============================================================================
CREATE TABLE [Option] (
    OptionID INT PRIMARY KEY IDENTITY(1,1),
    QuestionID INT NOT NULL,
    OptionText NVARCHAR(MAX) NOT NULL,
    OptionOrder INT NOT NULL,
    CONSTRAINT FK_Option_Question FOREIGN KEY (QuestionID) 
        REFERENCES Question(QuestionID) ON DELETE CASCADE
);
GO

-- ============================================================================
-- TABLE 11: ModelAnswer
-- ============================================================================
CREATE TABLE ModelAnswer (
    ModelAnswerID INT PRIMARY KEY IDENTITY(1,1),
    QuestionID INT NOT NULL UNIQUE,
    OptionID INT NOT NULL,
    CONSTRAINT FK_ModelAnswer_Question FOREIGN KEY (QuestionID) 
        REFERENCES Question(QuestionID) ON DELETE CASCADE,
    CONSTRAINT FK_ModelAnswer_Option FOREIGN KEY (OptionID) 
        REFERENCES [Option](OptionID) ON DELETE NO ACTION
);
GO

-- ============================================================================
-- TABLE 12: Exam
-- ============================================================================
CREATE TABLE Exam (
    ExamID INT PRIMARY KEY IDENTITY(1,1),
    ExamName NVARCHAR(150) NOT NULL,
    CourseID INT NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    TotalQuestions INT NOT NULL,
    DurationMinutes INT NOT NULL DEFAULT 180,
    CONSTRAINT FK_Exam_Course FOREIGN KEY (CourseID) 
        REFERENCES Course(CourseID) ON DELETE NO ACTION 
);
GO

-- ============================================================================
-- TABLE 13: ExamQuestion 
-- ============================================================================
CREATE TABLE ExamQuestion (
    ExamID INT NOT NULL,
    QuestionID INT NOT NULL,
    OrderNo INT NOT NULL,
    CONSTRAINT PK_ExamQuestion PRIMARY KEY (ExamID, QuestionID),
    CONSTRAINT FK_ExamQuestion_Exam FOREIGN KEY (ExamID) 
        REFERENCES Exam(ExamID) ON DELETE CASCADE,
    CONSTRAINT FK_ExamQuestion_Question FOREIGN KEY (QuestionID) 
        REFERENCES Question(QuestionID) ON DELETE NO ACTION 
);
GO

-- ============================================================================
-- TABLE 14: StudentExam
-- ============================================================================
CREATE TABLE StudentExam (
    StudentExamID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    TotalGrade INT NULL,
    CONSTRAINT FK_StudentExam_Student FOREIGN KEY (StudentID) 
        REFERENCES Student(StudentID) ON DELETE NO ACTION,
    CONSTRAINT FK_StudentExam_Exam FOREIGN KEY (ExamID) 
        REFERENCES Exam(ExamID) ON DELETE NO ACTION
);
GO
-- ============================================================================
-- TABLE 15: StudentAnswer
-- ============================================================================
CREATE TABLE StudentAnswer (
    StudentAnswerID INT PRIMARY KEY IDENTITY(1,1),
    StudentExamID INT NOT NULL,
    QuestionID INT NOT NULL,
    ChosenOptionID INT NULL,
    CONSTRAINT FK_StudentAnswer_StudentExam FOREIGN KEY (StudentExamID) 
        REFERENCES StudentExam(StudentExamID) ON DELETE CASCADE,
    CONSTRAINT FK_StudentAnswer_Question FOREIGN KEY (QuestionID) 
        REFERENCES Question(QuestionID),
    CONSTRAINT FK_StudentAnswer_Option FOREIGN KEY (ChosenOptionID) 
        REFERENCES [Option](OptionID)
);
