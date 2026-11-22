CREATE DATABASE IF NOT EXISTS rdm_lite
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE rdm_lite;

CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(40) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('operator', 'wali', 'guru', 'siswa') NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS classes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(30) NOT NULL UNIQUE,
    grade_level TINYINT UNSIGNED NOT NULL,
    homeroom_id INT UNSIGNED NULL,
    CONSTRAINT fk_classes_homeroom FOREIGN KEY (homeroom_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS students (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nis VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(120) NOT NULL,
    class_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NULL UNIQUE,
    CONSTRAINT fk_students_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subjects (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(15) NOT NULL UNIQUE,
    subject_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS extracurriculars (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    activity_code VARCHAR(15) NOT NULL UNIQUE,
    activity_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS teaching_assignments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT UNSIGNED NOT NULL,
    subject_id INT UNSIGNED NOT NULL,
    class_id INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_teaching_assignment (teacher_id, subject_id, class_id),
    CONSTRAINT fk_assignments_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_assignments_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    CONSTRAINT fk_assignments_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS grades (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    assignment_id INT UNSIGNED NOT NULL,
    academic_period VARCHAR(30) NOT NULL,
    task_score DECIMAL(5,2) NULL,
    midterm_score DECIMAL(5,2) NULL,
    final_exam_score DECIMAL(5,2) NULL,
    status ENUM('draft', 'submitted', 'validated', 'locked') NOT NULL DEFAULT 'draft',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_student_assignment_period (student_id, assignment_id, academic_period),
    CONSTRAINT fk_grades_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_grades_assignment FOREIGN KEY (assignment_id) REFERENCES teaching_assignments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS p5_projects (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id INT UNSIGNED NOT NULL,
    academic_period VARCHAR(30) NOT NULL,
    theme VARCHAR(100) NOT NULL,
    project_name VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_p5_project (class_id, academic_period, theme, project_name),
    CONSTRAINT fk_p5_projects_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS p5_assessments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    project_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    achievement_note TEXT NOT NULL,
    is_validated TINYINT(1) NOT NULL DEFAULT 0,
    validated_by INT UNSIGNED NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_p5_assessment (project_id, student_id),
    CONSTRAINT fk_p5_assessments_project FOREIGN KEY (project_id) REFERENCES p5_projects(id) ON DELETE CASCADE,
    CONSTRAINT fk_p5_assessments_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_p5_assessments_validator FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS report_details (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    academic_period VARCHAR(30) NOT NULL,
    attendance_sick TINYINT UNSIGNED NOT NULL DEFAULT 0,
    attendance_permit TINYINT UNSIGNED NOT NULL DEFAULT 0,
    attendance_absent TINYINT UNSIGNED NOT NULL DEFAULT 0,
    extracurricular VARCHAR(180) NOT NULL DEFAULT '',
    character_note TEXT NOT NULL,
    homeroom_note TEXT NOT NULL,
    is_validated TINYINT(1) NOT NULL DEFAULT 0,
    validated_by INT UNSIGNED NULL,
    UNIQUE KEY uq_report_detail_period (student_id, academic_period),
    CONSTRAINT fk_details_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_details_validator FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS report_cards (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    academic_period VARCHAR(30) NOT NULL,
    status ENUM('locked') NOT NULL DEFAULT 'locked',
    generated_by INT UNSIGNED NULL,
    generated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_report_card_period (student_id, academic_period),
    CONSTRAINT fk_reports_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_reports_operator FOREIGN KEY (generated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO users (username, password_hash, role, full_name) VALUES
('operator', '$2y$10$tfhpqUX/cAvrrwEfJ3B0KuE7j0MDhGUTbRC9JUhJVTTw3WKansEfO', 'operator', 'Nadia Rahma Putri'),
('wali', '$2y$10$tfhpqUX/cAvrrwEfJ3B0KuE7j0MDhGUTbRC9JUhJVTTw3WKansEfO', 'wali', 'Ahmad Fauzi, S.Pd.'),
('guru', '$2y$10$tfhpqUX/cAvrrwEfJ3B0KuE7j0MDhGUTbRC9JUhJVTTw3WKansEfO', 'guru', 'Siti Aminah, S.Pd.I.'),
('siswa', '$2y$10$tfhpqUX/cAvrrwEfJ3B0KuE7j0MDhGUTbRC9JUhJVTTw3WKansEfO', 'siswa', 'Fahri Maulana');

INSERT IGNORE INTO classes (class_name, grade_level, homeroom_id)
SELECT 'VII-A', 7, id FROM users WHERE username = 'wali';

INSERT IGNORE INTO classes (class_name, grade_level, homeroom_id) VALUES
('VIII-A', 8, NULL),
('IX-A', 9, NULL);

INSERT IGNORE INTO students (nis, full_name, class_id, user_id)
SELECT '2026001', 'Fahri Maulana', c.id, u.id
FROM classes c JOIN users u ON u.username = 'siswa'
WHERE c.class_name = 'VII-A';

INSERT IGNORE INTO subjects (subject_code, subject_name) VALUES
('BIND', 'Bahasa Indonesia'),
('PP', 'Pendidikan Pancasila'),
('MTK', 'Matematika'),
('AA', 'Akidah Akhlak'),
('BING', 'Bahasa Inggris'),
('QH', 'Al-Qur''an Hadis'),
('IPA', 'Ilmu Pengetahuan Alam'),
('FQH', 'Fikih'),
('IPS', 'Ilmu Pengetahuan Sosial'),
('MULOK', 'Mulok/Bahasa Jawa'),
('BAR', 'Bahasa Arab'),
('SKI', 'Sejarah Kebudayaan Islam'),
('PJOK', 'Pendidikan Jasmani, Olahraga, dan Kesehatan'),
('SB', 'Seni Budaya'),
('INF', 'Informatika');

INSERT IGNORE INTO extracurriculars (activity_code, activity_name) VALUES
('PRAMUKA', 'Pramuka'),
('OSIS', 'OSIS');

INSERT IGNORE INTO teaching_assignments (teacher_id, subject_id, class_id)
SELECT u.id, s.id, c.id
FROM users u
JOIN subjects s ON s.subject_code IN ('QH', 'FQH', 'MTK', 'BIND')
JOIN classes c ON c.class_name = 'VII-A'
WHERE u.username = 'guru';

INSERT IGNORE INTO grades (student_id, assignment_id, academic_period, task_score, midterm_score, final_exam_score, status)
SELECT st.id, ta.id, '2026/2027 - Ganjil',
    CASE s.subject_code WHEN 'QH' THEN 88 WHEN 'FQH' THEN 84 WHEN 'MTK' THEN 79 ELSE 91 END,
    CASE s.subject_code WHEN 'QH' THEN 85 WHEN 'FQH' THEN 82 WHEN 'MTK' THEN 81 ELSE 89 END,
    CASE s.subject_code WHEN 'QH' THEN 90 WHEN 'FQH' THEN 86 WHEN 'MTK' THEN 83 ELSE 92 END,
    'validated'
FROM students st
JOIN classes c ON c.id = st.class_id
JOIN teaching_assignments ta ON ta.class_id = c.id
JOIN subjects s ON s.id = ta.subject_id
WHERE st.nis = '2026001';