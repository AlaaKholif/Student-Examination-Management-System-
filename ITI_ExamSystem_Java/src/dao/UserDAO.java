package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    /**
     * Validates the user credentials against the database.
     * Returns the user's ID (StudentID or InstructorID) if valid, or -1 if invalid.
     */
    public int validateLogin(String role, String email, String password) {
        String query = "";

        // Determine which table to query based on the selected role
        if ("Student".equals(role)) {
            query = "SELECT StudentID FROM Student WHERE Email = ? AND Password = ?";
        } else if ("Instructor".equals(role)) {
            query = "SELECT InstructorID FROM Instructor WHERE Email = ? AND Password = ?";
        } else if ("Admin".equals(role)) {
            // Updated: Now points to the actual Admin table in SQL Server
            query = "SELECT AdminID FROM Admin WHERE Email = ? AND Password = ?";
        }

        // Execute the query securely using PreparedStatement to prevent SQL injection
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, email);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                // Return the first column, which is the ID we requested in the SELECT statement
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.err.println("Database error during login validation: " + e.getMessage());
        }

        return -1; // Return -1 if no matching record is found
    }
}