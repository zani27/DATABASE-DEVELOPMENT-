# Crownfield Eye Hospital Database

**Module:** CPU4:103 Introduction to Database  
**Platform:** MySQL Community Server 8.4 and MySQL Workbench

## Project overview

This project implements a relational database for the fictional Crownfield Eye Hospital. It replaces a flat appointment record with linked tables for patients, clinicians, clinics, diagnoses, prescriptions, treatments and follow-up plans. Primary and foreign keys, constraints, views and triggers reduce repetition and maintain consistency.

The repository covers Parts A to D through database design, implementation, six individual SQL features, access control, contact-field encryption and transaction management. Setup uses SQL scripts directly in MySQL Workbench. No Python installation or helper program is required.

All records are supplied teaching data or clearly identified synthetic additions. Added medicine directions are simulation labels, not clinical advice.

## Repository contents

| File or directory | Purpose |
|---|---|
| `01_schema.sql` | Create the database, thirteen tables, keys and constraints |
| `02_seed.sql` | Insert supplied records and additional synthetic data |
| `03_procedure_and_triggers.sql` | Create the patient-history procedure and integrity triggers |
| `04_individual_queries.sql` | Six individual SQL demonstrations |
| `05_security.sql` | Create roles, restricted views and scoped grants |
| `05b_demo_accounts.sql` | Generate account passwords, assign roles and set default roles |
| `06_transactions_and_protection.sql` | Demonstrate data changes, COMMIT, ROLLBACK and encryption |
| `07_evidence_views.sql` | Create exact table-count and role-grant views |
| `08_presentation_demo.sql` | Selected blocks for the live presentation |
| `09_secure_query.sql` | Demonstrate a parameterized query with valid and injection-shaped input |
| `DATABASE_STRUCTURE.md` | Column definitions, keys, relationships and assumptions |
| `ERD/` | Complete entity relationship diagram in DOT, SVG and PNG formats |
| `evidence/` | Query outputs, test logs, source mapping and original Workbench screenshots |

The DOT file is editable Graphviz source. SVG and PNG copies can be viewed without Graphviz. Normalization steps and their explanation are included in the report.

## Requirements

- MySQL Community Server 8.4, with InnoDB and strict SQL mode. The implementation was verified on 8.4.13.
- MySQL Workbench. Execution screenshots use version 26.10.0.
- An existing MySQL administrator account, such as `root`, with permission to create databases, accounts, roles, views, routines and triggers and inspect grant metadata.
- A dedicated teaching instance with no conflicting project database or demonstration accounts.

## Database setup in MySQL Workbench

1. Start MySQL Server and open MySQL Workbench.
2. Open an administrator connection using hostname `127.0.0.1`, port `3306`, username `root` and the password configured during MySQL installation.
3. Use **File → Open SQL Script** to open each file from the extracted repository folder.
4. Execute the scripts in the order below. Use the toolbar action that runs the complete script, rather than only the statement under the cursor.
5. Refresh the **Schemas** panel and expand `crownfield_eye` to view the tables, views and routines.

### Required execution order

| Step | Script | Instruction |
|---|---|---|
| 1 | `01_schema.sql` | Run once to create the schema and tables |
| 2 | `02_seed.sql` | Run once to insert the sample records |
| 3 | `03_procedure_and_triggers.sql` | Run the complete file, including its DELIMITER statements |
| 4 | `05_security.sql` | Create roles, restricted views and privileges |
| 5 | `05b_demo_accounts.sql` | Create accounts and save the generated passwords privately |
| 6 | `06_transactions_and_protection.sql` | Run the complete file in one connection |
| 7 | `07_evidence_views.sql` | Create the evidence views |
| 8 | `09_secure_query.sql` | Run the bound-parameter demonstration |
| 9 | `04_individual_queries.sql` | Execute Q1 to Q6 separately as explained below |

The numbering groups the assignment work; it does not replace this dependency order. Setup creates objects and inserts records, so it must begin with an empty project schema. The scripts do not delete an existing database and are not intended to be rerun over an already populated schema. Do not drop existing work to resolve a duplicate-object error; first confirm which setup steps have already completed.

### Generated passwords and account connections

`05b_demo_accounts.sql` uses MySQL's random-password generation. Each newly created account returns a generated password in its result tab. Save these passwords privately before closing the results. Do not include them in GitHub, reports or screenshots. Existing accounts retain their passwords; the script does not reset them.

Create a separate Workbench connection for each account when demonstrating access:

| Setting | Value |
|---|---|
| Hostname | `127.0.0.1` |
| Port | `3306` |
| Default schema | `crownfield_eye` |
| Username | `cf_admin`, `cf_doctor`, `cf_receptionist` or `OP001` |
| Password | The private password generated for that account |

Use `cf_admin` for routine project queries. Retain the root connection for setup and administrator-only metadata inspection.

### Encryption demonstration

File 06 generates a random 32-byte key in a session variable, encrypts synthetic contact addresses with AES-256-CBC and separate random IVs, then verifies decryption in the same connection. `recovered_contacts` should return `14`. The file clears the key afterwards and does not export it.

Consequently, the stored ciphertext cannot be decrypted after the session key has been cleared. This is a self-contained teaching demonstration, not a persistent key-management system. Repeating the encryption section generates a new key and replaces the ciphertext for the same synthetic addresses. Production use would require protected persistent keys and authenticated encryption.

## Database structure

The seeded database contains thirteen related tables and 240 records. Every main table contains at least ten additional records beyond the supplied source.

| Table | Rows | Purpose |
|---|---:|---|
| `patient` | 14 | Patient identity, postcode and encrypted synthetic contact fields |
| `specialty` | 13 | Clinician specialty catalogue |
| `clinician` | 13 | Clinician details and optional primary specialty |
| `clinic` | 13 | Appointment locations |
| `appointment` | 35 | Patient visits with a clinician and clinic |
| `diagnosis` | 14 | Diagnosis catalogue |
| `appointment_diagnosis` | 25 | Links appointments to diagnoses |
| `prescription` | 24 | Prescription headers and issue status |
| `medicine` | 14 | Medicine catalogue |
| `prescription_item` | 25 | Medicine lines and directions for each prescription |
| `follow_up_plan` | 25 | Follow-up date, priority and status |
| `treatment` | 10 | Treatment catalogue |
| `appointment_treatment` | 15 | Treatment occurrences associated with appointments |

There are also five views, one stored procedure and eight triggers. See [DATABASE_STRUCTURE.md](DATABASE_STRUCTURE.md) and [the ER diagram](ERD/Crownfield_ERD.svg) for the complete model.

## Individual SQL demonstrations

Open `04_individual_queries.sql` and run each labelled section separately.

| Feature | Purpose | Expected result |
|---|---|---|
| Q1 — GROUP BY and HAVING | Clinicians with at least three appointments | Four clinicians |
| Q2 — INNER JOIN | Appointment, patient, clinician and clinic information | Eight sample appointments |
| Q3 — LEFT JOIN | Appointments without follow-up plans | Ten appointments, IDs 26 to 35 |
| Q4 — Common table expression | Patients with more than two appointments | Six patients |
| Q5 — Input procedure | Ordered history for patient `OP001` | Four appointments |
| Q6 — Trigger | Reject a follow-up before its appointment | Error 1644 / SQLSTATE `45000`; stored date unchanged |

Q6 intentionally contains an invalid update. If Workbench stops at the expected error, execute the following `ROLLBACK` manually, then run the final SELECT to confirm that the due date is unchanged. Do not interpret this expected rejection as a setup failure.

`09_secure_query.sql` uses `PREPARE`, `EXECUTE ... USING` and a placeholder to keep input separate from executable SQL. The valid identifier returns one patient; the injection-shaped input returns no patients. It does not build SQL by concatenating user input.

For the presentation, open `08_presentation_demo.sql` and run its blocks separately. Execute the entire rollback block together so its before, during and after values are captured in the same session.

## Security model

| Account | Role | Permitted access | Main restriction |
|---|---|---|---|
| `cf_admin` | `cf_administrator` | All project-schema operations | No `GRANT OPTION` |
| `cf_doctor` | `cf_doctor_role` | Read selected clinical views and tables | No writes or protected contact access |
| `cf_receptionist` | `cf_receptionist_role` | Restricted patient and schedule views; insert and update selected booking columns | No diagnoses or clinical-note access |
| `OP001` | `cf_patient_role` | Own appointment view | No direct base-table access or writes |

The patient view uses the session login from `USER()` to filter appointments. Doctor read-only access is a deliberate prototype scope choice. MySQL manages account-password authentication; restricted views exclude encrypted contact fields.

To demonstrate access, connect as `OP001` and run `SELECT * FROM crownfield_eye.v_my_appointments;`. It should return four rows. A direct `SELECT * FROM crownfield_eye.patient;` should be denied. As `cf_receptionist`, the reception view is readable, while `SELECT * FROM crownfield_eye.diagnosis;` should be denied. These denials are expected.

## Verification and evidence

The database was tested end to end. Valid operations completed without unexpected errors, while invalid inputs were correctly rejected. The retained evidence includes expected and actual outcomes for keys, constraints, procedures, triggers, privileges, encryption and transactions.

After setup, the following SQL checks the main results:

```sql
USE crownfield_eye;
SELECT * FROM v_row_counts ORDER BY table_name;
SELECT SUM(records) AS total_records FROM v_row_counts;
CALL sp_patient_history('OP001');
SELECT appointment_id,due_date FROM follow_up_plan WHERE appointment_id=1;
SELECT * FROM v_role_permissions ORDER BY role_name,object_name;
```

The total should be `240`; the procedure should return four appointments; appointment 1 should retain a follow-up date of `2026-11-16`. File 06 demonstrates rollback restoration, a committed update and deletion of an unreferenced temporary treatment. File 08 presents the rollback values together in one result.

The `evidence/` directory contains JSON and CSV execution logs, clean-build results, source mapping and eleven original cursor-free screenshots. Each screenshot retains the complete Workbench window with the SQL editor and actual result or error visible together. The screenshot manifest records filenames and hashes. The logs preserve the original execution evidence; SQL-only setup and demonstrations are reproduced using the scripts above.

## Design assumptions

- The five source appointments represent four patients; patient ID alone cannot identify an appointment.
- Each appointment references one patient, clinician and clinic. Clinicians can work across clinic locations.
- Each clinician has at most one primary specialty in this model.
- Appointments can have several diagnoses, prescriptions and treatment occurrences, but at most one follow-up plan.
- Follow-up intervals use seven-day weeks measured from the appointment date.
- Missing source directions remain `NULL` on `Draft` prescriptions. A source value of `None` creates no prescription.
- Source appointment completion statuses remain `Unknown`; added data use explicit statuses and simulation labels.

## Limitations

The small teaching dataset does not establish concurrent clinical safety, load capacity or recovery capability. AES-CBC does not authenticate ciphertext, and this SQL demonstration discards its temporary key. Production development would need authenticated encryption, persistent managed keys, certificate-verified TLS, audit trails and recovery testing. Shared application connections would also require authenticated patient identity rather than direct database-login mapping. Historical master data, coded medicine products and fuller clinical workflows remain further work.

## References

- CPU4:103 assessment brief. *Summative Assessment Guide — Introduction to Database*. Supplied assignment document.
- Microsoft. [Database design basics](https://support.microsoft.com/en-us/access/database-design-basics).
- Oracle. [MySQL 8.4 CHECK constraints](https://dev.mysql.com/doc/refman/8.4/en/create-table-check-constraints.html).
- Oracle. [MySQL 8.4 CREATE USER](https://dev.mysql.com/doc/refman/8.4/en/create-user.html).
- Oracle. [MySQL 8.4 Using roles](https://dev.mysql.com/doc/refman/8.4/en/roles.html).
- Oracle. [MySQL 8.4 Encryption functions](https://dev.mysql.com/doc/refman/8.4/en/encryption-functions.html).
- Oracle. [MySQL 8.4 SQL prepared statements](https://dev.mysql.com/doc/refman/8.4/en/sql-prepared-statements.html).
