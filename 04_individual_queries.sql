USE crownfield_eye;

-- Q1: Which clinicians have at least three appointments?
SELECT c.clinician_id,c.clinician_name,COUNT(*) AS appointment_count FROM clinician c JOIN appointment a ON a.clinician_id=c.clinician_id GROUP BY c.clinician_id,c.clinician_name HAVING COUNT(*)>=3 ORDER BY appointment_count DESC,c.clinician_id;

-- Q2: Who is booked, with which clinician, and where?
SELECT a.appointment_id,p.patient_name,c.clinician_name,l.clinic_name,a.appointment_at FROM appointment a INNER JOIN patient p ON p.patient_id=a.patient_id INNER JOIN clinician c ON c.clinician_id=a.clinician_id INNER JOIN clinic l ON l.clinic_id=a.clinic_id ORDER BY a.appointment_id LIMIT 8;

-- Q3: Which appointments have no follow-up plan?
SELECT a.appointment_id,p.patient_name,a.appointment_at FROM appointment a JOIN patient p ON p.patient_id=a.patient_id LEFT JOIN follow_up_plan f ON f.appointment_id=a.appointment_id WHERE f.follow_up_id IS NULL ORDER BY a.appointment_id;

-- Q4: Which patients have more than two appointments?
WITH patient_totals AS (SELECT patient_id,COUNT(*) AS visits FROM appointment GROUP BY patient_id) SELECT p.patient_id,p.patient_name,t.visits FROM patient p JOIN patient_totals t ON p.patient_id=t.patient_id WHERE t.visits>2 ORDER BY t.visits DESC,p.patient_id;

-- Q5: What is the selected patient OP001 appointment history?
CALL sp_patient_history('OP001');

-- Q6: Does the trigger reject a follow-up before the appointment?
START TRANSACTION;
UPDATE follow_up_plan SET due_date='2026-01-01' WHERE appointment_id=1;
-- Expected SQLSTATE 45000. Run ROLLBACK even after the rejected statement.
ROLLBACK;
SELECT appointment_id,due_date FROM follow_up_plan WHERE appointment_id=1;