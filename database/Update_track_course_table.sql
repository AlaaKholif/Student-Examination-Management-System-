-- 1. Check current state (Optional but recommended)
SELECT * FROM Track_Course WHERE TrackID = 1;

-- 2. Perform the Update
-- We change the CourseID from 4 to 1 for Track 1
UPDATE Track_Course
SET CourseID = 1
WHERE TrackID = 1 AND CourseID = 4;

-- 3. Verify the change
SELECT * FROM Track_Course WHERE TrackID = 1;
