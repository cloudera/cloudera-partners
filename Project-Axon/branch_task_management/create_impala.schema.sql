-- Create Task Management Database
CREATE DATABASE IF NOT EXISTS task_management_db;
USE task_management_db;

DROP TABLE IF EXISTS task_management_db.projects;
CREATE EXTERNAL TABLE task_management_db.projects (
  created_at STRING COMMENT 'Creation timestamp (STRING format).',
  description STRING COMMENT 'Description.',
  end_date STRING COMMENT 'End date (STRING format).',
  project_id INT COMMENT 'Project ID.',
  project_name STRING COMMENT 'Project name.',
  start_date STRING COMMENT 'Start date (STRING format).'
)
ROW FORMAT SERDE
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/projects/';


-- Tasks Table (column order as per Parquet schema)
DROP TABLE IF EXISTS task_management_db.tasks;
CREATE EXTERNAL TABLE task_management_db.tasks (
    assigned_to INT COMMENT 'Employee reference.',
    created_at STRING COMMENT 'Created timestamp.',
    due_date STRING COMMENT 'Due date (STRING format).',
    priority STRING COMMENT 'Low / Medium / High / Critical.',
    project_id INT COMMENT 'Project reference.',
    status STRING COMMENT 'To Do / In Progress / Done.',
    task_id INT COMMENT 'Task ID.',
    task_name STRING COMMENT 'Task name.',
    updated_at STRING COMMENT 'Updated timestamp.'
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/tasks/';


-- Notifications Table (column order as per Parquet schema)
DROP TABLE IF EXISTS task_management_db.notifications;
CREATE EXTERNAL TABLE task_management_db.notifications (
    created_at STRING COMMENT 'Creation timestamp.',
    is_read BOOLEAN COMMENT 'Read/unread flag.',
    message STRING COMMENT 'Notification message.',
    notification_id INT COMMENT 'Notification ID.',
    task_id INT COMMENT 'Task reference.',
    user_id INT COMMENT 'User reference.'
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/notifications/';



-- Task Comments Table (column order as per Parquet schema)
DROP TABLE IF EXISTS task_management_db.comments;
CREATE EXTERNAL TABLE task_management_db.comments (
    comment STRING COMMENT 'Comment content.',
    comment_id INT COMMENT 'Comment ID.',
    commented_by INT COMMENT 'Employee ID.',
    created_at STRING COMMENT 'Comment timestamp.',
    task_id INT COMMENT 'Task reference.'
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/task_mgmt/comments/';


-- Create Branch Management Database
CREATE DATABASE IF NOT EXISTS branch_management_db;
USE branch_management_db;

DROP TABLE IF EXISTS assets;
CREATE EXTERNAL TABLE assets (
    asset_id STRING COMMENT 'Asset ID (UUID).',
    asset_type STRING COMMENT 'ATM, Vehicle, Software, etc.',
    location STRING COMMENT 'Asset location.',
    purchase_date STRING COMMENT 'Purchase date (STRING format).',
    status STRING COMMENT 'Active/Inactive.'
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/assets/';


DROP TABLE IF EXISTS branch_mgmt_db.branches;
CREATE EXTERNAL TABLE branch_mgmt_db.branches (
    established_date STRING COMMENT 'Date the branch was established.',
    ifsc_code STRING COMMENT 'IFSC code of the branch.',
    branch_id INT COMMENT 'Unique ID for the branch.',
    branch_name STRING COMMENT 'Name of the branch.',
    location STRING COMMENT 'Branch location.',
    manager_id STRING COMMENT 'ID of the branch manager.',
    region STRING COMMENT 'Region to which the branch belongs.'
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/branches/';

DROP TABLE IF EXISTS branch_management_db.daily_operations;
CREATE EXTERNAL TABLE branch_management_db.daily_operations (
    branch_id INT COMMENT 'Unique ID of the branch.',
    customers_served INT COMMENT 'Number of customers served.',
    operation_date STRING COMMENT 'Date of the operation (STRING format).',
    operation_id STRING COMMENT 'Unique ID of the operation.',
    operational_cost DOUBLE COMMENT 'Cost incurred in operations.',
    staff_count INT COMMENT 'Number of staff involved.',
    transactions_processed INT COMMENT 'Number of transactions processed.'
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/daily_operations/';

-- Inventory Table
DROP TABLE IF EXISTS branch_management_db.inventory;
CREATE EXTERNAL TABLE branch_management_db.inventory (
    branch_id INT COMMENT 'Branch reference.',
    inventory_id STRING COMMENT 'Inventory item ID (UUID).',
    product_id STRING COMMENT 'Product ID as UUID.',
    product_name STRING COMMENT 'Product name.',
    status STRING COMMENT 'Status (Available/SoldOut).',
    stock_quantity INT COMMENT 'Stock quantity.',
    stock_value DOUBLE COMMENT 'Calculated stock value.',
    unit_price DOUBLE COMMENT 'Unit price.'
)
ROW FORMAT SERDE 
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION 's3a://${s3_bucket_name}/user/aktiwari/branch_mgmt/inventory/';
