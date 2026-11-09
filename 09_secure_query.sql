USE crownfield_eye;
-- Bound parameters keep input separate from executable SQL.
PREPARE patient_lookup FROM
 'SELECT patient_id,patient_name FROM patient WHERE patient_id=?';
SET @patient_input='OP001';
EXECUTE patient_lookup USING @patient_input;
-- An injection-shaped string remains literal input and matches zero patients.
SET @patient_input='OP001'' OR ''1''=''1';
EXECUTE patient_lookup USING @patient_input;
DEALLOCATE PREPARE patient_lookup;
SET @patient_input=NULL;
