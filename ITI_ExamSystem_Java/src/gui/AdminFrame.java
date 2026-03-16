package gui;

import javax.swing.*;

/**
 * AdminFrame Class
 * Purpose: Admin panel for managing all system entities
 * Features: Manage Students, Courses, Questions, Instructors, etc.
 */
public class AdminFrame extends JFrame {

    public AdminFrame() {

        setTitle("ITI Exam System - Admin Panel");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(400, 300);
        setLocationRelativeTo(null);

    }
}
