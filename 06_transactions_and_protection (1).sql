USE crownfield_eye;
-- Controlled UPDATE and rollback: observe the change inside the transaction, then restoration.
START TRANSACTION;
UPDATE appointment SET notes='Transaction demonstration' WHERE appointment_id=6;
SELECT appointment_id,notes FROM appointment WHERE appointment_id=6;
ROLLBACK;
SELECT appointment_id,notes FROM appointment WHERE appointment_id=6;
-- Controlled UPDATE and COMMIT: affects only a synthetic appointment.
START TRANSACTION;
UPDATE appointment SET notes='Synthetic encounter reviewed' WHERE appointment_id=6;
COMMIT;
SELECT appointment_id,notes FROM appointment WHERE appointment_id=6;
-- Controlled DELETE: only an unreferenced synthetic catalogue row.
INSERT INTO treatment(treatment_name) VALUES('Disposable demo treatment');
DELETE FROM treatment WHERE treatment_name='Disposable demo treatment';
SELECT COUNT(*) AS remaining_disposable_rows FROM treatment WHERE treatment_name='Disposable demo treatment';
-- Self-contained AES demonstration using a fresh 32-byte session key.
-- Run this entire section in the SAME Workbench session.
-- This encrypts clearly synthetic addresses, verifies recovery, then clears the key.
-- The key is not exported. After clearing it, these ciphertext values cannot be
-- decrypted by this demonstration. Production requires protected persistent keys.
SET @contact_key=RANDOM_BYTES(32);
SET SESSION block_encryption_mode='aes-256-cbc';
UPDATE patient SET contact_iv=RANDOM_BYTES(16);
UPDATE patient SET contact_email_cipher=AES_ENCRYPT(CONCAT(LOWER(patient_id),'@example.test'),@contact_key,contact_iv);
SELECT patient_id,HEX(contact_email_cipher) AS encrypted_email FROM patient ORDER BY patient_id LIMIT 3;
SELECT patient_id,CAST(AES_DECRYPT(contact_email_cipher,@contact_key,contact_iv) AS CHAR) AS decrypted_demo_email FROM patient ORDER BY patient_id LIMIT 3;
SELECT COUNT(*) AS recovered_contacts FROM patient
WHERE CAST(AES_DECRYPT(contact_email_cipher,@contact_key,contact_iv) AS CHAR)=CONCAT(LOWER(patient_id),'@example.test');
SET @contact_key=NULL;
