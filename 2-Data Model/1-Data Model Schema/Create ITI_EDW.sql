CREATE DATABASE ITI_EDW;
GO

USE ITI_EDW;
GO

CREATE SCHEMA dim;
GO

CREATE SCHEMA fact;
GO

-----------------------------------------------------------( Dim_Student )----------------------------------------------------
CREATE TABLE dim.Dim_Student 
(
    StudentKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    StudentID INT UNIQUE,  -- Natural Key (from source)
    SSN BIGINT,
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    Email NVARCHAR(255),
    MaritalStatus NVARCHAR(255),
    City NVARCHAR(255),
    Street NVARCHAR(255),
    Gender NVARCHAR(255),
    BirthDate DATE,
    Degree NVARCHAR(255),
    Graduated BIT,
    TrackID INT,   
    BranchID INT,  
    IntakeID INT,
    PhoneNumbers NVARCHAR(MAX)
);

GO
-----------------------------------------------------------( Dim_Instructor )----------------------------------------------------
CREATE TABLE dim.Dim_Instructor 
(
    InstructorKey INT IDENTITY(1,1) PRIMARY KEY, -- Surrogate Key
    InstructorID INT UNIQUE,  -- Natural Key from Instructor table
    SSN BIGINT,
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    Email NVARCHAR(255),
    MaritalStatus NVARCHAR(255),
    City NVARCHAR(255),
    Street NVARCHAR(255),
    Gender NVARCHAR(255),
    BirthDate DATE,
    Degree NVARCHAR(255),
    Salary INT,
    HiringDate DATE,
    DepartmentID INT, -- Store Department ID (as an attribute, not FK)
    PhoneNumbers NVARCHAR(MAX) -- Concatenated Phone Numbers
);

GO
-----------------------------------------------------------( Dim_Company )----------------------------------------------------
CREATE TABLE dim.Dim_Company (
    CompanyKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    CompanyID INT UNIQUE,                      -- Natural key from OLTP
    CompanyName NVARCHAR(255),
    CompanyType NVARCHAR(255)
);

GO
-----------------------------------------------------------( Dim_FreelancePlatform )----------------------------------------------------
CREATE TABLE dim.Dim_FreelancePlatform (
    PlatformKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    PlatformID INT UNIQUE,                       -- Natural key from OLTP
    PlatformName NVARCHAR(255)
);

GO
-----------------------------------------------------------( Dim_Certificate )----------------------------------------------------
CREATE TABLE dim.Dim_Certificate (
    CertificateKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    CertificateID INT UNIQUE,                      -- Natural key from OLTP
    CertificateName NVARCHAR(255),
    CertificateProvider NVARCHAR(255),
    CertificateField NVARCHAR(255)
);

GO
-----------------------------------------------------------( Dim_Department )----------------------------------------------------
CREATE TABLE dim.Dim_Department (
    DepartmentKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    DepartmentID INT UNIQUE,                 -- Natural key from OLTP
    DepartmentName NVARCHAR(255)
);

GO
-----------------------------------------------------------( Dim_Course )----------------------------------------------------
CREATE TABLE dim.Dim_Course (
    CourseKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    CourseID INT UNIQUE,                      -- Natural key from OLTP
    CourseName NVARCHAR(255),
    Hours INT
);

GO
-----------------------------------------------------------( Dim_Topic )----------------------------------------------------
CREATE TABLE dim.Dim_Topic (
    TopicKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    CourseKey INT,                           -- Foreign key referencing Dim_Course
    TopicName NVARCHAR(255),
    CONSTRAINT FK_Dim_Topic_Course FOREIGN KEY (CourseKey) REFERENCES dim.Dim_Course(CourseKey)
);

GO
-----------------------------------------------------------( Dim_Intake )----------------------------------------------------
CREATE TABLE dim.Dim_Intake (
    IntakeKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    IntakeID INT UNIQUE,                       -- Natural key from OLTP
    StartDate DATE,
    EndDate DATE,
    IntakeType NVARCHAR(10)
);

GO
-----------------------------------------------------------( Dim_Branch )----------------------------------------------------
CREATE TABLE dim.Dim_Branch (
    BranchKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    BranchID INT UNIQUE,                      -- Natural key from OLTP
    BranchLocation NVARCHAR(255),             -- Maps to Location
    BranchName NVARCHAR(255)                  -- Maps to Name
);

GO
-----------------------------------------------------------( Dim_Track )----------------------------------------------------
CREATE TABLE dim.Dim_Track (
    TrackKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    TrackID INT UNIQUE,                      -- Natural key from OLTP
    TrackName NVARCHAR(255),
    DepartmentID INT                         -- Natural key from OLTP (from Department table)
);

GO
-----------------------------------------------------------( Dim_Exam )----------------------------------------------------
CREATE TABLE dim.Dim_Exam (
    ExamKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    ExamID INT UNIQUE,                       -- Natural key from OLTP
    ExamDate DATE,
    NumberOfTF INT,
    NumberOfMCQ INT,
    CourseID INT,       -- Natural key from Course table
    InstructorID INT    -- Natural key from Instructor table
);

GO
-----------------------------------------------------------( Dim_Question )----------------------------------------------------
CREATE TABLE dim.Dim_Question (
    QuestionKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    QuestionID INT UNIQUE,                       -- Natural key from OLTP
    QuestionText NVARCHAR(255),
    QuestionAnswer NVARCHAR(255),
    QuestionType NVARCHAR(255),
    CourseID INT                                -- Natural key from Course table
);

GO
-----------------------------------------------------------( Dim_QuestionChoice )----------------------------------------------------
CREATE TABLE dim.Dim_QuestionChoice (
    ChoiceKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key for choices
    QuestionKey INT,                          -- Foreign key referencing Dim_Question
    ChoiceText NVARCHAR(255),                 -- The text of the choice
    CONSTRAINT FK_QuestionChoice_Question
       FOREIGN KEY (QuestionKey) REFERENCES dim.Dim_Question(QuestionKey)
);

GO
-----------------------------------------------------------( Dim_Date )----------------------------------------------------
CREATE TABLE dim.Dim_Date (
    DateKey INT PRIMARY KEY,         -- e.g., 20230101
    [Date] DATE,                     -- Actual date value
    Year INT,
    Quarter INT,
    Month INT,
    MonthName NVARCHAR(50),
    Day INT,
    DayOfWeek INT,                   -- Numeric day of week (e.g., 1=Sunday, 2=Monday, etc.)
    DayName NVARCHAR(50),
    IsWeekend BIT                   -- 1 if Saturday or Sunday, else 0
);

-----------------------------------------------------------( End_Dimensions )----------------------------------------------------

GO

-----------------------------------------------------------( Fact_ExamPerformance )----------------------------------------------------
CREATE TABLE fact.Fact_ExamPerformance (
    ExamPerformanceKey INT IDENTITY(1,1) PRIMARY KEY,   -- Surrogate Key
    
    -- Surrogate keys from dimensions:
    StudentKey INT,      -- References dim.Dim_Student(StudentKey)
    ExamKey INT,         -- References dim.Dim_Exam(ExamKey)
    QuestionKey INT,     -- References dim.Dim_Question(QuestionKey)
    CourseKey INT,       -- References dim.Dim_Course(CourseKey)
    TrackKey INT,        -- References dim.Dim_Track(TrackKey)
    BranchKey INT,       -- References dim.Dim_Branch(BranchKey)
    IntakeKey INT,       -- References dim.Dim_Intake(IntakeKey)
    InstructorKey INT,   -- References dim.Dim_Instructor(InstructorKey)
    DepartmentKey INT,   -- References dim.Dim_Department(DepartmentKey)

    
    -- Performance Attributes:
    StudentAnswer NVARCHAR(255),  -- Answer provided by the student
    IsCorrect BIT,                -- 1 if correct, 0 otherwise
    QuestionScore INT,            -- Score per question (e.g., 10 if correct, 0 if wrong)
    PassFail NVARCHAR(10),        -- 'Pass' if the student's aggregated score meets the threshold, otherwise 'Fail'
    ExamDateKey INT,              -- References dim.Dim_Date(DateKey)

    -- Foreign Key Constraints:
    FOREIGN KEY (StudentKey) REFERENCES dim.Dim_Student(StudentKey),
    FOREIGN KEY (ExamKey) REFERENCES dim.Dim_Exam(ExamKey),
    FOREIGN KEY (QuestionKey) REFERENCES dim.Dim_Question(QuestionKey),
    FOREIGN KEY (CourseKey) REFERENCES dim.Dim_Course(CourseKey),
    FOREIGN KEY (TrackKey) REFERENCES dim.Dim_Track(TrackKey),
    FOREIGN KEY (BranchKey) REFERENCES dim.Dim_Branch(BranchKey),
    FOREIGN KEY (IntakeKey) REFERENCES dim.Dim_Intake(IntakeKey),
    FOREIGN KEY (InstructorKey) REFERENCES dim.Dim_Instructor(InstructorKey),
    FOREIGN KEY (DepartmentKey) REFERENCES dim.Dim_Department(DepartmentKey),
    FOREIGN KEY (ExamDateKey) REFERENCES dim.Dim_Date(DateKey)
);

GO
-----------------------------------------------------------( Fact_StudentCertifications )----------------------------------------------------
CREATE TABLE fact.Fact_StudentCertifications 
(
    CertificationsFactID INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Primary Key

    -- Surrogate keys from dimensions:
    CertificateKey INT,      -- References dim.Dim_Certificate(CertificateKey)
    StudentKey INT,         -- References dim.Dim_Student(StudentKey)
    TrackKey INT,           -- References dim.Dim_Track(TrackKey)
    BranchKey INT,          -- References dim.Dim_Branch(BranchKey)
    IntakeKey INT,          -- References dim.Dim_Intake(IntakeKey)
    DepartmentKey INT,      -- References dim.Dim_Department(DepartmentKey)
    DateEarnedKey INT,      -- References dim.Dim_Date(DateKey) for Date Earned

    -- Foreign Key Constraints:
    CONSTRAINT FK_Fact_StudentCertifications_Student
        FOREIGN KEY (StudentKey) REFERENCES dim.Dim_Student(StudentKey),
    CONSTRAINT FK_Fact_StudentCertifications_Certificate
        FOREIGN KEY (CertificateKey) REFERENCES dim.Dim_Certificate(CertificateKey),
    CONSTRAINT FK_Fact_StudentCertifications_Track
        FOREIGN KEY (TrackKey) REFERENCES dim.Dim_Track(TrackKey),
    CONSTRAINT FK_Fact_StudentCertifications_Branch
        FOREIGN KEY (BranchKey) REFERENCES dim.Dim_Branch(BranchKey),
    CONSTRAINT FK_Fact_StudentCertifications_Intake
        FOREIGN KEY (IntakeKey) REFERENCES dim.Dim_Intake(IntakeKey),
    CONSTRAINT FK_Fact_StudentCertifications_Department
        FOREIGN KEY (DepartmentKey) REFERENCES dim.Dim_Department(DepartmentKey),
    CONSTRAINT FK_Fact_StudentCertifications_DateEarned
        FOREIGN KEY (DateEarnedKey) REFERENCES dim.Dim_Date(DateKey)
);

GO
-----------------------------------------------------------( Fact_StudentEmployment )----------------------------------------------------
CREATE TABLE fact.Fact_StudentEmployment (
    StudentEmploymentFactID INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Primary Key

    -- Surrogate keys from dimensions:
    StudentKey INT,      -- References dim.Dim_Student(StudentKey)
    CompanyKey INT,      -- References dim.Dim_Company(CompanyKey)
    TrackKey INT,        -- References dim.Dim_Track(TrackKey)
    BranchKey INT,       -- References dim.Dim_Branch(BranchKey)
    IntakeKey INT,       -- References dim.Dim_Intake(IntakeKey)
    DepartmentKey INT,   -- References dim.Dim_Department(DepartmentKey)
    HiringDateKey INT,   -- References dim.Dim_Date(DateKey)

    JobTitle NVARCHAR(255),  -- The job title of the student
    Salary INT,             -- Salary amount

    -- Foreign Key Constraints:
    CONSTRAINT FK_FactStudentEmployment_Student
        FOREIGN KEY (StudentKey) REFERENCES dim.Dim_Student(StudentKey),
    CONSTRAINT FK_FactStudentEmployment_Company
        FOREIGN KEY (CompanyKey) REFERENCES dim.Dim_Company(CompanyKey),
    CONSTRAINT FK_FactStudentEmployment_Track
        FOREIGN KEY (TrackKey) REFERENCES dim.Dim_Track(TrackKey),
    CONSTRAINT FK_FactStudentEmployment_Branch
        FOREIGN KEY (BranchKey) REFERENCES dim.Dim_Branch(BranchKey),
    CONSTRAINT FK_FactStudentEmployment_Intake
        FOREIGN KEY (IntakeKey) REFERENCES dim.Dim_Intake(IntakeKey),
    CONSTRAINT FK_FactStudentEmployment_Department
        FOREIGN KEY (DepartmentKey) REFERENCES dim.Dim_Department(DepartmentKey),
    CONSTRAINT FK_FactStudentEmployment_HiringDate
        FOREIGN KEY (HiringDateKey) REFERENCES dim.Dim_Date(DateKey)
);

GO
-----------------------------------------------------------( Fact_StudentFreelance )----------------------------------------------------
CREATE TABLE fact.Fact_StudentFreelance (
    StudentFreelanceFactID INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Primary Key

    -- Surrogate keys from dimensions:
    StudentKey INT,      -- References dim.Dim_Student(StudentKey)
    PlatformKey INT, -- References dim.Dim_FreelancePlatform(FreelancePlatformKey)
    TrackKey INT,        -- References dim.Dim_Track(TrackKey)
    BranchKey INT,       -- References dim.Dim_Branch(BranchKey)
    IntakeKey INT,       -- References dim.Dim_Intake(IntakeKey)
    DepartmentKey INT,   -- References dim.Dim_Department(DepartmentKey)
    DateKey INT,         -- References dim.Dim_Date(DateKey)

    ProjectDetails NVARCHAR(255),  -- Description of the freelance project
    Earnings INT,                  -- Earnings from the freelance project

    -- Foreign Key Constraints:
    CONSTRAINT FK_FactStudentFreelance_Student
        FOREIGN KEY (StudentKey) REFERENCES dim.Dim_Student(StudentKey),
    CONSTRAINT FK_FactStudentFreelance_FreelancePlatform
        FOREIGN KEY (PlatformKey) REFERENCES dim.Dim_FreelancePlatform(PlatformKey),
    CONSTRAINT FK_FactStudentFreelance_Track
        FOREIGN KEY (TrackKey) REFERENCES dim.Dim_Track(TrackKey),
    CONSTRAINT FK_FactStudentFreelance_Branch
        FOREIGN KEY (BranchKey) REFERENCES dim.Dim_Branch(BranchKey),
    CONSTRAINT FK_FactStudentFreelance_Intake
        FOREIGN KEY (IntakeKey) REFERENCES dim.Dim_Intake(IntakeKey),
    CONSTRAINT FK_FactStudentFreelance_Department
        FOREIGN KEY (DepartmentKey) REFERENCES dim.Dim_Department(DepartmentKey),
    CONSTRAINT FK_FactStudentFreelance_Date
        FOREIGN KEY (DateKey) REFERENCES dim.Dim_Date(DateKey)
);


-----------------------------------------------------------( End_Facts )----------------------------------------------------
