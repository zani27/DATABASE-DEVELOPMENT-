USE crownfield_eye;
-- Run these blocks separately while explaining them. Avoid executing the whole file at once.

-- 1 Procedure: OP001 must return four ordered appointments.
CALL sp_patient_history('OP001');

-- 2 Trigger: expected error 1644, then show the date remains unchanged.
UPDATE follow_up_plan SET due_date='2026-01-01' WHERE appointment_id=1;
SELECT appointment_id,due_date FROM follow_up_plan WHERE appointment_id=1;

-- 3 Transaction: run the entire block, not just its final SELECT.
SET @before=(SELECT notes FROM appointment WHERE appointment_id=6);
START TRANSACTION;
UPDATE appointment SET notes='Uncommitted change' WHERE appointment_id=6;
SET @during=(SELECT notes FROM appointment WHERE appointment_id=6);
ROLLBACK;
SELECT @before AS before_change,@during AS during_transaction,notes AS after_rollback
FROM appointment WHERE appointment_id=6;

-- 4 Actual security metadata, no passwords or encryption key.
SELECT * FROM v_role_permissions ORDER BY role_name,object_name;
SELECT patient_id,HEX(contact_email_cipher) AS ciphertext FROM patient ORDER BY patient_id LIMIT 3;
