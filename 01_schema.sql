-- CPU4:103 Crownfield Eye Hospital. Fictional teaching data only.
-- Run on an empty crownfield_eye database. Existing databases are never dropped here.
CREATE DATABASE IF NOT EXISTS crownfield_eye CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE crownfield_eye;
CREATE TABLE patient (
 patient_id VARCHAR(10) PRIMARY KEY,
 patient_name VARCHAR(150) NOT NULL CHECK (CHAR_LENGTH(TRIM(patient_name))>0),
 postcode VARCHAR(10) NOT NULL,
 contact_email_cipher VARBINARY(512) NULL COMMENT 'Part D extension; AES encrypted synthetic contact email',
 contact_iv BINARY(16) NULL
) ENGINE=InnoDB;
CREATE TABLE specialty (
 specialty_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 specialty_name VARCHAR(100) NOT NULL UNIQUE CHECK (CHAR_LENGTH(TRIM(specialty_name))>0)
) ENGINE=InnoDB;
CREATE TABLE clinician (
 clinician_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 clinician_name VARCHAR(150) NOT NULL,
 specialty_id INT UNSIGNED NULL,
 FOREIGN KEY(specialty_id) REFERENCES specialty(specialty_id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
CREATE TABLE clinic (
 clinic_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 clinic_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE appointment (
 appointment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 patient_id VARCHAR(10) NOT NULL,
 clinician_id INT UNSIGNED NOT NULL,
 clinic_id INT UNSIGNED NOT NULL,
 appointment_at DATETIME NOT NULL,
 appointment_status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
 notes TEXT NULL,
 FOREIGN KEY(patient_id) REFERENCES patient(patient_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY(clinician_id) REFERENCES clinician(clinician_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY(clinic_id) REFERENCES clinic(clinic_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK(appointment_status IN ('Scheduled','Completed','Cancelled','DidNotAttend','Unknown')),
 INDEX ix_patient_date(patient_id,appointment_at), INDEX ix_clinician_date(clinician_id,appointment_at)
) ENGINE=InnoDB;
CREATE TABLE diagnosis (
 diagnosis_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 diagnosis_name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE appointment_diagnosis (
 appointment_id INT UNSIGNED NOT NULL, diagnosis_id INT UNSIGNED NOT NULL,
 PRIMARY KEY(appointment_id,diagnosis_id),
 FOREIGN KEY(appointment_id) REFERENCES appointment(appointment_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY(diagnosis_id) REFERENCES diagnosis(diagnosis_id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
CREATE TABLE prescription (
 prescription_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 appointment_id INT UNSIGNED NOT NULL,
 prescription_status VARCHAR(12) NOT NULL DEFAULT 'Draft',
 FOREIGN KEY(appointment_id) REFERENCES appointment(appointment_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK(prescription_status IN ('Draft','Issued','Cancelled'))
) ENGINE=InnoDB;
CREATE TABLE medicine (
 medicine_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 medicine_name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE prescription_item (
 prescription_id INT UNSIGNED NOT NULL, line_no SMALLINT UNSIGNED NOT NULL,
 medicine_id INT UNSIGNED NOT NULL,
 dose VARCHAR(100) NULL, route VARCHAR(40) NULL, frequency VARCHAR(100) NULL,
 duration_days SMALLINT UNSIGNED NULL,
 PRIMARY KEY(prescription_id,line_no),
 FOREIGN KEY(prescription_id) REFERENCES prescription(prescription_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY(medicine_id) REFERENCES medicine(medicine_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK(line_no>0), CHECK(duration_days IS NULL OR duration_days>0),
 CHECK(dose IS NULL OR CHAR_LENGTH(TRIM(dose))>0),
 CHECK(route IS NULL OR CHAR_LENGTH(TRIM(route))>0),
 CHECK(frequency IS NULL OR CHAR_LENGTH(TRIM(frequency))>0)
) ENGINE=InnoDB;
CREATE TABLE follow_up_plan (
 follow_up_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 appointment_id INT UNSIGNED NOT NULL UNIQUE,
 due_date DATE NOT NULL, priority VARCHAR(10) NOT NULL,
 follow_up_status VARCHAR(12) NOT NULL DEFAULT 'Planned',
 FOREIGN KEY(appointment_id) REFERENCES appointment(appointment_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK(priority IN ('Routine','High','Urgent')),
 CHECK(follow_up_status IN ('Planned','Completed','Cancelled','Unknown'))
) ENGINE=InnoDB;
CREATE TABLE treatment (
 treatment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 treatment_name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;
CREATE TABLE appointment_treatment (
 appointment_treatment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 appointment_id INT UNSIGNED NOT NULL, treatment_id INT UNSIGNED NOT NULL,
 treatment_status VARCHAR(12) NOT NULL DEFAULT 'Planned', treatment_notes TEXT NULL,
 FOREIGN KEY(appointment_id) REFERENCES appointment(appointment_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 FOREIGN KEY(treatment_id) REFERENCES treatment(treatment_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
 CHECK(treatment_status IN ('Planned','Completed','Cancelled','Unknown'))
) ENGINE=InnoDB;
-- ALTER TABLE is also demonstrated explicitly.
ALTER TABLE patient ADD CONSTRAINT chk_postcode_nonblank CHECK(CHAR_LENGTH(TRIM(postcode))>0);
