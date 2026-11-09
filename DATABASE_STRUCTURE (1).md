# Crownfield Eye Hospital database structure

Part A design handover for CPU4:103. This is the proposed structure for group integration. It specifies the logical model; implementation and individual work follow later.

## Chosen design

Thirteen related tables cover appointments, diagnoses, medicines, follow-up and treatments. Treatments are included because they appear in the scenario, although Appendix 1 contains no explicit treatment events.

PK = primary key; FK = foreign key; NULL = unknown or not supplied. Suggested MySQL types are included to remove ambiguity for the teammate implementing Part B.

## patient

One record per patient.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| patient_id | VARCHAR(10) | PK, required | Retains source identifiers OP001 to OP004 |
| patient_name | VARCHAR(150) | required | Full name as supplied; names are not unique |
| postcode | VARCHAR(10) | required | Current postcode; not a unique patient identifier |

## specialty

Controlled list of clinical specialties.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| specialty_id | INT UNSIGNED | PK, required | Generated identifier |
| specialty_name | VARCHAR(100) | required, UNIQUE | Glaucoma, Retina and Cornea in the source |

## clinician

One record per clinician.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| clinician_id | INT UNSIGNED | PK, required | Generated identifier; a name is not an identifier |
| clinician_name | VARCHAR(150) | required | Display name including title as supplied |
| specialty_id | INT UNSIGNED | FK, nullable | References specialty; zero or one primary specialty |

## clinic

One record per clinic location.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| clinic_id | INT UNSIGNED | PK, required | Generated identifier |
| clinic_name | VARCHAR(100) | required, UNIQUE | City Road, Bedford and Croydon; unique within this prototype |

## appointment

One booked encounter for one patient, clinician and clinic.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| appointment_id | INT UNSIGNED | PK, required | Generated identifier; source rows mapped to A001 to A005 for explanation |
| patient_id | VARCHAR(10) | FK, required | References patient |
| clinician_id | INT UNSIGNED | FK, required | References clinician |
| clinic_id | INT UNSIGNED | FK, required | References clinic |
| appointment_at | DATETIME | required | Combines the source date and time |
| appointment_status | VARCHAR(20) | required, default Scheduled | Scheduled / Completed / Cancelled / DidNotAttend / Unknown |
| notes | TEXT | nullable | The source Notes field is interpreted as appointment notes |

## diagnosis

Reusable catalogue of diagnosis terms.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| diagnosis_id | INT UNSIGNED | PK, required | Generated identifier |
| diagnosis_name | VARCHAR(150) | required, UNIQUE | A catalogue term, not a patient-specific observation |

## appointment_diagnosis

Diagnosis recorded at an appointment.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| appointment_id | INT UNSIGNED | PK part, FK, required | References appointment |
| diagnosis_id | INT UNSIGNED | PK part, FK, required | References diagnosis; the pair prevents duplicate links |

## prescription

Prescription header belonging to an appointment.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| prescription_id | INT UNSIGNED | PK, required | Generated identifier |
| appointment_id | INT UNSIGNED | FK, required | References appointment; several prescriptions may belong to it |
| prescription_status | VARCHAR(12) | required, default Draft | Draft / Issued / Cancelled; imported incomplete prescriptions are Draft |

## medicine

Reusable catalogue of medicine products.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| medicine_id | INT UNSIGNED | PK, required | Generated identifier |
| medicine_name | VARCHAR(150) | required, UNIQUE | Exact source term at prototype level; no None entry |

## prescription_item

One medicine line on a prescription.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| prescription_id | INT UNSIGNED | PK part, FK, required | References prescription |
| line_no | SMALLINT UNSIGNED | PK part, required, > 0 | Distinguishes lines including repeat medicines with different instructions |
| medicine_id | INT UNSIGNED | FK, required | References medicine |
| dose | VARCHAR(100) | nullable for imported drafts | Administration amount, including units; absent from source |
| route | VARCHAR(40) | nullable for imported drafts | Administration route; absent from source |
| frequency | VARCHAR(100) | nullable for imported drafts | Administration frequency; absent from source |
| duration_days | SMALLINT UNSIGNED | nullable for imported drafts, > 0 if present | Treatment duration in days; absent from source |

## follow_up_plan

Optional follow-up plan for an appointment.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| follow_up_id | INT UNSIGNED | PK, required | Generated identifier |
| appointment_id | INT UNSIGNED | FK, required, UNIQUE | References appointment; at most one plan per appointment |
| due_date | DATE | required | Derived once from source appointment date plus its interval in weeks |
| priority | VARCHAR(10) | required | Routine / High / Urgent |
| follow_up_status | VARCHAR(12) | required, default Planned | Planned / Completed / Cancelled / Unknown |

## treatment

Reusable catalogue of non-prescription treatments.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| treatment_id | INT UNSIGNED | PK, required | Generated identifier |
| treatment_name | VARCHAR(150) | required, UNIQUE | Included for the scenario; no treatment events supplied in Appendix 1 |

## appointment_treatment

Treatment occurrence associated with an appointment.

| Column | Suggested type | Key or rule | Meaning |
|---|---|---|---|
| appointment_treatment_id | INT UNSIGNED | PK, required | Generated identifier permits repeated instances of one treatment |
| appointment_id | INT UNSIGNED | FK, required | References appointment |
| treatment_id | INT UNSIGNED | FK, required | References treatment |
| treatment_status | VARCHAR(12) | required, default Planned | Planned / Completed / Cancelled / Unknown |
| treatment_notes | TEXT | nullable | Optional occurrence-specific details |

## Relationships

Each row reads: one parent relates to the stated number of child records; the parent cardinality states how many parent records each child must reference.

| Parent | Child | Parent per child | Children per parent | Child FK |
|---|---|---|---|---|
| patient | appointment | 1 | 0..* | patient_id |
| specialty | clinician | 0..1 | 0..* | specialty_id |
| clinician | appointment | 1 | 0..* | clinician_id |
| clinic | appointment | 1 | 0..* | clinic_id |
| appointment | appointment_diagnosis | 1 | 0..* | appointment_id |
| diagnosis | appointment_diagnosis | 1 | 0..* | diagnosis_id |
| appointment | prescription | 1 | 0..* | appointment_id |
| prescription | prescription_item | 1 | 1..* | prescription_id |
| medicine | prescription_item | 1 | 0..* | medicine_id |
| appointment | follow_up_plan | 1 | 0..1 | appointment_id |
| appointment | appointment_treatment | 1 | 0..* | appointment_id |
| treatment | appointment_treatment | 1 | 0..* | treatment_id |

The prescription-to-item relationship has a business minimum of one. A foreign key does not enforce that minimum. Create headers and items together in a transaction; before issue, validate that at least one complete item exists. No incomplete Draft prescription is clinically usable.

## Integrity decisions

- All PK columns and mandatory FK columns are NOT NULL. All FK types must match their referenced PK types.
- Restrict deletion and key updates of referenced records; retain clinical history and use status changes instead of destructive deletion.
- Require positive line_no and, where present, duration_days. Validate nonblank names, dose, route and frequency when supplied.
- Restrict statuses and priorities to the enumerated values in the dictionary. Apply defaults only to new records.
- Enforce at most one follow-up plan per appointment using UNIQUE(appointment_id).
- The composite appointment_diagnosis key prevents the same diagnosis being linked twice to one appointment.
- The composite prescription_item key is (prescription_id, line_no). The same medicine may occur on different lines with different directions.
- Validate follow_up_plan.due_date >= DATE(appointment.appointment_at) using a later cross-table routine or application transaction; a MySQL CHECK cannot reference another table.
- Before changing a prescription to Issued, validate at least one item and complete directions; guard subsequent item changes too. This is a cross-row rule for Part B, not an ordinary column CHECK.
- Do not impose uniqueness on (patient_id, appointment_at) or (clinician_id, appointment_at) without a confirmed booking policy. No appointment durations were supplied.

