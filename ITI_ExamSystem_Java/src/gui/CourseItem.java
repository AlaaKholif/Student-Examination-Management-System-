package gui;

/**
 * A helper class for JComboBox to display the Course Name but store the Course ID.
 */
public class CourseItem {
    private int id;
    private String name;

    public CourseItem(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    // The JComboBox uses this method to display the text!
    @Override
    public String toString() {
        return name;
    }
}