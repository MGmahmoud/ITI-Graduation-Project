USE ITI_EDW;
GO

-----------------------------------------------------------( Dim_Student )----------------------------------------------------
-- Insert into Dim_Student
INSERT INTO dim.Dim_Student (
    StudentID, 
    SSN, 
    FirstName, 
    LastName, 
    Email, 
    MaritalStatus, 
    City, 
    Street, 
    Gender, 
    BirthDate, 
    Degree, 
    Graduated, 
    TrackID, 
    BranchID, 
    IntakeID,
    PhoneNumbers
)
SELECT 
    s.S_ID AS StudentID,
    p.SSN,
    p.Fname AS FirstName,
    p.Lname AS LastName,
    p.Email,
    p.Marital_Status AS MaritalStatus,
    p.City,
    p.Street,
    p.Gender,
    p.Bdate AS BirthDate,
    p.degree AS Degree,
    s.Graduated,
    s.T_ID AS TrackID,   -- Store Track ID
    s.B_ID AS BranchID,  -- Store Branch ID
    s.In_ID AS IntakeID, -- Store Intake ID

    -- Use STRING_AGG() for cleaner phone number concatenation
    (
        SELECT STRING_AGG(CAST(pp.Phone_Num AS NVARCHAR(20)), ', ') 
        FROM ITI_Examination_System_DB.dbo.Person_Phone pp 
        WHERE pp.P_ID = p.P_ID
    ) AS PhoneNumbers

FROM ITI_Examination_System_DB.dbo.Student s
JOIN ITI_Examination_System_DB.dbo.Person p 
    ON s.S_ID = p.P_ID;

GO


-----------------------------------------------------------( Dim_Instructor )----------------------------------------------------
-- Insert into Dim_Instructor
INSERT INTO dim.Dim_Instructor (
    InstructorID, 
    SSN, 
    FirstName, 
    LastName, 
    Email, 
    MaritalStatus, 
    City, 
    Street, 
    Gender, 
    BirthDate, 
    Degree, 
    Salary, 
    HiringDate, 
    DepartmentID, 
    PhoneNumbers
)
SELECT 
    i.Ins_ID AS InstructorID,
    p.SSN,
    p.Fname AS FirstName,
    p.Lname AS LastName,
    p.Email,
    p.Marital_Status AS MaritalStatus,
    p.City,
    p.Street,
    p.Gender,
    p.Bdate AS BirthDate,
    p.Degree,
    i.Salary,
    i.Hiring_Date AS HiringDate,
    i.D_ID AS DepartmentID,

    -- Use STRING_AGG() for better performance and readability
    (
        SELECT STRING_AGG(CAST(pp.Phone_Num AS NVARCHAR(20)), ', ') 
        FROM ITI_Examination_System_DB.dbo.Person_Phone pp 
        WHERE pp.P_ID = p.P_ID
    ) AS PhoneNumbers

FROM ITI_Examination_System_DB.dbo.Instructor i
JOIN ITI_Examination_System_DB.dbo.Person p 
    ON i.Ins_ID = p.P_ID;

GO


-----------------------------------------------------------( Dim_Company )----------------------------------------------------

INSERT INTO dim.Dim_Company (CompanyID, CompanyName, CompanyType)
SELECT 
    C_ID AS CompanyID,
    Name AS CompanyName,
    Scope AS CompanyType
FROM ITI_Examination_System_DB.dbo.Company;

GO


-----------------------------------------------------------( Dim_FreelancePlatform )----------------------------------------------------

INSERT INTO dim.Dim_FreelancePlatform (PlatformID, PlatformName)
SELECT 
    F_ID AS PlatformID,
    Name AS PlatformName
FROM ITI_Examination_System_DB.dbo.Freelance_Platform;

GO


-----------------------------------------------------------( Dim_Certificate )----------------------------------------------------

INSERT INTO dim.Dim_Certificate (CertificateID, CertificateName, CertificateProvider, CertificateField)
SELECT 
    Cer_ID AS CertificateID,
    Name AS CertificateName,
    Provider AS CertificateProvider,
    Field AS CertificateField
FROM ITI_Examination_System_DB.dbo.Certificate;

GO


-----------------------------------------------------------( Dim_Department )----------------------------------------------------

INSERT INTO dim.Dim_Department (DepartmentID, DepartmentName)
SELECT
    D_ID, 
    Dept_Name 
FROM ITI_Examination_System_DB.dbo.Department;

GO


-----------------------------------------------------------( Dim_Course )----------------------------------------------------

INSERT INTO dim.Dim_Course (CourseID, CourseName, Hours)
SELECT 
    Crs_ID AS CourseID,
    Name AS CourseName,
    Hours
FROM ITI_Examination_System_DB.dbo.Course;

GO


-----------------------------------------------------------( Dim_Topic )----------------------------------------------------

INSERT INTO dim.Dim_Topic (CourseKey, TopicName)
SELECT 
    dc.CourseKey,
    t.name AS TopicName
FROM ITI_Examination_System_DB.dbo.Topic t
JOIN dim.Dim_Course dc 
    ON t.Crs_ID = dc.CourseID;

GO

-----------------------------------------------------------( Dim_Intake )----------------------------------------------------

INSERT INTO dim.Dim_Intake (IntakeID, StartDate, EndDate, IntakeType)
SELECT 
    In_ID AS IntakeID,
    Start_Date AS StartDate,
    End_Date AS EndDate,
    Type AS IntakeType
FROM ITI_Examination_System_DB.dbo.Intake;

GO


-----------------------------------------------------------( Dim_Branch )----------------------------------------------------

INSERT INTO dim.Dim_Branch (BranchID, BranchLocation, BranchName)
SELECT 
    B_ID AS BranchID,
    Location AS BranchLocation,
    Name AS BranchName
FROM ITI_Examination_System_DB.dbo.Branch;

GO


-----------------------------------------------------------( Dim_Track )----------------------------------------------------

INSERT INTO dim.Dim_Track (TrackID, TrackName, DepartmentID)
SELECT 
    T_ID AS TrackID,
    Name AS TrackName,
    D_ID AS DepartmentID
FROM ITI_Examination_System_DB.dbo.Track;

GO


-----------------------------------------------------------( Dim_Exam )----------------------------------------------------

INSERT INTO dim.Dim_Exam (ExamID, ExamDate, NumberOfTF, NumberOfMCQ, CourseID, InstructorID)
SELECT 
    E_ID AS ExamID,
    Date AS ExamDate,
    Num_of_TF,
    Num_of_MCQ,
    Crs_id AS CourseID,
    Ins_ID AS InstructorID
FROM ITI_Examination_System_DB.dbo.Exam;

GO


-----------------------------------------------------------( Dim_Question )----------------------------------------------------

INSERT INTO dim.Dim_Question (QuestionID, QuestionText, QuestionAnswer, QuestionType, CourseID)
SELECT 
    Q_ID AS QuestionID,
    Q_Text AS QuestionText,
    Q_Answer AS QuestionAnswer,
    Type AS QuestionType,
    Crs_id AS CourseID
FROM ITI_Examination_System_DB.dbo.Question;

GO


-----------------------------------------------------------( Dim_QuestionChoice )----------------------------------------------------

INSERT INTO dim.Dim_QuestionChoice (QuestionKey, ChoiceText)
SELECT 
    dq.QuestionKey,
    qc.Choice AS ChoiceText
FROM ITI_Examination_System_DB.dbo.Question_Choices qc
JOIN ITI_EDW.dim.Dim_Question dq
    ON qc.Q_ID = dq.QuestionID;

GO


-----------------------------------------------------------( Dim_Date )----------------------------------------------------

DECLARE @StartDate DATE = '1980-01-01';
DECLARE @EndDate DATE = '2030-12-31';

WITH CTE_Dates AS (
    SELECT @StartDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM CTE_Dates
    WHERE [Date] < @EndDate
)
INSERT INTO dim.Dim_Date (DateKey, [Date], Year, Quarter, Month, MonthName, Day, DayOfWeek, DayName, IsWeekend)
SELECT 
    CONVERT(INT, CONVERT(VARCHAR(8), [Date], 112)) AS DateKey,
    [Date],
    YEAR([Date]) AS Year,
    DATEPART(QUARTER, [Date]) AS Quarter,
    MONTH([Date]) AS Month,
    DATENAME(MONTH, [Date]) AS MonthName,
    DAY([Date]) AS Day,
    DATEPART(WEEKDAY, [Date]) AS DayOfWeek,
    DATENAME(WEEKDAY, [Date]) AS DayName,
    CASE WHEN DATEPART(WEEKDAY, [Date]) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend
FROM CTE_Dates
OPTION (MAXRECURSION 0);


-----------------------------------------------------------( End_Dimensions )----------------------------------------------------

GO


SELECT * FROM dim.Dim_Student;
SELECT * FROM dim.Dim_Course;
SELECT * FROM dim.Dim_Track;
SELECT * FROM dim.Dim_Branch;
SELECT * FROM dim.Dim_Intake;
SELECT * FROM dim.Dim_Instructor;
SELECT * FROM dim.Dim_Exam;
SELECT * FROM dim.Dim_Question;
SELECT * FROM dim.Dim_Certificate;
SELECT * FROM dim.Dim_Company;
SELECT * FROM dim.Dim_FreelancePlatform;
SELECT * FROM dim.Dim_Department;

GO

-----------------------------------------------------------( Fact_ExamPerformance )----------------------------------------------------

INSERT INTO fact.Fact_ExamPerformance (
    StudentKey,
    ExamKey,
    QuestionKey,
    CourseKey,
    TrackKey,
    BranchKey,
    IntakeKey,
    InstructorKey,
    DepartmentKey,
    ExamDateKey,
    StudentAnswer,
    IsCorrect,
    QuestionScore,
    PassFail
)
SELECT 
    ds.StudentKey,
    de.ExamKey,
    dq.QuestionKey,
    dc.CourseKey,
    dt.TrackKey,
    db.BranchKey,
    di.IntakeKey,
    dii.InstructorKey,
    dd.DepartmentKey,
    dd_date.DateKey AS ExamDateKey,
    
    seq.S_Answer AS StudentAnswer,
    
    -- Compare Student's Answer with the Correct Answer from Question Dimension
    CASE 
        WHEN seq.S_Answer = dq.QuestionAnswer THEN 1 
        ELSE 0 
    END AS IsCorrect,
    
    -- Assign Score Based on Correctness
    CASE 
        WHEN seq.S_Answer = dq.QuestionAnswer THEN 10  
        ELSE 0 
    END AS QuestionScore,
    
    -- Calculate Pass/Fail Based on Total Score in the Exam
    CASE 
        WHEN SUM(CASE WHEN seq.S_Answer = dq.QuestionAnswer THEN 10 ELSE 0 END) 
             OVER (PARTITION BY seq.S_ID, eq.E_ID) >= 50 THEN 'Pass'
        ELSE 'Fail' 
    END AS PassFail

FROM ITI_Examination_System_DB.dbo.Student_Exam_Questions seq
JOIN ITI_Examination_System_DB.dbo.Student s 
    ON seq.S_ID = s.S_ID
JOIN ITI_Examination_System_DB.dbo.Exam_Questions eq 
    ON seq.EQ_ID = eq.EQ_ID
JOIN ITI_Examination_System_DB.dbo.Exam e 
    ON eq.E_ID = e.E_ID
JOIN ITI_Examination_System_DB.dbo.Instructor i 
    ON e.Ins_ID = i.Ins_ID
JOIN ITI_Examination_System_DB.dbo.Track tr
    ON tr.T_ID = s.T_ID

-- Dimension Joins
JOIN dim.Dim_Student ds 
    ON s.S_ID = ds.StudentID
JOIN dim.Dim_Exam de 
    ON eq.E_ID = de.ExamID
JOIN dim.Dim_Question dq 
    ON eq.Q_ID = dq.QuestionID
JOIN dim.Dim_Course dc 
    ON e.Crs_ID = dc.CourseID
JOIN dim.Dim_Track dt 
    ON s.T_ID = dt.TrackID
JOIN dim.Dim_Branch db 
    ON s.B_ID = db.BranchID
JOIN dim.Dim_Intake di 
    ON s.In_ID = di.IntakeID
JOIN dim.Dim_Instructor dii 
    ON e.Ins_ID = dii.InstructorID
JOIN dim.Dim_Department dd 
    ON tr.D_ID = dd.DepartmentID
JOIN dim.Dim_Date dd_date 
    ON CAST(e.Date AS DATE) = dd_date.Date;  --Ensures Date Match

GO


-----------------------------------------------------------( Fact_StudentCertifications )----------------------------------------------------

INSERT INTO fact.Fact_StudentCertifications (
    CertificateKey,
    StudentKey,
    TrackKey,
    BranchKey,
    IntakeKey,
    DepartmentKey,
    DateEarnedKey
)
SELECT 
    dc.CertificateKey,
    ds.StudentKey,
    dt.TrackKey,
    db.BranchKey,
    di.IntakeKey,
    dd.DepartmentKey,
    dd_date.DateKey AS DateEarnedKey
FROM ITI_Examination_System_DB.dbo.Student_Certificate sc
JOIN ITI_Examination_System_DB.dbo.Student s 
    ON sc.S_ID = s.S_ID
JOIN ITI_Examination_System_DB.dbo.Certificate c 
    ON sc.Cer_ID = c.Cer_ID
JOIN ITI_Examination_System_DB.dbo.Track t
    ON s.T_ID = t.T_ID

-- Mapping to Dimensions
JOIN dim.Dim_Student ds 
    ON sc.S_ID = ds.StudentID
JOIN dim.Dim_Certificate dc 
    ON sc.Cer_ID = dc.CertificateID
JOIN dim.Dim_Track dt 
    ON s.T_ID = dt.TrackID
JOIN dim.Dim_Branch db 
    ON s.B_ID = db.BranchID
JOIN dim.Dim_Intake di 
    ON s.In_ID = di.IntakeID
JOIN dim.Dim_Department dd 
    ON t.D_ID = dd.DepartmentID
JOIN dim.Dim_Date dd_date 
    ON sc.Date = dd_date.Date;

GO


-----------------------------------------------------------( Fact_StudentEmployment )----------------------------------------------------

INSERT INTO fact.Fact_StudentEmployment (
    StudentKey,
    CompanyKey,
    TrackKey,
    BranchKey,
    IntakeKey,
    DepartmentKey,
    HiringDateKey,
    JobTitle,
    Salary
)
SELECT 
    ds.StudentKey,
    dc.CompanyKey,
    dt.TrackKey,
    db.BranchKey,
    di.IntakeKey,
    dd.DepartmentKey,
    dd_date.DateKey AS HiringDateKey,
    sc.Title AS JobTitle,
    sc.Salary
FROM ITI_Examination_System_DB.dbo.Student_Company sc
JOIN ITI_Examination_System_DB.dbo.Student s 
    ON sc.S_ID = s.S_ID
JOIN ITI_Examination_System_DB.dbo.Company c 
    ON sc.C_ID = c.C_ID
JOIN ITI_Examination_System_DB.dbo.Track tr
    ON tr.T_ID = s.T_ID

-- Dimension Joins
JOIN dim.Dim_Student ds 
    ON sc.S_ID = ds.StudentID
JOIN dim.Dim_Company dc 
    ON sc.C_ID = dc.CompanyID
JOIN dim.Dim_Track dt 
    ON s.T_ID = dt.TrackID
JOIN dim.Dim_Branch db 
    ON s.B_ID = db.BranchID
JOIN dim.Dim_Intake di 
    ON s.In_ID = di.IntakeID
JOIN dim.Dim_Department dd 
    ON tr.D_ID = dd.DepartmentID
JOIN dim.Dim_Date dd_date 
    ON sc.Hiring_Date = dd_date.Date;

GO


-----------------------------------------------------------( Fact_StudentFreelance )----------------------------------------------------

INSERT INTO fact.Fact_StudentFreelance (
    StudentKey,
    PlatformKey,
    TrackKey,
    BranchKey,
    IntakeKey,
    DepartmentKey,
    DateKey,
    ProjectDetails,
    Earnings
)
SELECT 
    ds.StudentKey,
    df.PlatformKey,
    dt.TrackKey,
    db.BranchKey,
    di.IntakeKey,
    dd.DepartmentKey,
    dd_date.DateKey AS DateKey,
    sf.Details AS ProjectDetails,
    sf.Cost AS Earnings
FROM ITI_Examination_System_DB.dbo.Student_Freelance sf
JOIN ITI_Examination_System_DB.dbo.Student s 
    ON sf.S_ID = s.S_ID
JOIN ITI_Examination_System_DB.dbo.Freelance_Platform f 
    ON sf.F_ID = f.F_ID
JOIN ITI_Examination_System_DB.dbo.Track tr
    ON tr.T_ID = s.T_ID

-- Dimension Joins
JOIN dim.Dim_Student ds 
    ON s.S_ID = ds.StudentID
JOIN dim.Dim_FreelancePlatform df 
    ON f.F_ID = df.PlatformID
JOIN dim.Dim_Track dt 
    ON s.T_ID = dt.TrackID
JOIN dim.Dim_Branch db 
    ON s.B_ID = db.BranchID
JOIN dim.Dim_Intake di 
    ON s.In_ID = di.IntakeID
JOIN dim.Dim_Department dd 
    ON tr.D_ID = dd.DepartmentID
JOIN dim.Dim_Date dd_date 
    ON sf.Date = dd_date.Date;


-----------------------------------------------------------( End_Facts )----------------------------------------------------
