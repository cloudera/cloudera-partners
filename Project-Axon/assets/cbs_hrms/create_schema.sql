-- Create Databases
CREATE DATABASE IF NOT EXISTS core_banking_db;
CREATE DATABASE IF NOT EXISTS HRMS;

-- Use core_banking_db
USE core_banking_db;

-- Customers Table
DROP TABLE IF EXISTS customers;
CREATE EXTERNAL TABLE customers (
    customer_id INT COMMENT 'Customer ID',
    first_name STRING COMMENT 'First Name',
    last_name STRING COMMENT 'Last Name',
    gender STRING COMMENT 'Gender',
    kyc_status STRING COMMENT 'KYC Status',
    customer_type STRING COMMENT 'Customer Type',
    relationship_manager_id INT COMMENT 'FK to Relationship Manager',
    email STRING COMMENT 'Customer Email',
    phone STRING COMMENT 'Customer Phone',
    address STRING COMMENT 'Address',
    city STRING COMMENT 'City',
    state STRING COMMENT 'State',
    postal_code STRING COMMENT 'Postal Code',
    country STRING COMMENT 'Country',
    status STRING COMMENT 'Status',
    source STRING COMMENT 'Source',
    created_at STRING COMMENT 'Created At (Stored as STRING for Hive compatibility)',
    updated_at STRING COMMENT 'Updated At (Stored as STRING for Hive compatibility)',
    dob STRING COMMENT 'Date of Birth (Stored as STRING for Hive compatibility)'
) 
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/CBS/customer/';

-- Accounts Table
DROP TABLE IF EXISTS accounts;
CREATE EXTERNAL TABLE accounts (
    account_id INT COMMENT 'Account ID',
    account_number STRING COMMENT 'Account Number',
    customer_id INT COMMENT 'FK to Customer',
    account_type STRING COMMENT 'Account Type',
    balance DECIMAL(15,2) COMMENT 'Balance',
    interest_rate DECIMAL(5,2) COMMENT 'Interest Rate',
    branch_code STRING COMMENT 'Branch Code',
    currency_type STRING COMMENT 'Currency Type',
    account_status STRING COMMENT 'Account Status',
    last_transaction_date STRING COMMENT 'Last Transaction Date (Stored as STRING for Hive compatibility)',
    created_at STRING COMMENT 'Created At (Stored as STRING for Hive compatibility)'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/CBS/accounts/';

-- Transactions Table
DROP TABLE IF EXISTS transactions;
CREATE EXTERNAL TABLE transactions (
    transaction_id INT COMMENT 'Transaction ID',
    account_number STRING COMMENT 'Account Number',
    transaction_type STRING COMMENT 'Transaction Type',
    amount DECIMAL(15,2) COMMENT 'Transaction Amount',
    transaction_date STRING COMMENT 'Transaction Date (Stored as STRING for Hive compatibility)',
    branch_code STRING COMMENT 'Branch Code',
    transaction_reference_id STRING COMMENT 'Transaction Reference ID',
    currency_type STRING COMMENT 'Currency Type',
    transaction_mode STRING COMMENT 'Transaction Mode',
    transaction_status STRING COMMENT 'Transaction Status',
    transaction_due_date STRING COMMENT 'Transaction Due Date (Stored as STRING for Hive compatibility)',
    description STRING COMMENT 'Transaction Description'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/CBS/transactions/';

-- Loans Table
DROP TABLE IF EXISTS loans;
CREATE EXTERNAL TABLE loans (
    loan_id INT COMMENT 'Loan ID',
    customer_id INT COMMENT 'FK to Customer',
    loan_type STRING COMMENT 'Loan Type',
    principal_amount DECIMAL(15,2) COMMENT 'Principal Amount',
    interest_rate DECIMAL(5,2) COMMENT 'Interest Rate',
    start_date STRING COMMENT 'Start Date (Stored as STRING for Hive compatibility)',
    end_date STRING COMMENT 'End Date (Stored as STRING for Hive compatibility)',
    account_number STRING COMMENT 'Linked Account Number',
    emi_amount DECIMAL(15,2) COMMENT 'EMI Amount',
    loan_status STRING COMMENT 'Loan Status',
    outstanding_balance DECIMAL(15,2) COMMENT 'Outstanding Balance'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/CBS/loans/';

-- Feedback Table
DROP TABLE IF EXISTS feedback;
CREATE EXTERNAL TABLE feedback (
    feedback_id INT COMMENT 'Feedback ID',
    customer_id INT COMMENT 'FK to Customer',
    branch_id INT COMMENT 'Branch ID',
    feedback_date STRING COMMENT 'Feedback Date (Stored as STRING for Hive compatibility)',
    feedback_type STRING COMMENT 'Feedback Type',
    feedback_rating INT COMMENT 'Feedback Rating',
    feedback_status STRING COMMENT 'Feedback Status',
    feedback_comment STRING COMMENT 'Feedback Comment'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/CBS/feedback/';

-- HRMS Tables
USE HRMS;

-- HRMS Employees Table
DROP TABLE IF EXISTS hrms_employees;
CREATE EXTERNAL TABLE hrms_employees (
    employee_id INT COMMENT 'Employee ID',
    first_name STRING COMMENT 'First Name',
    last_name STRING COMMENT 'Last Name',
    email STRING COMMENT 'Email',
    phone STRING COMMENT 'Phone',
    department STRING COMMENT 'Department',
    position STRING COMMENT 'Position',
    hire_date STRING COMMENT 'Hire Date (Stored as STRING for Hive compatibility)',
    salary DECIMAL(10,2) COMMENT 'Salary',
    status STRING COMMENT 'Status',
    branch_id INT COMMENT 'Branch ID',
    created_at STRING COMMENT 'Created At (Stored as STRING for Hive compatibility)',
    updated_at STRING COMMENT 'Updated At (Stored as STRING for Hive compatibility)'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/HRMS/employees/';

-- HRMS Attendance Table
DROP TABLE IF EXISTS hrms_attendance;
CREATE EXTERNAL TABLE hrms_attendance (
    attendance_id INT COMMENT 'Attendance ID',
    employee_id INT COMMENT 'Employee ID',
    date STRING COMMENT 'Attendance Date (Stored as STRING for Hive compatibility)',
    status STRING COMMENT 'Status',
    created_at STRING COMMENT 'Created At (Stored as STRING for Hive compatibility)'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/HRMS/attendance/';

-- HRMS Time Tracking Table
DROP TABLE IF EXISTS hrms_time_tracking;
CREATE EXTERNAL TABLE hrms_time_tracking (
    time_tracking_id INT COMMENT 'Time Tracking ID',
    employee_id INT COMMENT 'Employee ID',
    date STRING COMMENT 'Tracking Date (Stored as STRING for Hive compatibility)',
    hours_worked DECIMAL(5,2) COMMENT 'Hours Worked',
    overtime_hours DECIMAL(5,2) COMMENT 'Overtime Hours',
    status STRING COMMENT 'Status',
    created_at STRING COMMENT 'Created At (Stored as STRING for Hive compatibility)'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/ksahu/HRMS/time_tracking/';
