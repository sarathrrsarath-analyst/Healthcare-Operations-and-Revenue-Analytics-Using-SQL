CREATE DATABASE healthcare_db;
USE healthcare_db;
CREATE TABLE patients(
patient_id INT PRIMARY KEY,
patient_name VARCHAR(100),
age INT,
gender VARCHAR(20),
city VARCHAR(100),
registration_date DATE
);
CREATE TABLE doctors(
doctor_id INT PRIMARY KEY,
doctor_name VARCHAR(100),
specialization VARCHAR(100),
experience_years INT
);
CREATE TABLE appointments(
appointment_id INT PRIMARY KEY,
patient_id INT,
doctor_id INT,
visit_date DATE,
disease VARCHAR(100)
);
CREATE TABLE billing(
bill_id INT PRIMARY KEY,
appointment_id INT,
bill_amount DECIMAL(10,2),
payment_date DATE,
payment_mode VARCHAR(50)
);

SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM appointments;
SELECT * FROM billing;

-------------------------------------------------------------------------- patients ------------------------------------------------------------------

-- Total number of patients
SELECT COUNT(*) AS total_patients
FROM patients;

-- Gender-wise patient count
SELECT gender, COUNT(*) AS patient_count
FROM patients GROUP BY gender;

-- City-wise patient distribution
SELECT city, COUNT(*) AS patient_count
FROM patients GROUP BY city;

-- Patients registered month-wise
SELECT MONTH(registration_date) AS month_no,
       COUNT(*) AS patient_count
FROM patients GROUP BY MONTH(registration_date);

-- Patients registered after a specific date
SELECT *
FROM patients
WHERE registration_date > '2023-01-01';

-- Age-wise patient grouping
SELECT
CASE
    WHEN age BETWEEN 20 AND 30 THEN '20-30'
    WHEN age BETWEEN 31 AND 40 THEN '31-40'
    WHEN age BETWEEN 41 AND 50 THEN '41-50'
    WHEN age BETWEEN 51 AND 60 THEN '51-60'
    ELSE '60+'
END AS age_group,
COUNT(*) AS patient_count
FROM patients
GROUP BY age_group;

-- Average age of patients
SELECT AVG(age) AS avg_age
FROM patients;

-- Senior citizens count
SELECT COUNT(*) AS senior_citizens
FROM patients
WHERE age > 60;

-- Chennai patients registered after 2023
SELECT *
FROM patients
WHERE city = 'Chennai'
AND registration_date >= '2023-01-01';

-- Top 5 cities with highest patients
SELECT city, COUNT(*) AS patient_count
FROM patients
GROUP BY city
ORDER BY patient_count DESC
LIMIT 5;

------------------------------------------------------------ DOCTORS ----------------------------------------------------------------------

-- Total doctors
SELECT COUNT(*) AS total_doctors
FROM doctors;

-- Specialization-wise doctor count
SELECT specialization, COUNT(*) AS doctor_count
FROM doctors
GROUP BY specialization;

-- Average experience by specialization
SELECT specialization,
       AVG(experience_years) AS avg_experience
FROM doctors
GROUP BY specialization;

-- Doctors with experience > 10 years
SELECT *
FROM doctors
WHERE experience_years > 10;

-- List doctors with specialization
SELECT doctor_name, specialization
FROM doctors;

-- Most experienced doctor
SELECT *
FROM doctors
ORDER BY experience_years DESC
LIMIT 1;

-- Least experienced doctor
SELECT *
FROM doctors
ORDER BY experience_years ASC
LIMIT 1;

-- Doctors without appointments
SELECT d.*
FROM doctors d
LEFT JOIN appointments a
ON d.doctor_id = a.doctor_id
WHERE a.doctor_id IS NULL;

-- Doctor count per experience range
SELECT
CASE
    WHEN experience_years BETWEEN 0 AND 5 THEN '0-5'
    WHEN experience_years BETWEEN 6 AND 10 THEN '6-10'
    ELSE '10+'
END AS experience_range,
COUNT(*) AS doctor_count
FROM doctors
GROUP BY experience_range;

-- Top 3 experienced doctors
SELECT *
FROM doctors
ORDER BY experience_years DESC
LIMIT 3;

------------------------------------------ APPOINTMENTS -------------------------------------------------

-- Total appointments
SELECT COUNT(*) AS total_appointments
FROM appointments;

-- Doctor-wise appointment count
SELECT doctor_id,
       COUNT(*) AS appointment_count
FROM appointments
GROUP BY doctor_id;

-- Patient-wise visit count
SELECT patient_id,
       COUNT(*) AS visit_count
FROM appointments
GROUP BY patient_id;

-- Month-wise appointment trend
SELECT MONTH(visit_date) AS month_no,
       COUNT(*) AS total_visits
FROM appointments
GROUP BY MONTH(visit_date);

-- Disease-wise appointment count
SELECT disease,
       COUNT(*) AS total_cases
FROM appointments
GROUP BY disease;

-- Most frequently treated disease
SELECT disease,
       COUNT(*) AS total_cases
FROM appointments
GROUP BY disease
ORDER BY total_cases DESC
LIMIT 1;

-- Patients with more than 3 visits
SELECT patient_id,
       COUNT(*) AS visits
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 3;

-- Doctors who treated more than 50 patients
SELECT doctor_id,
       COUNT(DISTINCT patient_id) AS patient_count
FROM appointments
GROUP BY doctor_id
HAVING COUNT(DISTINCT patient_id) > 50;

-- Patients visited in last 6 months
SELECT DISTINCT patient_id
FROM appointments
WHERE visit_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- First and last visit per patient
SELECT patient_id,
       MIN(visit_date) AS first_visit,
       MAX(visit_date) AS last_visit
FROM appointments
GROUP BY patient_id;

---------------------------------------------------------- BILLING ----------------------------------------------------------------

-- Total hospital revenue
SELECT SUM(bill_amount) AS total_revenue
FROM billing;

-- Average bill amount
SELECT AVG(bill_amount) AS avg_bill
FROM billing;

-- Payment mode-wise revenue
SELECT payment_mode,
       SUM(bill_amount) AS revenue
FROM billing
GROUP BY payment_mode;

-- Payment mode-wise transaction count
SELECT payment_mode,
       COUNT(*) AS transaction_count
FROM billing
GROUP BY payment_mode;

-- Highest and lowest bill
SELECT MAX(bill_amount) AS highest_bill,
       MIN(bill_amount) AS lowest_bill
FROM billing;

-- Day-wise revenue
SELECT payment_date,
       SUM(bill_amount) AS revenue
FROM billing
GROUP BY payment_date;

-- Month-wise revenue trend
SELECT MONTH(payment_date) AS month_no,
       SUM(bill_amount) AS revenue
FROM billing
GROUP BY MONTH(payment_date);

-- Bills greater than average
SELECT *
FROM billing
WHERE bill_amount >
      (SELECT AVG(bill_amount) FROM billing);

-- Patients with total bill > 50000
SELECT a.patient_id,
       SUM(b.bill_amount) AS total_bill
FROM billing b
JOIN appointments a
ON b.appointment_id = a.appointment_id
GROUP BY a.patient_id
HAVING SUM(b.bill_amount) > 50000;

-- Top 10 highest bills
SELECT *
FROM billing
ORDER BY bill_amount DESC
LIMIT 10;

---------------------------------------------- COMBINED JOIN QUERIES ----------------------------------------------------------------------

-- City-wise revenue
SELECT p.city,
       SUM(b.bill_amount) AS revenue
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN billing b ON a.appointment_id = b.appointment_id
GROUP BY p.city;

-- Doctor-wise revenue
SELECT d.doctor_name,
       SUM(b.bill_amount) AS revenue
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN billing b ON a.appointment_id = b.appointment_id
GROUP BY d.doctor_name;

-- Specialization-wise revenue
SELECT d.specialization,
       SUM(b.bill_amount) AS revenue
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN billing b ON a.appointment_id = b.appointment_id
GROUP BY d.specialization;

-- Patient-wise total spending
SELECT p.patient_name,
       SUM(b.bill_amount) AS total_spent
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN billing b ON a.appointment_id = b.appointment_id
GROUP BY p.patient_name;

-- Top 3 doctors by revenue
SELECT d.doctor_name,
       SUM(b.bill_amount) AS revenue
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
JOIN billing b ON a.appointment_id = b.appointment_id
GROUP BY d.doctor_name
ORDER BY revenue DESC
LIMIT 3;

-- Patients consulting multiple doctors
SELECT patient_id,
       COUNT(DISTINCT doctor_id) AS doctor_count
FROM appointments
GROUP BY patient_id
HAVING COUNT(DISTINCT doctor_id) > 1;

-- Disease-wise revenue
SELECT a.disease,
       SUM(b.bill_amount) AS revenue
FROM appointments a
JOIN billing b
ON a.appointment_id = b.appointment_id
GROUP BY a.disease;

-- High-value patients
SELECT p.patient_name,
       SUM(b.bill_amount) AS total_spent
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN billing b ON a.appointment_id = b.appointment_id
GROUP BY p.patient_name
ORDER BY total_spent DESC;