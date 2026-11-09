USE crownfield_eye;
DELIMITER $$
CREATE PROCEDURE sp_patient_history(IN p_patient_id VARCHAR(10))
SQL SECURITY INVOKER
BEGIN
 IF p_patient_id IS NULL OR CHAR_LENGTH(TRIM(p_patient_id))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Patient ID is required';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM patient WHERE patient_id=p_patient_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Patient does not exist';
 END IF;
 SELECT a.appointment_id,p.patient_name,c.clinician_name,l.clinic_name,a.appointment_at,a.appointment_status
 FROM appointment a JOIN patient p ON a.patient_id=p.patient_id
 JOIN clinician c ON a.clinician_id=c.clinician_id JOIN clinic l ON a.clinic_id=l.clinic_id
 WHERE a.patient_id=p_patient_id ORDER BY a.appointment_at,a.appointment_id;
END$$
CREATE TRIGGER trg_followup_insert BEFORE INSERT ON follow_up_plan FOR EACH ROW
BEGIN
 IF NEW.due_date < (SELECT DATE(appointment_at) FROM appointment WHERE appointment_id=NEW.appointment_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Follow-up cannot precede its appointment';
 END IF;
END$$
CREATE TRIGGER trg_followup_update BEFORE UPDATE ON follow_up_plan FOR EACH ROW
BEGIN
 IF NEW.due_date < (SELECT DATE(appointment_at) FROM appointment WHERE appointment_id=NEW.appointment_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Follow-up cannot precede its appointment';
 END IF;
END$$
CREATE TRIGGER trg_appointment_date BEFORE UPDATE ON appointment FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM follow_up_plan WHERE appointment_id=OLD.appointment_id AND due_date<DATE(NEW.appointment_at)) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Appointment would invalidate its follow-up';
 END IF;
END$$
CREATE TRIGGER trg_prescription_insert BEFORE INSERT ON prescription FOR EACH ROW
BEGIN
 IF NEW.prescription_status='Issued' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Create a draft with complete items before issue';
 END IF;
END$$
CREATE TRIGGER trg_prescription_issue BEFORE UPDATE ON prescription FOR EACH ROW
BEGIN
 IF NEW.prescription_status='Issued' AND
 (NOT EXISTS(SELECT 1 FROM prescription_item WHERE prescription_id=NEW.prescription_id)
 OR EXISTS(SELECT 1 FROM prescription_item WHERE prescription_id=NEW.prescription_id AND
 (dose IS NULL OR route IS NULL OR frequency IS NULL OR duration_days IS NULL))) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Issued prescription needs at least one complete item';
 END IF;
END$$
CREATE TRIGGER trg_item_insert BEFORE INSERT ON prescription_item FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM prescription WHERE prescription_id=NEW.prescription_id AND prescription_status='Issued') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Return issued prescription to Draft before editing items';
 END IF;
END$$
CREATE TRIGGER trg_item_update BEFORE UPDATE ON prescription_item FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM prescription WHERE prescription_id IN (OLD.prescription_id,NEW.prescription_id) AND prescription_status='Issued') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Return issued prescription to Draft before editing items';
 END IF;
END$$
CREATE TRIGGER trg_item_delete BEFORE DELETE ON prescription_item FOR EACH ROW
BEGIN
 IF EXISTS(SELECT 1 FROM prescription WHERE prescription_id=OLD.prescription_id AND prescription_status='Issued') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Return issued prescription to Draft before editing items';
 END IF;
END$$
DELIMITER ;
-- Demonstrate valid issue only for complete synthetic prescriptions.
UPDATE prescription SET prescription_status='Issued' WHERE prescription_id BETWEEN 5 AND 14;
