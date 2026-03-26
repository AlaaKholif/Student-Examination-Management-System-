package dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class QuestionDAO {

    public boolean insertQuestion(int courseId, String type, String text, String optA, String optB, String optC, String optD, String correctAnswer) {
        String call = "{call InsertFullQuestion(?, ?, ?, ?, ?, ?, ?, ?)}";

        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(call)) {

            cstmt.setInt(1, courseId);
            cstmt.setString(2, type);
            cstmt.setString(3, text);
            cstmt.setString(4, optA);
            cstmt.setString(5, optB);
            cstmt.setString(6, optC);
            cstmt.setString(7, optD);
            cstmt.setString(8, correctAnswer);

            cstmt.execute();
            return true;

        } catch (SQLException e) {
            System.err.println("Error inserting question: " + e.getMessage());
            return false;
        }
    }
}