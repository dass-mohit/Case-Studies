CREATE DATABASE IF NOT EXISTS healthcare_analytics;
USE healthcare_analytics;

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    contact_no VARCHAR(15) NOT NULL,
    address VARCHAR(255),
    chronic_conditions VARCHAR(255)
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(255) NOT NULL,
    contact_no VARCHAR(15) NOT NULL
);

CREATE TABLE Admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    diagnosis VARCHAR(255) NOT NULL,
    doctor_id INT,
    room_no VARCHAR(10)
);

CREATE TABLE Vitals (
    vital_id INT PRIMARY KEY,
    admission_id INT NOT NULL,
    recorded_time DATETIME NOT NULL,
    heart_rate INT NOT NULL,
    blood_pressure VARCHAR(10) NOT NULL,
    oxygen_level INT NOT NULL,
    temperature DECIMAL(5,2) NOT NULL
);

CREATE TABLE Treatments (
    treatment_id INT PRIMARY KEY,
    admission_id INT NOT NULL,
    treatment_date DATE NOT NULL,
    `procedure` VARCHAR(255),
    medication VARCHAR(255) NOT NULL,
    dosage VARCHAR(50)
);

CREATE TABLE Readmission_Risk (
    risk_id INT PRIMARY KEY,
    admission_id INT NOT NULL,
    prediction_date DATE NOT NULL,
    risk_score DECIMAL(5,2) NOT NULL,
    risk_level VARCHAR(10) NOT NULL,
    CONSTRAINT fk_risk_admission
        FOREIGN KEY (admission_id)
        REFERENCES Admissions(admission_id)
);

ALTER TABLE Admissions
ADD CONSTRAINT fk_admissions_patient
FOREIGN KEY (patient_id)
REFERENCES Patients(patient_id);

ALTER TABLE Admissions
ADD CONSTRAINT fk_admissions_doctor
FOREIGN KEY (doctor_id)
REFERENCES Doctors(doctor_id);

ALTER TABLE Vitals
ADD CONSTRAINT fk_vitals_admission
FOREIGN KEY (admission_id)
REFERENCES Admissions(admission_id);

ALTER TABLE Treatments
ADD CONSTRAINT fk_treatments_admission
FOREIGN KEY (admission_id)
REFERENCES Admissions(admission_id);

SELECT
    'Patients' AS table_name,
    COUNT(*) AS total_records
FROM Patients
UNION ALL
SELECT 'Doctors', COUNT(*) FROM Doctors
UNION ALL
SELECT 'Admissions', COUNT(*) FROM Admissions
UNION ALL
SELECT 'Vitals', COUNT(*) FROM Vitals
UNION ALL
SELECT 'Treatments', COUNT(*) FROM Treatments
UNION ALL
SELECT 'Readmission_Risk', COUNT(*) FROM Readmission_Risk;

SELECT
    (SELECT COUNT(*)
     FROM Admissions a
     LEFT JOIN Patients p ON a.patient_id = p.patient_id
     WHERE p.patient_id IS NULL) AS orphan_patient_refs,

    (SELECT COUNT(*)
     FROM Admissions a
     LEFT JOIN Doctors d ON a.doctor_id = d.doctor_id
     WHERE a.doctor_id IS NOT NULL
       AND d.doctor_id IS NULL) AS orphan_doctor_refs,

    (SELECT COUNT(*)
     FROM Vitals v
     LEFT JOIN Admissions a ON v.admission_id = a.admission_id
     WHERE a.admission_id IS NULL) AS orphan_vital_refs,

    (SELECT COUNT(*)
     FROM Treatments t
     LEFT JOIN Admissions a ON t.admission_id = a.admission_id
     WHERE a.admission_id IS NULL) AS orphan_treatment_refs,

    (SELECT COUNT(*)
     FROM Readmission_Risk r
     LEFT JOIN Admissions a ON r.admission_id = a.admission_id
     WHERE a.admission_id IS NULL) AS orphan_risk_refs;

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT risk_id) AS unique_risk_ids,
    COUNT(DISTINCT admission_id) AS unique_admissions,
    MIN(risk_score) AS min_risk_score,
    MAX(risk_score) AS max_risk_score
FROM Readmission_Risk;
