-- Create the database
CREATE DATABASE ITI_Examination_System_DB;
GO

-- Use the newly created database
USE ITI_Examination_System_DB;
GO

CREATE TABLE [dbo].[Person] (
    [P_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [SSN] BIGINT NOT NULL,
    [Fname] NVARCHAR(255) NOT NULL,
    [Lname] NVARCHAR(255) NOT NULL,
    [Email] NVARCHAR(255) NOT NULL,
    [Marital_Status] NVARCHAR(255) NOT NULL CHECK ([Marital_Status] IN ('Married', 'Single', 'Divorced')),
    [City] NVARCHAR(255) NOT NULL,
    [Street] NVARCHAR(255) NULL,
    [Gender] NVARCHAR(255) NOT NULL CHECK ([Gender] IN ('Male', 'Female')),
    [Bdate] DATE NOT NULL,
    [Degree] NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [dbo].[Person_Phone] (
    [P_ID] INT NOT NULL,
    [Phone_Num] BIGINT NOT NULL CHECK ([Phone_Num] > 0),
    PRIMARY KEY ([P_ID], [Phone_Num]),
    FOREIGN KEY ([P_ID]) REFERENCES [dbo].[Person]([P_ID])
);
GO

CREATE TABLE [dbo].[Department] (
    [D_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Dept_Name] NVARCHAR(255) NOT NULL UNIQUE
);
GO

CREATE TABLE [dbo].[Intake] (
    [In_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Start_Date] DATE NOT NULL,
    [End_Date] DATE NOT NULL,
    [Type] NVARCHAR(10) NOT NULL,
    CHECK ([End_Date] > [Start_Date])  -- Ensures logical date order
);
GO


CREATE TABLE [dbo].[Branch] (
    [B_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Location] NVARCHAR(255) NOT NULL, -- Increased for more flexibility
    [Name] NVARCHAR(255) NOT NULL UNIQUE, -- Allows longer names
);
GO

CREATE TABLE [dbo].[Track] (
    [T_ID] INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incremented ID
    [Name] NVARCHAR(255) NOT NULL UNIQUE,  -- Ensures unique track names
    [D_ID] INT NOT NULL,
    FOREIGN KEY ([D_ID]) REFERENCES [dbo].[Department]([D_ID])
);
GO

CREATE TABLE [dbo].[Student] (
    [S_ID] INT PRIMARY KEY,  -- S_ID is both PK and FK
    [Graduated] BIT NOT NULL,
    [T_ID] INT NOT NULL,
    [B_ID] INT NOT NULL,
    [In_ID] INT NOT NULL,
    FOREIGN KEY ([S_ID]) REFERENCES [dbo].[Person]([P_ID]) ,
    FOREIGN KEY ([T_ID]) REFERENCES [dbo].[Track]([T_ID]) ,
    FOREIGN KEY ([B_ID]) REFERENCES [dbo].[Branch]([B_ID]) ,
    FOREIGN KEY ([In_ID]) REFERENCES [dbo].[Intake]([In_ID])
);
GO


CREATE TABLE [dbo].[Instructor] (
    [Ins_ID] INT PRIMARY KEY,  -- Ins_ID is both PK and FK
    [Salary] INT NOT NULL CHECK ([Salary] > 0),
    [Hiring_Date] DATE NULL, 
    [D_ID] INT NOT NULL,
    FOREIGN KEY ([Ins_ID]) REFERENCES [dbo].[Person]([P_ID]),
    FOREIGN KEY ([D_ID]) REFERENCES [dbo].[Department]([D_ID])
);
GO

-- Company Table
CREATE TABLE [dbo].[Company] (
    [C_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(255) NOT NULL UNIQUE,  -- Ensures company names are unique
    [Scope] NVARCHAR(255) NULL CHECK ([Scope] IN ('Local', 'International'))  -- Restricts to predefined values
);
GO

-- Freelance Table
CREATE TABLE [dbo].[Freelance_Platform] (
    [F_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(255) NOT NULL UNIQUE  -- Ensures unique freelance platform names
);
GO


-- Certificate Table
CREATE TABLE [dbo].[Certificate] (
    [Cer_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(255) NOT NULL UNIQUE,  -- Ensures unique certificate names
    [Provider] NVARCHAR(255) NOT NULL,  -- Every certificate should have a provider
    [Field] NVARCHAR(255) NULL  -- Allows certificates without a specific field
);
GO

-- Course Table
CREATE TABLE [dbo].[Course] (
    [Crs_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(255) NOT NULL UNIQUE,  -- Ensures unique course names
    [Hours] INT NOT NULL CHECK ([Hours] > 0)  -- Ensures hours are greater than 0
);
GO

-- Topic Table
CREATE TABLE [dbo].[Topic] (
    [Crs_ID] INT NOT NULL,
    [Name] NVARCHAR(255) NOT NULL,  -- Name must be NOT NULL as it's part of PK
    PRIMARY KEY ([Crs_ID], [Name]),
    FOREIGN KEY ([Crs_ID]) REFERENCES [dbo].[Course]([Crs_ID])
);
GO


-- Exam Table
CREATE TABLE [dbo].[Exam] (
    [E_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Date] DATE NOT NULL,
    [Num_of_TF] INT NOT NULL CHECK ([Num_of_TF] >= 0), -- Prevents negative values
    [Num_of_MCQ] INT NOT NULL CHECK ([Num_of_MCQ] >= 0), -- Prevents negative values
    [Crs_id] INT NOT NULL,
    [Ins_ID] INT NOT NULL,
    CONSTRAINT Check_Questions_Sum CHECK ([Num_of_TF] + [Num_of_MCQ] = 10), -- Ensures total questions = 10
    FOREIGN KEY ([Crs_id]) REFERENCES [dbo].[Course]([Crs_ID]),
    FOREIGN KEY ([Ins_ID]) REFERENCES [dbo].[Instructor]([Ins_ID])
);
GO

-- Question Table
CREATE TABLE [dbo].[Question] (
    [Q_ID] INT IDENTITY(1,1) PRIMARY KEY,
    [Q_Text] NVARCHAR(255) NOT NULL, -- Renamed for clarity
    [Q_Answer] NVARCHAR(255) NOT NULL,
    [Type] NVARCHAR(255) NOT NULL CHECK ([Type] IN ('TRUE/FALSE', 'MCQ')), -- Restricts type to 'TF' or 'MCQ'
    [Crs_id] INT NOT NULL,
    FOREIGN KEY ([Crs_id]) REFERENCES [dbo].[Course]([Crs_ID])
);
GO

CREATE TABLE [dbo].[Question_Choices] (
    [Q_ID] INT NOT NULL,
    [Choice] NVARCHAR(255) NOT NULL, -- Fixed typo and ensured NOT NULL
    PRIMARY KEY ([Q_ID], [Choice]),
    FOREIGN KEY ([Q_ID]) REFERENCES [dbo].[Question]([Q_ID])
);
GO

CREATE TABLE [dbo].[Exam_Questions] (
    [EQ_ID] INT IDENTITY(1,1) PRIMARY KEY,
	[E_ID] INT NOT NULL,
    [Q_ID] INT NOT NULL,
    FOREIGN KEY ([Q_ID]) REFERENCES [dbo].[Question]([Q_ID]),
    FOREIGN KEY ([E_ID]) REFERENCES [dbo].[Exam]([E_ID]),
    CONSTRAINT UQ_Exam_Questions UNIQUE ([Q_ID], [E_ID]) -- Prevent duplicate Q_ID & E_ID pairs
);
GO

CREATE TABLE [Student_Exam_Questions] (
  [EQ_ID] INT,
  [S_ID] INT,
  [S_Answer] NVARCHAR(255),
  [Is_Correct_Answer] BIT,  -- Renamed from "Check" and changed type to BIT
  PRIMARY KEY ([EQ_ID], [S_ID]),
  FOREIGN KEY ([EQ_ID]) REFERENCES Exam_Questions([EQ_ID]),
  FOREIGN KEY ([S_ID]) REFERENCES Student(S_ID)
);
GO


CREATE TABLE [Track_Course] (
  [T_ID] INT,         -- Foreign Key referencing Track table
  [Crs_ID] INT,       -- Foreign Key referencing Course table
  PRIMARY KEY ([T_ID], [Crs_ID]), -- Composite Primary Key to prevent duplicates
  FOREIGN KEY ([T_ID]) REFERENCES [Track]([T_ID]),
  FOREIGN KEY ([Crs_ID]) REFERENCES [Course]([Crs_ID]) 
);
GO


CREATE TABLE [Track_Branch_Intake] (
  [T_ID] INT,   -- Foreign Key referencing Track table
  [B_ID] INT,   -- Foreign Key referencing Branch table
  [In_ID] INT,  -- Foreign Key referencing Intake table
  PRIMARY KEY ([T_ID], [B_ID], [In_ID]),
  FOREIGN KEY ([T_ID]) REFERENCES [Track]([T_ID]),
  FOREIGN KEY ([B_ID]) REFERENCES [Branch]([B_ID]),
  FOREIGN KEY ([In_ID]) REFERENCES [Intake]([In_ID])
);
GO


-- Table linking Students to Certificates
CREATE TABLE [Student_Certificate] (
  [Cer_ID] INT,  -- Foreign Key referencing Certificate
  [S_ID] INT,    -- Foreign Key referencing Student
  [Date] DATE NOT NULL,  -- The date when the certificate was obtained
  PRIMARY KEY ([Cer_ID], [S_ID]),
  FOREIGN KEY ([Cer_ID]) REFERENCES [Certificate]([Cer_ID]),
  FOREIGN KEY ([S_ID]) REFERENCES [Student]([S_ID])
);
GO

-- Table linking Students to Freelance Work
CREATE TABLE [Student_Freelance] (
  [F_ID] INT,    -- Foreign Key referencing Freelance
  [S_ID] INT,    -- Foreign Key referencing Student
  [Details] NVARCHAR(255) NOT NULL, -- Description of freelance work
  [Date] DATE NOT NULL,  -- Date of freelance work
  [Cost] INT NOT NULL CHECK([Cost] > 0), -- Must be greater than 0
  PRIMARY KEY ([F_ID], [S_ID]),
  FOREIGN KEY ([F_ID]) REFERENCES [Freelance_Platform]([F_ID]),
  FOREIGN KEY ([S_ID]) REFERENCES [Student]([S_ID])
);
GO

-- Table linking Students to Companies
CREATE TABLE [Student_Company] (
  [C_ID] INT,  -- Foreign Key referencing Company
  [S_ID] INT,  -- Foreign Key referencing Student
  [Title] NVARCHAR(255) NOT NULL, -- Job title
  [Hiring_Date] DATE NOT NULL,  -- Hiring date
  [Salary] INT CHECK([Salary] > 0), -- Must be greater than 0
  PRIMARY KEY ([C_ID], [S_ID]),
  FOREIGN KEY ([C_ID]) REFERENCES [Company]([C_ID]),
  FOREIGN KEY ([S_ID]) REFERENCES [Student]([S_ID])
);
GO


-- Table linking Courses to Instructors (Many-to-Many Relationship)
CREATE TABLE [Course_Instructor] (
  [Crs_ID] INT,   -- Foreign Key referencing Course
  [Ins_ID] INT,   -- Foreign Key referencing Instructor
  PRIMARY KEY ([Crs_ID], [Ins_ID]),
  FOREIGN KEY ([Crs_ID]) REFERENCES [Course]([Crs_ID]),
  FOREIGN KEY ([Ins_ID]) REFERENCES [Instructor]([Ins_ID]) 
);
GO
