package dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {

    /**
     * Retrieves all questions belonging to courses taught by the logged-in instructor.
     */
    public List<Object[]> getInstructorQuestions(int instructorId) {
        List<Object[]> questionData = new ArrayList<>();

        // We join Question to Instructor_Course to only get questions this instructor has rights to
        String query =
                "SELECT Q.QuestionID, C.CourseName, Q.QuestionType, Q.QuestionText " +
                        "FROM Question Q " +
                        "INNER JOIN Course C ON Q.CourseID = C.CourseID " +
                        "INNER JOIN Instructor_Course IC ON C.CourseID = IC.CourseID " +
                        "WHERE IC.InstructorID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, instructorId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Object[] row = new Object[4];
                row[0] = rs.getInt("QuestionID");
                row[1] = rs.getString("CourseName");
                row[2] = rs.getString("QuestionType");
                row[3] = rs.getString("QuestionText");
                questionData.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching questions: " + e.getMessage());
        }

        return questionData;
    }

    /**
     * Calls the Report_InstructorCourses stored procedure.
     */
    public List<Object[]> getInstructorCourses(int instructorId) {
        List<Object[]> courseData = new ArrayList<>();
        String call = "{call Report_InstructorCourses(?)}";

        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(call)) {

            cstmt.setInt(1, instructorId);
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                Object[] row = new Object[3];
                row[0] = rs.getString("CourseName");
                row[1] = rs.getString("TrackName");
                row[2] = rs.getInt("StudentCount");
                courseData.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching instructor reports: " + e.getMessage());
        }

        return courseData;
    }
}
