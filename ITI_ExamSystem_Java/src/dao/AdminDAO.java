package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    /**
     * Retrieves all students for the Admin table.
     */
    public List<Object[]> getAllStudents() {
        List<Object[]> students = new ArrayList<>();
        String query = "SELECT StudentID, StudentName, Email, Phone FROM Student";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Object[] row = new Object[4];
                row[0] = rs.getInt("StudentID");
                row[1] = rs.getString("StudentName");
                row[2] = rs.getString("Email");
                row[3] = rs.getString("Phone");
                students.add(row);
            }
        } catch (SQLException e) {
            System.err.println("Error fetching students: " + e.getMessage());
        }

        return students;
    }

    /**
     * Calls the DeleteStudent stored procedure.
     */
    public boolean deleteStudent(int studentId) {
        String call = "{call DeleteStudent(?)}";

        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.CallableStatement cstmt = conn.prepareCall(call)) {

            cstmt.setInt(1, studentId);
            cstmt.execute();
            return true;

        } catch (java.sql.SQLException e) {
            System.err.println("Error deleting student: " + e.getMessage());
            return false;
        }
    }
    /**
     * Calls the InsertStudent stored procedure.
     */
    public boolean insertStudent(String name, String email, String phone) {
        String call = "{call InsertStudent(?, ?, ?)}";

        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(call)) {

            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setString(3, phone);

            pstmt.execute();
            return true;

        } catch (java.sql.SQLException e) {
            System.err.println("Error adding new student: " + e.getMessage());
            return false;
        }
    }
    /**
     * Calls the UpdateStudent stored procedure.
     */
    public boolean updateStudent(int studentId, String name, String email, String phone) {
        String call = "{call UpdateStudent(?, ?, ?, ?)}";

        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(call)) {

            // Note the order matches your SQL procedure: ID, Name, Email, Phone
            pstmt.setInt(1, studentId);
            pstmt.setString(2, name);
            pstmt.setString(3, email);
            pstmt.setString(4, phone);

            pstmt.execute();
            return true;

        } catch (java.sql.SQLException e) {
            System.err.println("Error updating student: " + e.getMessage());
            return false;
        }
    }
    // ============================================================================
    // INSTRUCTOR CRUD OPERATIONS
    // ============================================================================

    public List<Object[]> getAllInstructors() {
        List<Object[]> instructors = new ArrayList<>();
        String query = "SELECT InstructorID, InstructorName, Email, DepartmentNo FROM Instructor";

        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(query);
             java.sql.ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Object[] row = new Object[4];
                row[0] = rs.getInt("InstructorID");
                row[1] = rs.getString("InstructorName");
                row[2] = rs.getString("Email");
                row[3] = rs.getInt("DepartmentNo");
                instructors.add(row);
            }
        } catch (java.sql.SQLException e) {
            System.err.println("Error fetching instructors: " + e.getMessage());
        }
        return instructors;
    }

    public boolean insertInstructor(String name, String email, int deptNo) {
        String call = "{call InsertInstructor(?, ?, ?)}";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(call)) {
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setInt(3, deptNo);
            pstmt.execute();
            return true;
        } catch (java.sql.SQLException e) {
            System.err.println("Error adding instructor: " + e.getMessage());
            return false;
        }
    }

    public boolean updateInstructor(int id, String name, String email, int deptNo) {
        String call = "{call UpdateInstructor(?, ?, ?, ?)}";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(call)) {
            pstmt.setInt(1, id);
            pstmt.setString(2, name);
            pstmt.setString(3, email);
            pstmt.setInt(4, deptNo);
            pstmt.execute();
            return true;
        } catch (java.sql.SQLException e) {
            System.err.println("Error updating instructor: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteInstructor(int instructorId) {
        String call = "{call DeleteInstructor(?)}";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.CallableStatement cstmt = conn.prepareCall(call)) {
            cstmt.setInt(1, instructorId);
            cstmt.execute();
            return true;
        } catch (java.sql.SQLException e) {
            System.err.println("Error deleting instructor: " + e.getMessage());
            return false;
        }
    }
    // ============================================================================
    // COURSE CRUD OPERATIONS
    // ============================================================================

    public List<Object[]> getAllCourses() {
        List<Object[]> courses = new ArrayList<>();
        // Querying the table directly for the master view
        String query = "SELECT CourseID, CourseName, MinDegree, MaxDegree FROM Course";

        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(query);
             java.sql.ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Object[] row = new Object[4];
                row[0] = rs.getInt("CourseID");
                row[1] = rs.getString("CourseName");
                row[2] = rs.getInt("MinDegree");
                row[3] = rs.getInt("MaxDegree");
                courses.add(row);
            }
        } catch (java.sql.SQLException e) {
            System.err.println("Error fetching courses: " + e.getMessage());
        }
        return courses;
    }

    public boolean insertCourse(String name, int minDegree, int maxDegree) {
        String call = "{call InsertCourse(?, ?, ?)}";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(call)) {
            pstmt.setString(1, name);
            pstmt.setInt(2, minDegree);
            pstmt.setInt(3, maxDegree);
            pstmt.execute();
            return true;
        } catch (java.sql.SQLException e) {
            System.err.println("Error adding course: " + e.getMessage());
            return false;
        }
    }

    public boolean updateCourse(int id, String name, int minDegree, int maxDegree) {
        String call = "{call UpdateCourse(?, ?, ?, ?)}";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(call)) {
            pstmt.setInt(1, id);
            pstmt.setString(2, name);
            pstmt.setInt(3, minDegree);
            pstmt.setInt(4, maxDegree);
            pstmt.execute();
            return true;
        } catch (java.sql.SQLException e) {
            System.err.println("Error updating course: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteCourse(int courseId) {
        String call = "{call DeleteCourse(?)}";
        try (java.sql.Connection conn = DatabaseConnection.getConnection();
             java.sql.CallableStatement cstmt = conn.prepareCall(call)) {
            cstmt.setInt(1, courseId);
            cstmt.execute();
            return true;
        } catch (java.sql.SQLException e) {
            System.err.println("Error deleting course: " + e.getMessage());
            return false;
        }
    }
}