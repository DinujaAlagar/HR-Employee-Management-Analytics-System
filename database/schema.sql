CREATE TABLE IF NOT EXISTS departments (
    department_id INTEGER PRIMARY KEY AUTOINCREMENT,
    department_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    gender TEXT,
    email TEXT,
    phone TEXT,
    department_id INTEGER NOT NULL,
    position TEXT NOT NULL,
    join_date TEXT NOT NULL,
    employment_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Active',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id TEXT NOT NULL,
    date TEXT NOT NULL,
    check_in TEXT,
    check_out TEXT,
    status TEXT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS leave_requests (
    leave_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id TEXT NOT NULL,
    leave_type TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    reason TEXT,
    status TEXT NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS performance (
    performance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id TEXT NOT NULL,
    evaluation_date TEXT NOT NULL,
    communication REAL NOT NULL,
    teamwork REAL NOT NULL,
    productivity REAL NOT NULL,
    leadership REAL NOT NULL,
    problem_solving REAL NOT NULL,
    overall_score REAL NOT NULL,
    comments TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

INSERT OR IGNORE INTO departments(department_name) VALUES
('Human Resources'), ('Finance'), ('Information Technology'), ('Marketing'),
('Sales'), ('Operations'), ('Customer Service'), ('Administration');

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP001','Nimal Perera','Male','nimal@example.com','0771234567',department_id,'HR Assistant','2025-06-10','Full Time','Active'
FROM departments WHERE department_name='Human Resources';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP002','Kavindi Silva','Female','kavindi@example.com','0712345678',department_id,'Marketing Executive','2024-11-01','Full Time','Active'
FROM departments WHERE department_name='Marketing';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP003','Arun Kumar','Male','arun@example.com','0763456789',department_id,'Software Engineer','2025-01-15','Full Time','Active'
FROM departments WHERE department_name='Information Technology';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP004','Shenali Fernando','Female','shenali@example.com','0754567890',department_id,'Finance Officer','2023-08-20','Full Time','Active'
FROM departments WHERE department_name='Finance';

INSERT OR IGNORE INTO attendance(employee_id,date,check_in,check_out,status) VALUES
('EMP001',date('now'),'08:30','17:00','Present'),
('EMP002',date('now'),'08:45','17:10','Late'),
('EMP003',date('now'),'08:20','17:00','Present'),
('EMP004',date('now'),'08:35','17:00','Present');

INSERT OR IGNORE INTO performance
(employee_id,evaluation_date,communication,teamwork,productivity,leadership,problem_solving,overall_score,comments)
VALUES
('EMP001','2026-08-30',82,86,80,76,84,81.6,'Consistent performance and good teamwork.'),
('EMP002','2026-08-30',88,84,91,79,86,85.6,'Strong productivity and communication.'),
('EMP003','2026-08-30',80,90,94,82,92,87.6,'Excellent technical delivery and problem solving.'),
('EMP004','2026-08-30',85,82,86,80,84,83.4,'Reliable performance with good attention to detail.');
-- Additional Team Members

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP005','Janushika','Female','janushika@example.com','0705000001',department_id,'Project Manager','2026-01-10','Full Time','Active'
FROM departments WHERE department_name='Administration';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP006','Thinuja','Female','thinuja@example.com','0705000002',department_id,'HR Manager','2026-01-15','Full Time','Active'
FROM departments WHERE department_name='Human Resources';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP007','Tharanya','Female','tharanya@example.com','0705000003',department_id,'Recruitment Specialist','2026-02-01','Full Time','Active'
FROM departments WHERE department_name='Human Resources';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP008','Haskiya','Female','haskiya@example.com','0705000004',department_id,'HR Operations Executive','2026-02-05','Full Time','Active'
FROM departments WHERE department_name='Operations';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP009','Adhiya','Female','adhiya@example.com','0705000005',department_id,'Training & Development Officer','2026-02-10','Full Time','Active'
FROM departments WHERE department_name='Human Resources';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP010','Aysha','Female','aysha@example.com','0705000006',department_id,'Performance Management Officer','2026-02-15','Full Time','Active'
FROM departments WHERE department_name='Human Resources';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP011','Aksha','Female','aksha@example.com','0705000007',department_id,'HR Analytics Specialist','2026-02-20','Full Time','Active'
FROM departments WHERE department_name='Information Technology';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP012','Jakshika','Female','jakshika@example.com','0705000008',department_id,'Employee Relations Officer','2026-02-25','Full Time','Active'
FROM departments WHERE department_name='Human Resources';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP013','Dershan','Male','dershan@example.com','0705000009',department_id,'IT & Systems Coordinator','2026-03-01','Full Time','Active'
FROM departments WHERE department_name='Information Technology';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP014','Premnath','Male','premnath@example.com','0705000010',department_id,'Database Administrator','2026-03-05','Full Time','Active'
FROM departments WHERE department_name='Information Technology';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP015','Fathima','Female','fathima@example.com','0705000011',department_id,'UI/UX Designer','2026-03-10','Full Time','Active'
FROM departments WHERE department_name='Marketing';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP016','Asrif','Male','asrif@example.com','0705000012',department_id,'Backend Developer','2026-03-15','Full Time','Active'
FROM departments WHERE department_name='Information Technology';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP017','Sisath','Male','sisath@example.com','0705000013',department_id,'Frontend Developer','2026-03-20','Full Time','Active'
FROM departments WHERE department_name='Information Technology';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP018','Kabiska','Female','kabiska@example.com','0705000014',department_id,'Quality Assurance Officer','2026-03-25','Full Time','Active'
FROM departments WHERE department_name='Operations';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP019','Alagar','Male','alagar@example.com','0705000015',department_id,'Documentation Officer','2026-04-01','Full Time','Active'
FROM departments WHERE department_name='Administration';

INSERT OR IGNORE INTO employees
(employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
SELECT 'EMP020','Sumadhi','Female','sumadhi@example.com','0705000016',department_id,'Presentation & Communication Lead','2026-04-05','Full Time','Active'
FROM departments WHERE department_name='Customer Service';
-- 16 Team Members Attendance

INSERT OR IGNORE INTO attendance
(employee_id,date,check_in,check_out,status)
VALUES
('EMP005','2026-09-01','08:25','17:00','Present'),
('EMP006','2026-09-01','08:30','17:00','Present'),
('EMP007','2026-09-01','08:40','17:00','Late'),
('EMP008','2026-09-01','08:15','17:00','Present'),
('EMP009','2026-09-01','08:30','17:00','Present'),
('EMP010','2026-09-01','08:45','17:00','Late'),
('EMP011','2026-09-01','08:20','17:00','Present'),
('EMP012','2026-09-01','08:35','17:00','Present'),
('EMP013','2026-09-01','08:10','17:00','Present'),
('EMP014','2026-09-01','08:30','17:00','Present'),
('EMP015','2026-09-01','08:25','17:00','Present'),
('EMP016','2026-09-01','08:20','17:00','Present'),
('EMP017','2026-09-01','08:30','17:00','Present'),
('EMP018','2026-09-01','08:45','17:00','Late'),
('EMP019','2026-09-01','08:25','17:00','Present'),
('EMP020','2026-09-01','08:20','17:00','Present');


-- 16 Team Members Leave

INSERT OR IGNORE INTO leave_requests
(employee_id,leave_type,start_date,end_date,reason,status)
VALUES
('EMP005','Annual Leave','2026-09-15','2026-09-16','Personal matters','Approved'),
('EMP006','Medical Leave','2026-09-08','2026-09-08','Medical appointment','Approved'),
('EMP007','Annual Leave','2026-09-20','2026-09-22','Family vacation','Pending'),
('EMP008','Casual Leave','2026-09-12','2026-09-12','Personal work','Approved'),
('EMP009','Annual Leave','2026-09-25','2026-09-26','Family event','Pending'),
('EMP010','Medical Leave','2026-09-10','2026-09-11','Health reasons','Approved'),
('EMP011','Casual Leave','2026-09-18','2026-09-18','Personal appointment','Approved'),
('EMP012','Annual Leave','2026-09-28','2026-09-30','Family vacation','Pending'),
('EMP013','Casual Leave','2026-09-14','2026-09-14','Personal work','Approved'),
('EMP014','Medical Leave','2026-09-17','2026-09-18','Medical appointment','Approved'),
('EMP015','Annual Leave','2026-09-21','2026-09-23','Personal vacation','Pending'),
('EMP016','Casual Leave','2026-09-11','2026-09-11','Personal matters','Approved'),
('EMP017','Annual Leave','2026-09-24','2026-09-25','Family event','Approved'),
('EMP018','Medical Leave','2026-09-19','2026-09-19','Medical appointment','Pending'),
('EMP019','Casual Leave','2026-09-29','2026-09-29','Personal work','Approved'),
('EMP020','Annual Leave','2026-09-26','2026-09-28','Family vacation','Pending');


-- 16 Team Members Performance

INSERT OR IGNORE INTO performance
(employee_id,evaluation_date,communication,teamwork,productivity,leadership,problem_solving,overall_score,comments)
VALUES
('EMP005','2026-08-30',88,90,86,91,89,88.8,'Strong project coordination and leadership.'),
('EMP006','2026-08-30',92,90,88,94,91,91.0,'Excellent HR leadership and communication.'),
('EMP007','2026-08-30',87,89,90,84,88,87.6,'Effective recruitment and communication.'),
('EMP008','2026-08-30',84,88,86,82,85,85.0,'Reliable HR operations and teamwork.'),
('EMP009','2026-08-30',90,92,87,86,89,88.8,'Strong training coordination.'),
('EMP010','2026-08-30',91,88,90,89,92,90.0,'Excellent performance management skills.'),
('EMP011','2026-08-30',89,86,94,88,95,90.4,'Strong analytical and problem-solving skills.'),
('EMP012','2026-08-30',88,93,86,85,89,88.2,'Excellent employee relations and teamwork.'),
('EMP013','2026-08-30',86,89,92,84,94,89.0,'Strong technical coordination.'),
('EMP014','2026-08-30',84,87,95,86,96,89.6,'Excellent database management skills.'),
('EMP015','2026-08-30',91,90,89,87,90,89.4,'Creative UI/UX work and communication.'),
('EMP016','2026-08-30',87,88,94,85,96,90.0,'Excellent backend development skills.'),
('EMP017','2026-08-30',89,90,93,84,94,90.0,'Strong frontend development skills.'),
('EMP018','2026-08-30',86,91,88,83,90,87.6,'Good quality assurance skills.'),
('EMP019','2026-08-30',90,87,85,88,89,87.8,'Strong documentation skills.'),
('EMP020','2026-08-30',94,92,88,90,91,91.0,'Excellent presentation and communication.');