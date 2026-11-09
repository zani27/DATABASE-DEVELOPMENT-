USE crownfield_eye;
-- Administrator-only evidence view: reads grant metadata, never password hashes.
CREATE OR REPLACE SQL SECURITY DEFINER VIEW v_role_permissions AS
 SELECT User AS role_name,Table_name AS object_name,CAST(Table_priv AS CHAR) AS privileges
 FROM mysql.tables_priv WHERE Db='crownfield_eye' AND User IN ('cf_doctor_role','cf_receptionist_role','cf_patient_role') AND CAST(Table_priv AS CHAR)<>''
 UNION ALL
 SELECT User,CONCAT(Table_name,'.',Column_name),CAST(Column_priv AS CHAR)
 FROM mysql.columns_priv WHERE Db='crownfield_eye' AND User='cf_receptionist_role'
 UNION ALL
 SELECT User,'ALL SCHEMA OBJECTS','ALL SCHEMA PRIVILEGES (NO GRANT OPTION)'
 FROM mysql.db WHERE Db='crownfield_eye' AND User='cf_administrator';
CREATE OR REPLACE SQL SECURITY DEFINER VIEW v_row_counts AS
 SELECT 'patient' AS table_name,COUNT(*) AS records FROM patient
 UNION ALL SELECT 'specialty',COUNT(*) FROM specialty
 UNION ALL SELECT 'clinician',COUNT(*) FROM clinician
 UNION ALL SELECT 'clinic',COUNT(*) FROM clinic
 UNION ALL SELECT 'appointment',COUNT(*) FROM appointment
 UNION ALL SELECT 'diagnosis',COUNT(*) FROM diagnosis
 UNION ALL SELECT 'appointment_diagnosis',COUNT(*) FROM appointment_diagnosis
 UNION ALL SELECT 'prescription',COUNT(*) FROM prescription
 UNION ALL SELECT 'medicine',COUNT(*) FROM medicine
 UNION ALL SELECT 'prescription_item',COUNT(*) FROM prescription_item
 UNION ALL SELECT 'follow_up_plan',COUNT(*) FROM follow_up_plan
 UNION ALL SELECT 'treatment',COUNT(*) FROM treatment
 UNION ALL SELECT 'appointment_treatment',COUNT(*) FROM appointment_treatment;

