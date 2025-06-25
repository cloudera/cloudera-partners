-- Create Database
CREATE DATABASE IF NOT EXISTS branch_management_db;
USE branch_management_db;

-- Branches Table
DROP TABLE IF EXISTS branches;
CREATE EXTERNAL TABLE branches (
    branch_id INT COMMENT 'Unique identifier for each branch.',
    branch_name STRING COMMENT 'Name of the branch.',
    location STRING COMMENT 'Branch location.',
    region STRING COMMENT 'Region (e.g., North, South).',
    manager_id INT COMMENT 'Reference to employee_id.',
    IFSCCode STRING COMMENT 'Branch-specific IFSC code.',
    EstablishedDate STRING COMMENT 'Established date (Stored as STRING for Hive compatibility)'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/branches/';

-- Daily Operations Table
DROP TABLE IF EXISTS daily_operations;
CREATE EXTERNAL TABLE daily_operations (
    operation_id INT COMMENT 'Operational record ID.',
    branch_id INT COMMENT 'Reference to branch.',
    operation_date STRING COMMENT 'Date of operation (STRING format).',
    customers_served INT COMMENT 'Customers served.',
    transactions_processed INT COMMENT 'Transactions processed.',
    staff_count INT COMMENT 'Staff present.',
    operational_cost DECIMAL(12,2) COMMENT 'Cost of operations.'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/daily_operations/';

-- Inventory Table
DROP TABLE IF EXISTS inventory;
CREATE EXTERNAL TABLE inventory (
    inventory_id INT COMMENT 'Inventory item ID.',
    branch_id INT COMMENT 'Branch reference.',
    product_id INT COMMENT 'Product ID.',
    product_name STRING COMMENT 'Product name.',
    stock_quantity INT COMMENT 'Stock quantity.',
    unit_price DECIMAL(10,2) COMMENT 'Unit price.',
    status STRING COMMENT 'Status (Available/SoldOut).',
    stock_value DECIMAL(12,2) COMMENT 'Calculated stock value.'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/inventory/';

-- Assets Table
DROP TABLE IF EXISTS assets;
CREATE EXTERNAL TABLE assets (
    asset_id INT COMMENT 'Asset ID.',
    asset_type STRING COMMENT 'ATM, Vehicle, Software, etc.',
    location STRING COMMENT 'Asset location.',
    purchase_date STRING COMMENT 'Purchase date (STRING format).',
    status STRING COMMENT 'Active/Inactive.'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/assets/';

-- Query for task_management_db Database
-- Create Database
CREATE DATABASE IF NOT EXISTS task_management_db;
USE task_management_db;

-- Projects Table
DROP TABLE IF EXISTS projects;
CREATE EXTERNAL TABLE projects (
    project_id INT COMMENT 'Project ID.',
    project_name STRING COMMENT 'Project name.',
    description STRING COMMENT 'Description.',
    start_date STRING COMMENT 'Start date (STRING format).',
    end_date STRING COMMENT 'End date (STRING format).',
    created_at STRING COMMENT 'Creation timestamp (STRING format).'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/projects/';

-- Tasks Table
DROP TABLE IF EXISTS tasks;
CREATE EXTERNAL TABLE tasks (
    task_id INT COMMENT 'Task ID.',
    task_name STRING COMMENT 'Task name.',
    project_id INT COMMENT 'Project reference.',
    assigned_to INT COMMENT 'Employee reference.',
    status STRING COMMENT 'To Do / In Progress / Done.',
    priority STRING COMMENT 'Low / Medium / High / Critical.',
    due_date STRING COMMENT 'Due date (STRING format).',
    created_at STRING COMMENT 'Created timestamp.',
    updated_at STRING COMMENT 'Updated timestamp.'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/tasks/';

-- Task Comments Table
DROP TABLE IF EXISTS task_comments;
CREATE EXTERNAL TABLE task_comments (
    comment_id INT COMMENT 'Comment ID.',
    task_id INT COMMENT 'Task reference.',
    comment STRING COMMENT 'Comment content.',
    commented_by INT COMMENT 'Employee ID.',
    created_at STRING COMMENT 'Comment timestamp.'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/comments/';


-- Notifications Table
DROP TABLE IF EXISTS notifications;
CREATE EXTERNAL TABLE notifications (
    notification_id INT COMMENT 'Notification ID.',
    user_id INT COMMENT 'User reference.',
    task_id INT COMMENT 'Task reference.',
    message STRING COMMENT 'Notification message.',
    is_read BOOLEAN COMMENT 'Read/unread flag.',
    created_at STRING COMMENT 'Creation timestamp.'
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/notifications/';

