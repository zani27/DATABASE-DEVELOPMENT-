USE crownfield_eye;
CREATE ROLE IF NOT EXISTS 'cf_administrator','cf_doctor_role','cf_receptionist_role','cf_patient_role';
CREATE SQL SECURITY DEFINER VIEW v_reception_patients AS SELECT patient_id,patient_name FROM patient;
CREATE SQL SECURITY DEFINER VIEW v_clinical_schedule AS
 SELECT a.appointment_id,a.patient_id,p.patient_name,a.appointment_at,a.appointment_status,c.clinician_name,l.clinic_name
 FROM appointment a JOIN patient p ON p.patient_id=a.patient_id
 JOIN clinician c ON c.clinician_id=a.clinician_id JOIN clinic l ON l.clinic_id=a.clinic_id;
CREATE SQL SECURITY DEFINER VIEW v_my_appointments AS
 SELECT a.appointment_id,a.appointment_at,a.appointment_status,l.clinic_name,c.clinician_name
 FROM appointment a JOIN clinic l ON l.clinic_id=a.clinic_id JOIN clinician c ON c.clinician_id=a.clinician_id
 WHERE a.patient_id=SUBSTRING_INDEX(USER(),'@',1);
GRANT ALL PRIVILEGES ON crownfield_eye.* TO 'cf_administrator';
GRANT SELECT ON crownfield_eye.v_clinical_schedule TO 'cf_doctor_role';
GRANT SELECT ON crownfield_eye.diagnosis TO 'cf_doctor_role';
GRANT SELECT ON crownfield_eye.appointment_diagnosis TO 'cf_doctor_role';
GRANT SELECT ON crownfield_eye.medicine TO 'cf_doctor_role';
GRANT SELECT ON crownfield_eye.prescription TO 'cf_doctor_role';
GRANT SELECT ON crownfield_eye.prescription_item TO 'cf_doctor_role';
GRANT SELECT ON crownfield_eye.v_reception_patients TO 'cf_receptionist_role';
GRANT SELECT ON crownfield_eye.v_clinical_schedule TO 'cf_receptionist_role';
GRANT INSERT(patient_id,clinician_id,clinic_id,appointment_at,appointment_status),
 UPDATE(patient_id,clinician_id,clinic_id,appointment_at,appointment_status) ON crownfield_eye.appointment TO 'cf_receptionist_role';
GRANT SELECT ON crownfield_eye.v_my_appointments TO 'cf_patient_role';
-- Run 05b_demo_accounts.sql next to create local demonstration accounts,
-- assign these roles and activate default roles. Keep generated passwords private.
