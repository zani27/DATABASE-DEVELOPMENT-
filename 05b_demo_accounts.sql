-- Run as root after 05_security.sql on a dedicated teaching instance.
-- MySQL returns a generated password for each newly created account.
-- Save those results privately before closing the result tabs. Do not publish them.
-- Existing accounts are retained; this script does not reset their passwords.
CREATE USER IF NOT EXISTS 'cf_admin'@'localhost' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'cf_doctor'@'localhost' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'cf_receptionist'@'localhost' IDENTIFIED BY RANDOM PASSWORD;
CREATE USER IF NOT EXISTS 'OP001'@'localhost' IDENTIFIED BY RANDOM PASSWORD;

GRANT 'cf_administrator' TO 'cf_admin'@'localhost';
GRANT 'cf_doctor_role' TO 'cf_doctor'@'localhost';
GRANT 'cf_receptionist_role' TO 'cf_receptionist'@'localhost';
GRANT 'cf_patient_role' TO 'OP001'@'localhost';

SET DEFAULT ROLE 'cf_administrator' TO 'cf_admin'@'localhost';
SET DEFAULT ROLE 'cf_doctor_role' TO 'cf_doctor'@'localhost';
SET DEFAULT ROLE 'cf_receptionist_role' TO 'cf_receptionist'@'localhost';
SET DEFAULT ROLE 'cf_patient_role' TO 'OP001'@'localhost';
