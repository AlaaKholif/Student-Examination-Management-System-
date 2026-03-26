package dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class ExamDAO {

    /**
     * Calls the GenerateExam stored procedure.
     * Returns true if successful, false otherwise.
     */
    public boolean generateExam(int courseId, String examName, int numMcq, int numTf, int durationMinutes) {
        String call = "{call GenerateExam(?, ?, ?, ?, ?)}";

        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(call)) {

            cstmt.setInt(1, courseId);
            cstmt.setString(2, examName);
            cstmt.setInt(3, numMcq);
            cstmt.setInt(4, numTf);
            cstmt.setInt(5, durationMinutes);

            cstmt.execute();
            return true;

        } catch (SQLException e) {
            System.err.println("Error generating exam: " + e.getMessage());
            return false;
        }
    }
}