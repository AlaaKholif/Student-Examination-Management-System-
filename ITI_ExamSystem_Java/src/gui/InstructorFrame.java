package gui;

import dao.ExamDAO;
import dao.ReportDAO; // Make sure this is imported!
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.List;

public class InstructorFrame extends JFrame {



    // 1. Create a variable to hold the ID of the logged-in instructor
    private int loggedInInstructorId;

    // 2. Update the constructor to require the ID as a parameter
    public InstructorFrame(int instructorId) {

        // 3. Save the passed ID into our variable
        this.loggedInInstructorId = instructorId;

        setTitle("ITI Exam System - Instructor Panel (ID: " + loggedInInstructorId + ")");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(500, 450);
        setLocationRelativeTo(null);



        JTabbedPane tabbedPane = new JTabbedPane();

        // Add the tabs
        tabbedPane.addTab("Generate Exam", createGenerateExamPanel());
        tabbedPane.addTab("Reports", createReportsPanel());
        tabbedPane.addTab("Manage Questions", createManageQuestionsPanel()); // Placeholder for later

        add(tabbedPane, BorderLayout.CENTER);

        // Logout button at the bottom
        JPanel bottomPanel = new JPanel();
        JButton logoutButton = new JButton("Logout");
        logoutButton.addActionListener(e -> {
            this.dispose();
            new LoginFrame().setVisible(true);
        });
        bottomPanel.add(logoutButton);
        add(bottomPanel, BorderLayout.SOUTH);
    }

    private JPanel createGenerateExamPanel() {
        JPanel panel = new JPanel(new GridBagLayout());
        panel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.insets = new Insets(10, 10, 10, 10);

        // Form Fields
        JTextField courseIdField = new JTextField(15);
        JTextField examNameField = new JTextField(15);
        JTextField mcqCountField = new JTextField("5", 15);
        JTextField tfCountField = new JTextField("2", 15);
        JTextField durationField = new JTextField("180", 15); // Default 3 hours

        // Layout the form
        gbc.gridx = 0; gbc.gridy = 0; panel.add(new JLabel("Course ID:"), gbc);
        gbc.gridx = 1; panel.add(courseIdField, gbc);

        gbc.gridx = 0; gbc.gridy = 1; panel.add(new JLabel("Exam Name:"), gbc);
        gbc.gridx = 1; panel.add(examNameField, gbc);

        gbc.gridx = 0; gbc.gridy = 2; panel.add(new JLabel("MCQ Count:"), gbc);
        gbc.gridx = 1; panel.add(mcqCountField, gbc);

        gbc.gridx = 0; gbc.gridy = 3; panel.add(new JLabel("T/F Count:"), gbc);
        gbc.gridx = 1; panel.add(tfCountField, gbc);

        gbc.gridx = 0; gbc.gridy = 4; panel.add(new JLabel("Duration (Minutes):"), gbc);
        gbc.gridx = 1; panel.add(durationField, gbc);

        // Generate Button
        JButton generateButton = new JButton("Generate Exam");
        gbc.gridx = 0; gbc.gridy = 5; gbc.gridwidth = 2;
        panel.add(generateButton, gbc);

        // Button Action
        generateButton.addActionListener(e -> {
            try {
                int courseId = Integer.parseInt(courseIdField.getText());
                String examName = examNameField.getText();
                int mcq = Integer.parseInt(mcqCountField.getText());
                int tf = Integer.parseInt(tfCountField.getText());
                int duration = Integer.parseInt(durationField.getText());

                ExamDAO dao = new ExamDAO();
                boolean success = dao.generateExam(courseId, examName, mcq, tf, duration);

                if (success) {
                    JOptionPane.showMessageDialog(this, "Exam generated successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);
                    examNameField.setText(""); // clear field
                } else {
                    JOptionPane.showMessageDialog(this, "Failed to generate exam. Check Course ID and available questions.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(this, "Please enter valid numbers for ID, counts, and duration.", "Input Error", JOptionPane.ERROR_MESSAGE);
            }
        });

        return panel;
    }

    private JPanel createReportsPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // Title
        JLabel titleLabel = new JLabel("Your Assigned Courses & Enrollment");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 16));
        panel.add(titleLabel, BorderLayout.NORTH);

        // Define the table columns based on our stored procedure output
        String[] columnNames = {"Course Name", "Track Name", "Total Students"};
        DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0);

        // Fetch the data using the DAO
        dao.ReportDAO reportDAO = new dao.ReportDAO();
        List<Object[]> courses = reportDAO.getInstructorCourses(loggedInInstructorId);

        // Populate the table
        for (Object[] row : courses) {
            tableModel.addRow(row);
        }

        JTable reportTable = new JTable(tableModel);
        reportTable.setEnabled(false); // Make it read-only

        // Add it to a scroll pane so the column headers appear
        panel.add(new JScrollPane(reportTable), BorderLayout.CENTER);

        // Add a Refresh button at the bottom just in case new students are added
        JPanel bottomPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        JButton refreshButton = new JButton("Refresh Data");

        refreshButton.addActionListener(e -> {
            tableModel.setRowCount(0); // Clear existing rows
            List<Object[]> freshData = reportDAO.getInstructorCourses(loggedInInstructorId);
            for (Object[] row : freshData) {
                tableModel.addRow(row);
            }
        });

        bottomPanel.add(refreshButton);
        panel.add(bottomPanel, BorderLayout.SOUTH);

        return panel;
    }

    private JPanel createManageQuestionsPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // Top Panel: Title and Add Button
        JPanel topPanel = new JPanel(new BorderLayout());
        JLabel titleLabel = new JLabel("Question Bank for Your Courses");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 16));
        topPanel.add(titleLabel, BorderLayout.WEST);

        JButton addQuestionButton = new JButton("+ Add New Question");
        addQuestionButton.addActionListener(e -> {
            openAddQuestionWizard();
        });
        topPanel.add(addQuestionButton, BorderLayout.EAST);

        panel.add(topPanel, BorderLayout.NORTH);

        // Center Panel: The Table
        String[] columnNames = {"ID", "Course", "Type", "Question Text"};
        javax.swing.table.DefaultTableModel tableModel = new javax.swing.table.DefaultTableModel(columnNames, 0);

        // Fetch data using DAO
        dao.ReportDAO reportDAO = new dao.ReportDAO();
        List<Object[]> questions = reportDAO.getInstructorQuestions(loggedInInstructorId);

        for (Object[] row : questions) {
            tableModel.addRow(row);
        }

        JTable questionTable = new JTable(tableModel);
        questionTable.setEnabled(false); // Read-only for now

        // Adjust column widths so the text has more room
        questionTable.getColumnModel().getColumn(0).setPreferredWidth(50);
        questionTable.getColumnModel().getColumn(1).setPreferredWidth(150);
        questionTable.getColumnModel().getColumn(2).setPreferredWidth(50);
        questionTable.getColumnModel().getColumn(3).setPreferredWidth(400);

        panel.add(new JScrollPane(questionTable), BorderLayout.CENTER);

        return panel;
    }
    private void openAddQuestionWizard() {
        JDialog dialog = new JDialog(this, "Add New Question Wizard", true);
        dialog.setSize(400, 450);
        dialog.setLocationRelativeTo(this);
        dialog.setLayout(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.insets = new Insets(5, 5, 5, 5);

        // Fields
        JTextField courseIdField = new JTextField();
        JComboBox<String> typeCombo = new JComboBox<>(new String[]{"MCQ", "TF"});
        JTextArea questionTextField = new JTextArea(3, 20);
        questionTextField.setLineWrap(true);

        JTextField optAField = new JTextField();
        JTextField optBField = new JTextField();
        JTextField optCField = new JTextField();
        JTextField optDField = new JTextField();
        JComboBox<String> correctCombo = new JComboBox<>(new String[]{"A", "B", "C", "D"});

        // Dynamic UI logic: Hide options C and D if TF is selected
        typeCombo.addActionListener(e -> {
            boolean isMCQ = "MCQ".equals(typeCombo.getSelectedItem());
            optAField.setEnabled(isMCQ);
            optBField.setEnabled(isMCQ);
            optCField.setEnabled(isMCQ);
            optDField.setEnabled(isMCQ);

            correctCombo.removeAllItems();
            if (isMCQ) {
                correctCombo.addItem("A"); correctCombo.addItem("B"); correctCombo.addItem("C"); correctCombo.addItem("D");
            } else {
                correctCombo.addItem("T"); correctCombo.addItem("F");
            }
        });

        // Add components to dialog layout
        int row = 0;
        gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Course ID:"), gbc);
        gbc.gridx = 1; dialog.add(courseIdField, gbc);

        row++; gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Type:"), gbc);
        gbc.gridx = 1; dialog.add(typeCombo, gbc);

        row++; gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Question:"), gbc);
        gbc.gridx = 1; dialog.add(new JScrollPane(questionTextField), gbc);

        row++; gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Option A:"), gbc);
        gbc.gridx = 1; dialog.add(optAField, gbc);

        row++; gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Option B:"), gbc);
        gbc.gridx = 1; dialog.add(optBField, gbc);

        row++; gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Option C:"), gbc);
        gbc.gridx = 1; dialog.add(optCField, gbc);

        row++; gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Option D:"), gbc);
        gbc.gridx = 1; dialog.add(optDField, gbc);

        row++; gbc.gridx = 0; gbc.gridy = row; dialog.add(new JLabel("Correct Answer:"), gbc);
        gbc.gridx = 1; dialog.add(correctCombo, gbc);

        // Save Button
        JButton saveButton = new JButton("Save Question");
        row++; gbc.gridx = 0; gbc.gridy = row; gbc.gridwidth = 2;
        dialog.add(saveButton, gbc);

        saveButton.addActionListener(e -> {
            try {
                int courseId = Integer.parseInt(courseIdField.getText());
                String type = (String) typeCombo.getSelectedItem();
                String text = questionTextField.getText();
                String correct = (String) correctCombo.getSelectedItem();

                dao.QuestionDAO dao = new dao.QuestionDAO();
                boolean success = dao.insertQuestion(courseId, type, text, optAField.getText(), optBField.getText(), optCField.getText(), optDField.getText(), correct);

                if (success) {
                    JOptionPane.showMessageDialog(dialog, "Question saved successfully!");
                    dialog.dispose(); // Close wizard
                } else {
                    JOptionPane.showMessageDialog(dialog, "Database error. Check constraints.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(dialog, "Invalid Course ID.", "Input Error", JOptionPane.ERROR_MESSAGE);
            }
        });

        dialog.setVisible(true);
    }
}
