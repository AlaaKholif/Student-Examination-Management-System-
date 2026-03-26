package gui;

import dao.ReportDAO;
import dao.StudentDAO;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.util.List;

public class StudentFrame extends JFrame {

    private int loggedInStudentId;

    public StudentFrame(int studentId) {
        this.loggedInStudentId = studentId;

        setTitle("ITI Exam System - Student Dashboard (ID: " + loggedInStudentId + ")");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(600, 450);
        setLocationRelativeTo(null);

        JTabbedPane tabbedPane = new JTabbedPane();

        // Add the tabs
        tabbedPane.addTab("Available Exams", createAvailableExamsPanel());
        tabbedPane.addTab("My Grades", createGradesPanel());

        add(tabbedPane, BorderLayout.CENTER);

        // Bottom Logout Button
        JPanel bottomPanel = new JPanel();
        JButton logoutButton = new JButton("Logout");
        logoutButton.addActionListener(e -> {
            this.dispose();
            new LoginFrame().setVisible(true);
        });
        bottomPanel.add(logoutButton);
        add(bottomPanel, BorderLayout.SOUTH);
    }

    private JPanel createAvailableExamsPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JLabel titleLabel = new JLabel("Exams Ready to Take");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 16));
        panel.add(titleLabel, BorderLayout.NORTH);

        // Set up the table
        String[] columnNames = {"Exam ID", "Exam Name", "Course", "Duration (Mins)", "Questions"};
        DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0);

        // Fetch data from DAO
        StudentDAO studentDAO = new StudentDAO();
        List<Object[]> exams = studentDAO.getAvailableExams(loggedInStudentId);

        for (Object[] row : exams) {
            tableModel.addRow(row);
        }

        JTable examTable = new JTable(tableModel);
        examTable.setEnabled(true); // Enabled so they can click a row
        examTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        panel.add(new JScrollPane(examTable), BorderLayout.CENTER);

        // Action Panel
        JPanel actionPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        JButton startExamButton = new JButton("Start Selected Exam");

        startExamButton.addActionListener(e -> {
            int selectedRow = examTable.getSelectedRow();
            if (selectedRow == -1) {
                JOptionPane.showMessageDialog(this, "Please select an exam from the list first.", "No Selection", JOptionPane.WARNING_MESSAGE);
                return;
            }

            // Safely parse the values from the table model
            int examId = Integer.parseInt(tableModel.getValueAt(selectedRow, 0).toString());
            String examName = tableModel.getValueAt(selectedRow, 1).toString();
            int duration = Integer.parseInt(tableModel.getValueAt(selectedRow, 3).toString());

            int confirm = JOptionPane.showConfirmDialog(this,
                    "Are you sure you want to start '" + examName + "'?\nThe timer (" + duration + " mins) will begin immediately.",
                    "Start Exam", JOptionPane.YES_NO_OPTION);

            if (confirm == JOptionPane.YES_OPTION) {
                // UPDATE THIS BLOCK: Open the active exam frame and hide the dashboard
                this.setVisible(false);
                new gui.ActiveExamFrame(loggedInStudentId, examId, examName, duration).setVisible(true);
            }
        });

        actionPanel.add(startExamButton);
        panel.add(actionPanel, BorderLayout.SOUTH);

        return panel;
    }

    private JPanel createGradesPanel() {
        JPanel panel = new JPanel(new BorderLayout(10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        String[] columnNames = {"Course Name", "Exam Name", "Your Grade", "Max Grade", "Percentage"};
        DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0);

        ReportDAO reportDAO = new ReportDAO();
        List<Object[]> grades = reportDAO.getStudentGrades(loggedInStudentId);

        for (Object[] row : grades) {
            tableModel.addRow(row);
        }

        JTable gradesTable = new JTable(tableModel);
        gradesTable.setEnabled(false);
        panel.add(new JScrollPane(gradesTable), BorderLayout.CENTER);

        return panel;
    }
}