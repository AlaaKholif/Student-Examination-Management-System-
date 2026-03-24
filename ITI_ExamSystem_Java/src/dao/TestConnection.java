package dao;

import dao.DatabaseConnection;
import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        System.out.println("Attempting to connect to the database...");

        // Calling getConnection() will trigger the file read and connection attempt
        Connection conn = DatabaseConnection.getConnection();

        if (conn != null) {
            System.out.println("SUCCESS! The properties file was read and the database is connected.");
        } else {
            System.out.println("FAILED. Check the error messages above.");
        }
    }
}