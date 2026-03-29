<div align="center">
  <h1>🎓 Student Examination Management System</h1>
  <p>A robust, database-centric desktop application designed to streamline the examination process across iti educational branches.</p>
</div>

<br />

## 📖 Overview

The **ITI Student Examination Management System** is a comprehensive, database-driven solution engineered to manage academic assessments efficiently. Designed with a strong emphasis on backend processing, the core logic of the application resides entirely within Microsoft SQL Server stored procedures, ensuring high performance, data integrity, and security. 

The frontend is built using Java Swing with FlatLaf themes, providing a responsive desktop interface that connects to the database via JDBC. By digitizing the examination workflow, this system reduces administrative overhead, enforces strict testing environments, and delivers immediate, automated grading feedback to students.

## ✨ Core Functionalities

The system is built around several critical functional modules that handle the entire lifecycle of an academic examination.

### Examination Engine
The core of the system is its automated examination engine. Exams are generated dynamically using a randomized selection process that pulls from a pre-loaded question bank of Multiple Choice (MCQ) and True/False questions. The generation process guarantees no duplicate questions and assigns specific ordering for each student. When students submit their exams, their answers are packaged in XML format and processed by the database, which automatically calculates the total grade based on predefined model answers.

### Comprehensive Reporting
The application includes a robust reporting module that provides valuable insights to both instructors and administrators. The system generates detailed reports on student enrollment by department, comprehensive grade transcripts for individual students (including percentages), and course overview reports for instructors detailing student counts across different tracks.

### Entity Management
A complete suite of CRUD (Create, Read, Update, Delete) operations manages the educational hierarchy. The system maintains complex relationships between physical branches, academic tracks, specific courses, assigned instructors, and enrolled students. 

## 👥 User Roles & Access Control

Security and data isolation are enforced directly at the database level using SQL Server roles, ensuring that users can only access information relevant to their permissions.

| Role | System Responsibilities | Database Access Level |
| :--- | :--- | :--- |
| **Administrator** | Full system management, user administration, and database backups. | `db_owner` |
| **Instructor** | Generate exams, manage the question bank, and view academic reports. | Read/Write access on exam and question tables |
| **Student** | Take active exams and view personal academic grades only. | `db_datareader` (Read-only access) |

## 🗄️ Database Architecture

The project features a highly normalized, 12-table relational schema designed with strict data integrity rules. 

### Schema Entities
The database architecture models the complex educational environment through interconnected entities. The structural foundation includes the `Branch`, `Track`, and `Course` tables, linked via junction tables to support many-to-many relationships. User profiles are maintained in the `Instructor` and `Student` tables. The assessment framework is built upon the `Question`, `Option`, and `ModelAnswer` tables, while the actual examination execution is recorded in the `Exam`, `StudentExam`, and `StudentAnswer` tables.

> **Note:** An Entity-Relationship Diagram (`ERD.png`) is included in the project repository to provide a detailed visual representation of these relationships.

### Stored Procedures
To guarantee optimal performance, all business logic is encapsulated within SQL Server Stored Procedures. Critical procedures include `GenerateExam` for random question selection, `SubmitExamAnswers` which utilizes XML parsing for bulk answer insertion, and `CorrectExam` for automated grading. All procedures utilize explicit transaction blocks to prevent partial writes and maintain database consistency.

## ⚙️ Non-Functional Requirements

The system was engineered to meet strict performance and reliability standards:

| Category | Requirement Specification |
| :--- | :--- |
| **Performance** | Exam generation for 50 questions executes in under 2 seconds. Automated exam correction per student completes in under 1 second. |
| **Security** | Students are strictly prohibited from accessing other students' data or the `ModelAnswer` table, enforced via database roles. |
| **Data Integrity** | All stored procedures implement transaction blocks. Foreign Key constraints explicitly define `ON DELETE` rules to prevent orphan records. |
| **Localization** | All text columns utilize `NVARCHAR` data types to ensure full support for both Arabic and English characters. |

## 🚀 Getting Started

Follow these instructions to set up and run the project on your local machine.

### Prerequisites

* Java Development Kit (JDK) 8 or higher
* Microsoft SQL Server (2019 or newer recommended) via SSMS
* SQL Server JDBC Driver (`mssql-jdbc`)

### Installation & Setup

1. **Clone the Repository**
   Download the project source code to your local machine.

2. **Database Configuration**
   * Open SQL Server Management Studio (SSMS).
   * Execute the `create-database.sql` script located in the `database` folder.
   * Run the `create-tables.sql` script to establish the schema.
   * Execute the remaining SQL scripts (`crud-stored-procedures.sql`, `sample-data.sql`, etc.) to populate sample data and essential stored procedures.

3. **Application Configuration**
   * Navigate to the `ITI_ExamSystem_Java/src` directory.
   * Locate the `database.properties` file.
   * Update the database connection credentials to match your local SQL Server instance:
     ```properties
     db.url=jdbc:sqlserver://localhost:1433;databaseName=ITI_ExamSystem;encrypt=true;trustServerCertificate=true
     db.user=your_username
     db.password=your_password
     ```

4. **Run the Application**
   Compile and execute the `gui.LoginFrame` class to launch the system.

## 🎥 Demo & Portfolio

A demonstration video showcasing the system's capabilities, including the login interface and role-specific modules, is available in the provided demo link: https://limewire.com/d/frT1b#L2UhXI7itZ. 

This project is maintained on GitHub for version control and team collaboration.

## 📄 License

This project is open-source and available under standard open-source licenses. Please refer to the repository for specific licensing details.
