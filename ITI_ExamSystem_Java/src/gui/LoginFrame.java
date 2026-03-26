package gui;

import javax.swing.*;
import java.awt.*;
import com.formdev.flatlaf.FlatLightLaf;
import com.formdev.flatlaf.FlatDarkLaf;
import javax.swing.UIManager;
import javax.swing.SwingUtilities;

/**
 * gui.LoginFrame Class
 * Purpose: Main login screen for the application
 * Allows users to select their role (Admin, Instructor, Student)
 */
public class LoginFrame extends JFrame {
    private final JComboBox<String> roleComboBox;
    private final JTextField usernameField;
    private final JPasswordField passwordField;

    public LoginFrame() {
        setTitle("ITI Exam System - Login");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(400, 300);
        setLocationRelativeTo(null);
        setResizable(false);
        
        // Main panel
        JPanel mainPanel = new JPanel();
        mainPanel.setLayout(new GridBagLayout());
        mainPanel.setBackground(new Color(240, 240, 240));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10);
        
        // Title
        JLabel titleLabel = new JLabel("ITI Exam System");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 20));
        gbc.gridx = 0;
        gbc.gridy = 0;
        gbc.gridwidth = 2;
        mainPanel.add(titleLabel, gbc);
        
        // Role label and combo box
        gbc.gridwidth = 1;
        gbc.gridy = 1;
        JLabel roleLabel = new JLabel("Role:");
        mainPanel.add(roleLabel, gbc);
        
        gbc.gridx = 1;
        roleComboBox = new JComboBox<>(new String[]{"Admin", "Instructor", "Student"});
        mainPanel.add(roleComboBox, gbc);
        
        // Username label and field
        gbc.gridx = 0;
        gbc.gridy = 2;
        JLabel usernameLabel = new JLabel("Email:");
        mainPanel.add(usernameLabel, gbc);
        
        gbc.gridx = 1;
        usernameField = new JTextField(15);
        mainPanel.add(usernameField, gbc);
        
        // Password label and field
        gbc.gridx = 0;
        gbc.gridy = 3;
        JLabel passwordLabel = new JLabel("Password:");
        mainPanel.add(passwordLabel, gbc);
        
        gbc.gridx = 1;
        passwordField = new JPasswordField(15);
        mainPanel.add(passwordField, gbc);
        
        // Buttons panel
        JPanel buttonPanel = new JPanel();
        buttonPanel.setBackground(new Color(240, 240, 240));

        JButton loginButton = new JButton("Login");
        loginButton.setPreferredSize(new Dimension(100, 30));
        loginButton.addActionListener(_ -> handleLogin());
        buttonPanel.add(loginButton);

        JButton exitButton = new JButton("Exit");
        exitButton.setPreferredSize(new Dimension(100, 30));
        exitButton.addActionListener(_ -> System.exit(0));
        buttonPanel.add(exitButton);
        
        gbc.gridx = 0;
        gbc.gridy = 4;
        gbc.gridwidth = 2;
        mainPanel.add(buttonPanel, gbc);
        
        add(mainPanel);
    }
    
    /**
     * Handle login button click
     * For demo purposes, accepts any non-empty username/password
     */
    private void handleLogin() {
        String email = usernameField.getText(); // Note: Instruct users to use their Email here
        String password = new String(passwordField.getPassword());
        String role = (String) roleComboBox.getSelectedItem();

        if (email.isEmpty() || password.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please enter both email and password.", "Input Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        // Instantiate the DAO and check the database
        dao.UserDAO userDAO = new dao.UserDAO();
        // We get the ID from the database (e.g., it returns 1 for Ahmed)
        int loggedInId = userDAO.validateLogin(role, email, password);

        if (loggedInId != -1) {
            this.setVisible(false); // Hide login window

            if ("Admin".equals(role)) {
                new AdminFrame().setVisible(true);
            } else if ("Instructor".equals(role)) {
                // Pass the ID into the constructor we just updated!
                new InstructorFrame(loggedInId).setVisible(true);
            } else if ("Student".equals(role)) {
                // (You will do the exact same thing for the StudentFrame later)
                new StudentFrame(loggedInId).setVisible(true);
            }
        } else {
            JOptionPane.showMessageDialog(this, "Invalid credentials.", "Login Failed", JOptionPane.ERROR_MESSAGE);
        }
    }

    public static void main(String[] args) {
        // 1. Initialize the modern light theme BEFORE creating the window
        try {
            UIManager.setLookAndFeel(new FlatLightLaf());

            // Highly recommended: override the default 90s font with a modern one
            UIManager.put("defaultFont", new java.awt.Font("Segoe UI", java.awt.Font.PLAIN, 14));
        } catch (Exception ex) {
            System.err.println("Failed to initialize modern UI theme.");
        }

        // 2. Launch the application safely
        SwingUtilities.invokeLater(() -> new LoginFrame().setVisible(true));
    }
}
