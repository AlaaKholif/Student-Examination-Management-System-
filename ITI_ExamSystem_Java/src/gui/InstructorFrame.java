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
        setSize(800, 600);
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
        // Create the Dropdown
        JComboBox<CourseItem> courseComboBox = new JComboBox<>();

        // Fetch courses from the database using our existing DAO
        dao.AdminDAO adminDAO = new dao.AdminDAO();
        java.util.List<Object[]> courses = adminDAO.getAllCourses();

        for (Object[] row : courses) {
            // Safely parse the ID and Name
            int id = Integer.parseInt(row[0].toString());
            String name = row[1].toString();

            // Add them to the dropdown
            courseComboBox.addItem(new CourseItem(id, name));
        }
        JTextField examNameField = new JTextField(15);
        JTextField mcqCountField = new JTextField("5", 15);
        JTextField tfCountField = new JTextField("2", 15);
        JTextField durationField = new JTextField("60", 15); // Default 1 hours

        // Layout the form
        gbc.gridx = 0; gbc.gridy = 0; panel.add(new JLabel("Course:"), gbc);
        gbc.gridx = 1; panel.add(courseComboBox, gbc);

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
                // 1. Safely extract the ID from the selected dropdown item
                CourseItem selectedCourse = (CourseItem) courseComboBox.getSelectedItem();
                if (selectedCourse == null) {
                    JOptionPane.showMessageDialog(this, "Please select a course.", "Input Error", JOptionPane.WARNING_MESSAGE);
                    return;
                }
                int courseId = selectedCourse.getId();

                // 2. Grab the rest of the text fields
                String examName = examNameField.getText().trim();
                if (examName.isEmpty()) {
                    JOptionPane.showMessageDialog(this, "Please enter an Exam Name.", "Input Error", JOptionPane.WARNING_MESSAGE);
                    return;
                }

                int mcq = Integer.parseInt(mcqCountField.getText().trim());
                int tf = Integer.parseInt(tfCountField.getText().trim());
                int duration = Integer.parseInt(durationField.getText().trim());

                // 3. Send to database
                ExamDAO dao = new ExamDAO();
                boolean success = dao.generateExam(courseId, examName, mcq, tf, duration);

                if (success) {
                    JOptionPane.showMessageDialog(this, "Exam generated successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);
                    // Clear all fields so they can quickly generate another one
                    examNameField.setText("");
                    mcqCountField.setText("");
                    tfCountField.setText("");
                    durationField.setText("");
                    courseComboBox.setSelectedIndex(0); // Reset dropdown to the first course
                } else {
                    JOptionPane.showMessageDialog(this, "Failed to generate exam. Ensure the question bank has enough questions for this course.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            } catch (NumberFormatException ex) {
                // Now this error ONLY triggers if they mess up the MCQ, T/F, or Duration boxes
                JOptionPane.showMessageDialog(this, "Please enter valid numbers for counts and duration.", "Input Error", JOptionPane.ERROR_MESSAGE);
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
        // Create the Dropdown
        JComboBox<CourseItem> courseComboBox = new JComboBox<>();

        // Fetch courses from the database using our existing DAO
        dao.AdminDAO adminDAO = new dao.AdminDAO();
        java.util.List<Object[]> courses = adminDAO.getAllCourses();

        for (Object[] row : courses) {
            // Safely parse the ID and Name
            int id = Integer.parseInt(row[0].toString());
            String name = row[1].toString();

            // Add them to the dropdown
            courseComboBox.addItem(new CourseItem(id, name));
        }
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
        gbc.gridx = 1; dialog.add(courseComboBox, gbc);

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
            // 1. Safely extract the ID from the selected dropdown item
            CourseItem selectedCourse = (CourseItem) courseComboBox.getSelectedItem();
            if (selectedCourse == null) {
                JOptionPane.showMessageDialog(dialog, "Please select a course.", "Input Error", JOptionPane.WARNING_MESSAGE);
                return;
            }
            int courseId = selectedCourse.getId();

            // 2. Grab the rest of the inputs
            String type = (String) typeCombo.getSelectedItem();
            String text = questionTextField.getText().trim();
            String correct = (String) correctCombo.getSelectedItem();

            // 3. Validation: Prevent saving empty questions
            if (text.isEmpty()) {
                JOptionPane.showMessageDialog(dialog, "Question text cannot be empty.", "Input Error", JOptionPane.WARNING_MESSAGE);
                return;
            }

            // 4. Send to database
            dao.QuestionDAO dao = new dao.QuestionDAO();
            boolean success = dao.insertQuestion(
                    courseId,
                    type,
                    text,
                    optAField.getText().trim(),
                    optBField.getText().trim(),
                    optCField.getText().trim(),
                    optDField.getText().trim(),
                    correct
            );

            // 5. Handle the result
            if (success) {
                JOptionPane.showMessageDialog(dialog, "Question saved successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);
                dialog.dispose(); // Close wizard smoothly
            } else {
                JOptionPane.showMessageDialog(dialog, "Database error. Could not save the question. Check constraints.", "Error", JOptionPane.ERROR_MESSAGE);
            }
        });

        dialog.setVisible(true);
    }
}
