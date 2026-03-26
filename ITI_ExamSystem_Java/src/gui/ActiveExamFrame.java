package gui;

import dao.StudentDAO;
import dao.StudentDAO.ExamQuestionDTO;

import javax.swing.*;
import java.awt.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActiveExamFrame extends JFrame {

    private int studentId;
    private int examId;
    private int timeLeftSeconds;
    private Timer timer;

    private Map<Integer, Integer> studentAnswers = new HashMap<>();

    private CardLayout cardLayout;
    private JPanel cardsPanel;
    private JLabel timerLabel;

    // New variables to track state for our buttons
    private int currentQuestionIndex = 0;
    private int totalQuestions;
    private JButton prevButton;
    private JButton nextButton;
    private JButton submitButton;

    public ActiveExamFrame(int studentId, int examId, String examName, int durationMinutes) {
        this.studentId = studentId;
        this.examId = examId;
        this.timeLeftSeconds = durationMinutes * 60;

        setTitle("Active Exam - " + examName);
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        setSize(800, 600);
        setLocationRelativeTo(null);
        setLayout(new BorderLayout(10, 10));

        StudentDAO dao = new StudentDAO();
        List<ExamQuestionDTO> questions = dao.getExamQuestions(examId);

        if (questions.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Error: No questions found for this exam.", "Exam Error", JOptionPane.ERROR_MESSAGE);
            this.dispose();
            return;
        }

        this.totalQuestions = questions.size();

        // Build the Top Panel (Timer)
        JPanel topPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        timerLabel = new JLabel("Time Remaining: " + formatTime(timeLeftSeconds));
        timerLabel.setFont(new Font("Arial", Font.BOLD, 18));
        timerLabel.setForeground(Color.RED);
        topPanel.add(timerLabel);
        add(topPanel, BorderLayout.NORTH);

        // Build the Center Panel (The Question Cards)
        cardLayout = new CardLayout();
        cardsPanel = new JPanel(cardLayout);
        cardsPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        for (int i = 0; i < questions.size(); i++) {
            cardsPanel.add(createQuestionPanel(questions.get(i), i + 1, questions.size()), "Question_" + i);
        }
        add(cardsPanel, BorderLayout.CENTER);

        // Build the Bottom Panel (Navigation)
        JPanel bottomPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 10));
        prevButton = new JButton("<< Previous");
        nextButton = new JButton("Next >>");
        submitButton = new JButton("Submit Exam");
        submitButton.setBackground(new Color(34, 139, 34));
        submitButton.setForeground(Color.WHITE);

        // Set initial button states (Hide Previous on Q1, Hide Submit until the last question)
        prevButton.setVisible(false);
        submitButton.setVisible(totalQuestions == 1); // Edge case: if exam only has 1 question
        nextButton.setVisible(totalQuestions > 1);

        prevButton.addActionListener(e -> {
            cardLayout.previous(cardsPanel);
            currentQuestionIndex--;
            updateButtonVisibility();
        });

        nextButton.addActionListener(e -> {
            cardLayout.next(cardsPanel);
            currentQuestionIndex++;
            updateButtonVisibility();
        });

        submitButton.addActionListener(e -> {
            int confirm = JOptionPane.showConfirmDialog(this,
                    "Are you sure you want to submit? You have answered " + studentAnswers.size() + " out of " + questions.size() + " questions.",
                    "Confirm Submission", JOptionPane.YES_NO_OPTION);
            if (confirm == JOptionPane.YES_OPTION) {
                processSubmission();
            }
        });

        bottomPanel.add(prevButton);
        bottomPanel.add(nextButton);
        bottomPanel.add(submitButton);
        add(bottomPanel, BorderLayout.SOUTH);

        startTimer();
    }

    // --- NEW METHOD: Handles showing/hiding the right buttons ---
    private void updateButtonVisibility() {
        prevButton.setVisible(currentQuestionIndex > 0);

        if (currentQuestionIndex == totalQuestions - 1) {
            nextButton.setVisible(false);
            submitButton.setVisible(true);
        } else {
            nextButton.setVisible(true);
            submitButton.setVisible(false);
        }
    }

    private JPanel createQuestionPanel(ExamQuestionDTO q, int currentNumber, int totalQuestions) {
        JPanel panel = new JPanel(new BorderLayout(10, 20));

        JLabel headerLabel = new JLabel("Question " + currentNumber + " of " + totalQuestions + " (" + q.questionType + ")");
        headerLabel.setFont(new Font("Arial", Font.BOLD, 14));
        panel.add(headerLabel, BorderLayout.NORTH);

        JTextArea questionText = new JTextArea(q.questionText);
        questionText.setFont(new Font("Arial", Font.PLAIN, 16));
        questionText.setWrapStyleWord(true);
        questionText.setLineWrap(true);
        questionText.setEditable(false);
        questionText.setOpaque(false);
        panel.add(questionText, BorderLayout.CENTER);

        JPanel optionsPanel = new JPanel(new GridLayout(q.options.size(), 1, 5, 10));
        ButtonGroup bg = new ButtonGroup();

        for (Map.Entry<Integer, String> entry : q.options.entrySet()) {
            int optionId = entry.getKey();
            String optionText = entry.getValue();

            JRadioButton radioBtn = new JRadioButton(optionText);
            radioBtn.setFont(new Font("Arial", Font.PLAIN, 14));
            bg.add(radioBtn);
            optionsPanel.add(radioBtn);

            radioBtn.addActionListener(e -> studentAnswers.put(q.questionId, optionId));
        }

        panel.add(optionsPanel, BorderLayout.SOUTH);
        return panel;
    }

    private void startTimer() {
        timer = new Timer(1000, e -> {
            timeLeftSeconds--;
            timerLabel.setText("Time Remaining: " + formatTime(timeLeftSeconds));

            if (timeLeftSeconds <= 0) {
                timer.stop();
                JOptionPane.showMessageDialog(this, "Time is up! Your exam will now be submitted automatically.", "Time Expired", JOptionPane.WARNING_MESSAGE);
                processSubmission();
            }
        });
        timer.start();
    }

    private String formatTime(int totalSeconds) {
        int hours = totalSeconds / 3600;
        int minutes = (totalSeconds % 3600) / 60;
        int seconds = totalSeconds % 60;
        return String.format("%02d:%02d:%02d", hours, minutes, seconds);
    }

    private void processSubmission() {
        if (timer != null) timer.stop();

        // 1. Call the DAO to submit the XML
        StudentDAO dao = new StudentDAO();
        boolean success = dao.submitExam(studentId, examId, studentAnswers);

        // 2. Handle the result
        if (success) {
            JOptionPane.showMessageDialog(this, "Exam submitted successfully! Your grade has been calculated.", "Success", JOptionPane.INFORMATION_MESSAGE);
        } else {
            JOptionPane.showMessageDialog(this, "There was an error saving your exam. Please contact an administrator.", "Submission Error", JOptionPane.ERROR_MESSAGE);
        }

        // 3. Close the active exam window
        this.dispose();

        // 4. Re-open the Student Dashboard (this refreshes the tables to show the new grade!)
        new StudentFrame(studentId).setVisible(true);
    }
}