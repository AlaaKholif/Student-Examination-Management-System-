-- 1. Create the Admin table if it doesn't exist yet
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Admin')
BEGIN
    CREATE TABLE Admin (
        AdminID INT IDENTITY(1,1) PRIMARY KEY,
        AdminName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        Password NVARCHAR(100) NOT NULL DEFAULT '123456'
    );
    PRINT 'Admin table created.';
END
GO

-- 2. Insert your default Master Admin account
-- I am using the standard ITI email format and our default 123456 password
IF NOT EXISTS (SELECT 1 FROM Admin WHERE Email = 'admin@iti.edu.eg')
BEGIN
    INSERT INTO Admin (AdminName, Email, Password)
    VALUES ('System Administrator', 'admin@iti.edu.eg', '123456');
    PRINT 'Admin credentials created: admin@iti.edu.eg / 123456';
END
ELSE
BEGIN
    PRINT 'Admin account already exists!';
END
GO
