USE ITI_ExamSystem;
GO

-- ============================================================================
-- SECTION 1: INSERT BRANCHES (3 branches)
-- ============================================================================
INSERT INTO Branch (BranchName, Location) VALUES 
    (N'Cairo Branch', N'Cairo, Egypt'),
    (N'Alexandria Branch', N'Alexandria, Egypt'),
    (N'Giza Branch', N'Giza, Egypt');
GO

-- ============================================================================
-- SECTION 2: INSERT TRACKS (2+ per branch)
-- ============================================================================
INSERT INTO Track (TrackName, BranchID, DurationMonths) VALUES 
    (N'Web Development', 1, 6),
    (N'Database Administration', 1, 5),
    (N'Mobile Development', 2, 6),
    (N'Cloud Computing', 2, 5),
    (N'Data Science', 3, 7),
    (N'Cybersecurity', 3, 6);
GO

-- ============================================================================
-- SECTION 3: INSERT COURSES (5+ courses)
-- ============================================================================
INSERT INTO Course (CourseName, MinDegree, MaxDegree) VALUES 
    (N'SQL Server Fundamentals', 40, 100),
    (N'Advanced SQL Queries', 40, 100),
    (N'Database Design', 40, 100),
    (N'C# Programming', 40, 100),
    (N'Web Development with ASP.NET', 40, 100),
    (N'JavaScript Essentials', 40, 100),
    (N'Python for Data Science', 40, 100);
GO

-- ============================================================================
-- SECTION 4: LINK TRACKS TO COURSES
-- ============================================================================
INSERT INTO Track_Course (TrackID, CourseID) VALUES 
    (1, 4), (1, 5), (1, 6),  -- Web Development
    (2, 1), (2, 2), (2, 3),  -- Database Administration
    (3, 4), (3, 6),          -- Mobile Development
    (4, 1), (4, 2),          -- Cloud Computing
    (5, 7), (5, 2),          -- Data Science
    (6, 1), (6, 2);          -- Cybersecurity
GO

-- ============================================================================
-- SECTION 5: INSERT INSTRUCTORS (3+ instructors)
-- ============================================================================
INSERT INTO Instructor (InstructorName, Email, DepartmentNo) VALUES 
    (N'Dr. Ahmed Hassan', N'ahmed.hassan@iti.edu.eg', 1),
    (N'Eng. Fatima Mohamed', N'fatima.mohamed@iti.edu.eg', 2),
    (N'Prof. Karim Ibrahim', N'karim.ibrahim@iti.edu.eg', 1),
    (N'Ms. Layla Saleh', N'layla.saleh@iti.edu.eg', 3),
    (N'Mr. Hassan Ali', N'hassan.ali@iti.edu.eg', 2);
GO

-- ============================================================================
-- SECTION 6: ASSIGN INSTRUCTORS TO COURSES (2+ courses per instructor)
-- ============================================================================
INSERT INTO Instructor_Course (InstructorID, CourseID) VALUES 
    (1, 1), (1, 2), (1, 3),        -- Dr. Ahmed Hassan teaches SQL courses
    (2, 4), (2, 5),                -- Eng. Fatima Mohamed teaches C# and ASP.NET
    (3, 6), (3, 7),                -- Prof. Karim Ibrahim teaches JavaScript and Python
    (4, 1), (4, 2),                -- Ms. Layla Saleh teaches SQL courses
    (5, 4), (5, 5);                -- Mr. Hassan Ali teaches C# and ASP.NET
GO

-- ============================================================================
-- SECTION 7: INSERT STUDENTS (20+ students)
-- ============================================================================
INSERT INTO Student (StudentName, Email, Phone) VALUES 
    (N'Mohamed Ali', N'student1@iti.edu.eg', N'01001234567'),
    (N'Fatma Ahmed', N'student2@iti.edu.eg', N'01001234568'),
    (N'Ali Mahmoud', N'student3@iti.edu.eg', N'01001234569'),
    (N'Sara Hassan', N'student4@iti.edu.eg', N'01001234570'),
    (N'Ahmed Ibrahim', N'student5@iti.edu.eg', N'01001234571'),
    (N'Layla Omar', N'student6@iti.edu.eg', N'01001234572'),
    (N'Mahmoud Salem', N'student7@iti.edu.eg', N'01001234573'),
    (N'Nour Khaled', N'student8@iti.edu.eg', N'01001234574'),
    (N'Hassan Mohamed', N'student9@iti.edu.eg', N'01001234575'),
    (N'Maryam Yassin', N'student10@iti.edu.eg', N'01001234576'),
    (N'Omar Farouk', N'student11@iti.edu.eg', N'01001234577'),
    (N'Dina Osama', N'student12@iti.edu.eg', N'01001234578'),
    (N'Khaled Hussein', N'student13@iti.edu.eg', N'01001234579'),
    (N'Rana Mahmoud', N'student14@iti.edu.eg', N'01001234580'),
    (N'Ibrahim Ali', N'student15@iti.edu.eg', N'01001234581'),
    (N'Yasmine Ahmed', N'student16@iti.edu.eg', N'01001234582'),
    (N'Sami Mohamed', N'student17@iti.edu.eg', N'01001234583'),
    (N'Hana Hassan', N'student18@iti.edu.eg', N'01001234584'),
    (N'Tarek Ibrahim', N'student19@iti.edu.eg', N'01001234585'),
    (N'Reem Ali', N'student20@iti.edu.eg', N'01001234586');
GO

-- ============================================================================
-- SECTION 8: ASSIGN STUDENTS TO TRACKS
-- ============================================================================
INSERT INTO Student_Track (StudentID, TrackID) VALUES 
    (1, 1), (2, 1), (3, 1), (4, 1), (5, 1),     -- Track 1: Web Development
    (6, 2), (7, 2), (8, 2), (9, 2), (10, 2),   -- Track 2: Database Administration
    (11, 3), (12, 3), (13, 3), (14, 3),        -- Track 3: Mobile Development
    (15, 4), (16, 4), (17, 4),                 -- Track 4: Cloud Computing
    (18, 5), (19, 5), (20, 5);                 -- Track 5: Data Science
GO
