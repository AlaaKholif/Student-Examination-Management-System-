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