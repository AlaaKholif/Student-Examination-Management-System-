package gui;

import dao.AdminDAO;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.List;

public class AdminFrame extends JFrame {

    public AdminFrame() {
        setTitle("ITI Exam System - System Administration");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(800, 600);
        setLocationRelativeTo(null);

        JTabbedPane tabbedPane = new JTabbedPane();

        // Add the primary management tabs
        tabbedPane.addTab("Manage Students", createStudentsPanel());
        tabbedPane.addTab("Manage Instructors", createInstructorsPanel());
        tabbedPane.addTab("Manage Courses", createCoursesPanel());

        add(tabbedPane, BorderLayout.CENTER);

        // Bottom Logout Button
        JPanel bottomPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        JButton logoutButton = new JButton("Logout");
        logoutButton.addActionListener(e -> {
            this.dispose();
            new LoginFrame().setVisible(true);
        });
        bottomPanel.add(logoutButton);
        add(bottomPanel, BorderLayout.SOUTH);
    }

    private JPanel createStudentsPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // Header
        JLabel titleLabel = new JLabel("Student Directory");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 18));
        panel.add(titleLabel, BorderLayout.NORTH);

        // Table Setup
        String[] columnNames = {"ID", "Name", "Email", "Phone"};
        DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false; // Prevent direct editing in the table
            }
        };

        // Load Data
        AdminDAO adminDAO = new AdminDAO();
        List<Object[]> students = adminDAO.getAllStudents();
        for (Object[] row : students) {
            tableModel.addRow(row);
        }

        JTable studentTable = new JTable(tableModel);
        studentTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        panel.add(new JScrollPane(studentTable), BorderLayout.CENTER);

        // Action Buttons (Add, Edit, Delete)
        JPanel actionPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JButton addButton = new JButton("Add New Student");
        JButton editButton = new JButton("Edit Selected");
        JButton deleteButton = new JButton("Delete Selected");

        deleteButton.setForeground(Color.RED);

        addButton.addActionListener(e -> {
            // 1. Create the input fields
            JTextField nameField = new JTextField(15);
            JTextField emailField = new JTextField(15);
            JTextField phoneField = new JTextField(15);

            // 2. Add them to a clean Grid layout
            JPanel inputPanel = new JPanel(new GridLayout(3, 2, 5, 10));
            inputPanel.add(new JLabel("Full Name:"));
            inputPanel.add(nameField);
            inputPanel.add(new JLabel("Email Address:"));
            inputPanel.add(emailField);
            inputPanel.add(new JLabel("Phone Number:"));
            inputPanel.add(phoneField);

            // 3. Show the pop-up wizard
            int result = JOptionPane.showConfirmDialog(this, inputPanel,
                    "Add New Student", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

            // 4. Process the submission
            if (result == JOptionPane.OK_OPTION) {
                String name = nameField.getText().trim();
                String email = emailField.getText().trim();
                String phone = phoneField.getText().trim();

                // Validation check
                if (name.isEmpty() || email.isEmpty() || phone.isEmpty()) {
                    JOptionPane.showMessageDialog(this, "All fields are required.", "Input Error", JOptionPane.WARNING_MESSAGE);
                    return;
                }

                // Send to database
                AdminDAO dao = new AdminDAO();
                if (dao.insertStudent(name, email, phone)) {
                    JOptionPane.showMessageDialog(this, "Student added successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);

                    // Refresh the table by quickly reloading the Admin dashboard
                    this.dispose();
                    new AdminFrame().setVisible(true);
                } else {
                    JOptionPane.showMessageDialog(this, "Database error. Could not add student (Email might already exist).", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        editButton.addActionListener(e -> {
            int selectedRow = studentTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select a student to edit.", "Selection Required", JOptionPane.WARNING_MESSAGE);
                return;
            }

            // 1. Safely extract the current data from the selected row
            int studentId = Integer.parseInt(tableModel.getValueAt(selectedRow, 0).toString());
            String currentName = tableModel.getValueAt(selectedRow, 1).toString();
            String currentEmail = tableModel.getValueAt(selectedRow, 2).toString();
            String currentPhone = tableModel.getValueAt(selectedRow, 3).toString();

            // 2. Create the input fields and pre-fill them with the current data
            JTextField nameField = new JTextField(currentName, 15);
            JTextField emailField = new JTextField(currentEmail, 15);
            JTextField phoneField = new JTextField(currentPhone, 15);

            // 3. Build the wizard panel
            JPanel inputPanel = new JPanel(new GridLayout(3, 2, 5, 10));
            inputPanel.add(new JLabel("Full Name:"));
            inputPanel.add(nameField);
            inputPanel.add(new JLabel("Email Address:"));
            inputPanel.add(emailField);
            inputPanel.add(new JLabel("Phone Number:"));
            inputPanel.add(phoneField);

            // 4. Show the pop-up wizard
            int result = JOptionPane.showConfirmDialog(this, inputPanel,
                    "Edit Student (ID: " + studentId + ")", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

            // 5. Process the update if they click OK
            if (result == JOptionPane.OK_OPTION) {
                String newName = nameField.getText().trim();
                String newEmail = emailField.getText().trim();
                String newPhone = phoneField.getText().trim();

                // Validation check
                if (newName.isEmpty() || newEmail.isEmpty() || newPhone.isEmpty()) {
                    JOptionPane.showMessageDialog(this, "All fields are required.", "Input Error", JOptionPane.WARNING_MESSAGE);
                    return;
                }

                // Send the update to the database
                AdminDAO dao = new AdminDAO();
                if (dao.updateStudent(studentId, newName, newEmail, newPhone)) {
                    JOptionPane.showMessageDialog(this, "Student updated successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);

                    // Refresh the table by quickly reloading the Admin dashboard
                    this.dispose();
                    new AdminFrame().setVisible(true);
                } else {
                    JOptionPane.showMessageDialog(this, "Database error. Could not update student.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        deleteButton.addActionListener(e -> {
            int selectedRow = studentTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select a student to delete.", "Selection Required", JOptionPane.WARNING_MESSAGE);
                return;
            }

            // Extract ID and Name from the selected table row
            int studentId = (int) tableModel.getValueAt(selectedRow, 0);
            String studentName = (String) tableModel.getValueAt(selectedRow, 1);

            int confirm = JOptionPane.showConfirmDialog(this,
                    "Are you sure you want to permanently delete " + studentName + "?\nThis will also delete all their exam records.",
                    "Confirm Delete", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);

            if (confirm == JOptionPane.YES_OPTION) {
                AdminDAO dao = new AdminDAO();
                if (dao.deleteStudent(studentId)) {
                    // Success! Remove the row directly from the visual table so we don't have to reload everything
                    tableModel.removeRow(selectedRow);
                    JOptionPane.showMessageDialog(this, studentName + " has been successfully removed from the system.", "Success", JOptionPane.INFORMATION_MESSAGE);
                } else {
                    JOptionPane.showMessageDialog(this, "Database error. Could not delete student.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });
        actionPanel.add(addButton);
        actionPanel.add(editButton);
        actionPanel.add(deleteButton);
        panel.add(actionPanel, BorderLayout.SOUTH);

        return panel;
    }
    private JPanel createInstructorsPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JLabel titleLabel = new JLabel("Instructor Directory");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 18));
        panel.add(titleLabel, BorderLayout.NORTH);

        String[] columnNames = {"ID", "Name", "Email", "Department No"};
        DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0) {
            @Override
            public boolean isCellEditable(int row, int column) { return false; }
        };

        AdminDAO adminDAO = new AdminDAO();
        List<Object[]> instructors = adminDAO.getAllInstructors();
        for (Object[] row : instructors) {
            tableModel.addRow(row);
        }

        JTable instructorTable = new JTable(tableModel);
        instructorTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        panel.add(new JScrollPane(instructorTable), BorderLayout.CENTER);

        // Action Buttons
        JPanel actionPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JButton addButton = new JButton("Add New Instructor");
        JButton editButton = new JButton("Edit Selected");
        JButton deleteButton = new JButton("Delete Selected");
        deleteButton.setForeground(Color.RED);

        // --- ADD LOGIC ---
        addButton.addActionListener(e -> {
            JTextField nameField = new JTextField(15);
            JTextField emailField = new JTextField(15);
            JTextField deptField = new JTextField(15);

            JPanel inputPanel = new JPanel(new GridLayout(3, 2, 5, 10));
            inputPanel.add(new JLabel("Full Name:"));
            inputPanel.add(nameField);
            inputPanel.add(new JLabel("Email Address:"));
            inputPanel.add(emailField);
            inputPanel.add(new JLabel("Department No:"));
            inputPanel.add(deptField);

            int result = JOptionPane.showConfirmDialog(this, inputPanel, "Add New Instructor", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

            if (result == JOptionPane.OK_OPTION) {
                try {
                    String name = nameField.getText().trim();
                    String email = emailField.getText().trim();
                    int deptNo = Integer.parseInt(deptField.getText().trim());

                    if (adminDAO.insertInstructor(name, email, deptNo)) {
                        JOptionPane.showMessageDialog(this, "Instructor added successfully!");
                        this.dispose();
                        new AdminFrame().setVisible(true);
                    } else {
                        JOptionPane.showMessageDialog(this, "Database error adding instructor.", "Error", JOptionPane.ERROR_MESSAGE);
                    }
                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(this, "Department No must be a valid number.", "Input Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        // --- EDIT LOGIC ---
        editButton.addActionListener(e -> {
            int selectedRow = instructorTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select an instructor to edit.", "Selection Required", JOptionPane.WARNING_MESSAGE);
                return;
            }

            int id = Integer.parseInt(tableModel.getValueAt(selectedRow, 0).toString());
            JTextField nameField = new JTextField(tableModel.getValueAt(selectedRow, 1).toString(), 15);
            JTextField emailField = new JTextField(tableModel.getValueAt(selectedRow, 2).toString(), 15);
            JTextField deptField = new JTextField(tableModel.getValueAt(selectedRow, 3).toString(), 15);

            JPanel inputPanel = new JPanel(new GridLayout(3, 2, 5, 10));
            inputPanel.add(new JLabel("Full Name:"));
            inputPanel.add(nameField);
            inputPanel.add(new JLabel("Email Address:"));
            inputPanel.add(emailField);
            inputPanel.add(new JLabel("Department No:"));
            inputPanel.add(deptField);

            int result = JOptionPane.showConfirmDialog(this, inputPanel, "Edit Instructor (ID: " + id + ")", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

            if (result == JOptionPane.OK_OPTION) {
                try {
                    String name = nameField.getText().trim();
                    String email = emailField.getText().trim();
                    int deptNo = Integer.parseInt(deptField.getText().trim());

                    if (adminDAO.updateInstructor(id, name, email, deptNo)) {
                        JOptionPane.showMessageDialog(this, "Instructor updated successfully!");
                        this.dispose();
                        new AdminFrame().setVisible(true);
                    } else {
                        JOptionPane.showMessageDialog(this, "Database error updating instructor.", "Error", JOptionPane.ERROR_MESSAGE);
                    }
                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(this, "Department No must be a valid number.", "Input Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        // --- DELETE LOGIC ---
        deleteButton.addActionListener(e -> {
            int selectedRow = instructorTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select an instructor to delete.", "Selection Required", JOptionPane.WARNING_MESSAGE);
                return;
            }

            int id = Integer.parseInt(tableModel.getValueAt(selectedRow, 0).toString());
            String name = tableModel.getValueAt(selectedRow, 1).toString();

            int confirm = JOptionPane.showConfirmDialog(this, "Permanently delete instructor " + name + "?", "Confirm Delete", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);

            if (confirm == JOptionPane.YES_OPTION) {
                if (adminDAO.deleteInstructor(id)) {
                    tableModel.removeRow(selectedRow);
                    JOptionPane.showMessageDialog(this, "Instructor deleted successfully.");
                } else {
                    JOptionPane.showMessageDialog(this, "Database error. Could not delete instructor.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        actionPanel.add(addButton);
        actionPanel.add(editButton);
        actionPanel.add(deleteButton);
        panel.add(actionPanel, BorderLayout.SOUTH);

        return panel;
    }
    private JPanel createCoursesPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JLabel titleLabel = new JLabel("Course Directory");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 18));
        panel.add(titleLabel, BorderLayout.NORTH);

        String[] columnNames = {"Course ID", "Course Name", "Min Degree", "Max Degree"};
        DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0) {
            @Override
            public boolean isCellEditable(int row, int column) { return false; }
        };

        AdminDAO adminDAO = new AdminDAO();
        List<Object[]> courses = adminDAO.getAllCourses();
        for (Object[] row : courses) {
            tableModel.addRow(row);
        }

        JTable courseTable = new JTable(tableModel);
        courseTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        panel.add(new JScrollPane(courseTable), BorderLayout.CENTER);

        // Action Buttons
        JPanel actionPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        JButton addButton = new JButton("Add New Course");
        JButton editButton = new JButton("Edit Selected");
        JButton deleteButton = new JButton("Delete Selected");
        deleteButton.setForeground(Color.RED);

        // --- ADD LOGIC ---
        addButton.addActionListener(e -> {
            JTextField nameField = new JTextField(15);
            JTextField minField = new JTextField("60", 15); // Default passing grade
            JTextField maxField = new JTextField("100", 15); // Default max grade

            JPanel inputPanel = new JPanel(new GridLayout(3, 2, 5, 10));
            inputPanel.add(new JLabel("Course Name:"));
            inputPanel.add(nameField);
            inputPanel.add(new JLabel("Minimum Degree:"));
            inputPanel.add(minField);
            inputPanel.add(new JLabel("Maximum Degree:"));
            inputPanel.add(maxField);

            int result = JOptionPane.showConfirmDialog(this, inputPanel, "Add New Course", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

            if (result == JOptionPane.OK_OPTION) {
                try {
                    String name = nameField.getText().trim();
                    int minDegree = Integer.parseInt(minField.getText().trim());
                    int maxDegree = Integer.parseInt(maxField.getText().trim());

                    if (name.isEmpty()) {
                        JOptionPane.showMessageDialog(this, "Course name is required.", "Input Error", JOptionPane.WARNING_MESSAGE);
                        return;
                    }

                    if (adminDAO.insertCourse(name, minDegree, maxDegree)) {
                        JOptionPane.showMessageDialog(this, "Course added successfully!");
                        this.dispose();
                        new AdminFrame().setVisible(true);
                    } else {
                        JOptionPane.showMessageDialog(this, "Database error adding course.", "Error", JOptionPane.ERROR_MESSAGE);
                    }
                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(this, "Degrees must be valid numbers.", "Input Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        // --- EDIT LOGIC ---
        editButton.addActionListener(e -> {
            int selectedRow = courseTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select a course to edit.", "Selection Required", JOptionPane.WARNING_MESSAGE);
                return;
            }

            int id = Integer.parseInt(tableModel.getValueAt(selectedRow, 0).toString());
            JTextField nameField = new JTextField(tableModel.getValueAt(selectedRow, 1).toString(), 15);
            JTextField minField = new JTextField(tableModel.getValueAt(selectedRow, 2).toString(), 15);
            JTextField maxField = new JTextField(tableModel.getValueAt(selectedRow, 3).toString(), 15);

            JPanel inputPanel = new JPanel(new GridLayout(3, 2, 5, 10));
            inputPanel.add(new JLabel("Course Name:"));
            inputPanel.add(nameField);
            inputPanel.add(new JLabel("Minimum Degree:"));
            inputPanel.add(minField);
            inputPanel.add(new JLabel("Maximum Degree:"));
            inputPanel.add(maxField);

            int result = JOptionPane.showConfirmDialog(this, inputPanel, "Edit Course (ID: " + id + ")", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

            if (result == JOptionPane.OK_OPTION) {
                try {
                    String name = nameField.getText().trim();
                    int minDegree = Integer.parseInt(minField.getText().trim());
                    int maxDegree = Integer.parseInt(maxField.getText().trim());

                    if (adminDAO.updateCourse(id, name, minDegree, maxDegree)) {
                        JOptionPane.showMessageDialog(this, "Course updated successfully!");
                        this.dispose();
                        new AdminFrame().setVisible(true);
                    } else {
                        JOptionPane.showMessageDialog(this, "Database error updating course.", "Error", JOptionPane.ERROR_MESSAGE);
                    }
                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(this, "Degrees must be valid numbers.", "Input Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        // --- DELETE LOGIC ---
        deleteButton.addActionListener(e -> {
            int selectedRow = courseTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select a course to delete.", "Selection Required", JOptionPane.WARNING_MESSAGE);
                return;
            }

            int id = Integer.parseInt(tableModel.getValueAt(selectedRow, 0).toString());
            String name = tableModel.getValueAt(selectedRow, 1).toString();

            int confirm = JOptionPane.showConfirmDialog(this,
                    "Permanently delete the course '" + name + "'?\nWARNING: This cascades and deletes ALL related questions and exams!",
                    "Critical Deletion", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);

            if (confirm == JOptionPane.YES_OPTION) {
                if (adminDAO.deleteCourse(id)) {
                    tableModel.removeRow(selectedRow);
                    JOptionPane.showMessageDialog(this, "Course deleted successfully.");
                } else {
                    JOptionPane.showMessageDialog(this, "Database error. Could not delete course.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });

        actionPanel.add(addButton);
        actionPanel.add(editButton);
        actionPanel.add(deleteButton);
        panel.add(actionPanel, BorderLayout.SOUTH);

        return panel;
    }
}