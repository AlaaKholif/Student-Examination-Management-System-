package dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DatabaseConnection {

    private static Connection connection = null;

    // Private constructor prevents instantiation
    private DatabaseConnection() {}

    public static Connection getConnection() {
        try {
            // Only create a new connection if one doesn't exist or is closed
            if (connection == null || connection.isClosed()) {

                // 1. Load the properties file
                Properties properties = new Properties();

                // This looks for database.properties at the root of your src folder
                try (InputStream input = DatabaseConnection.class.getClassLoader().getResourceAsStream("database.properties")) {
                    if (input == null) {
                        System.err.println("ERROR: Unable to find database.properties in the src folder!");
                        return null;
                    }
                    properties.load(input);
                }

                // 2. Load the SQL Server Driver
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

                // 3. Establish the connection using the properties
                connection = DriverManager.getConnection(
                        properties.getProperty("db.url"),
                        properties.getProperty("db.user"),
                        properties.getProperty("db.password")
                );

                System.out.println("Database connection established successfully via properties file!");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("ERROR: JDBC Driver not found. Did you add the mssql-jdbc jar to your project?");
        } catch (Exception e) {
            System.err.println("ERROR: Connection Failed: " + e.getMessage());
        }

        return connection;
    }
}