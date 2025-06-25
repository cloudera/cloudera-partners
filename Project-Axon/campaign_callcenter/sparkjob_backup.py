from pyspark.sql import SparkSession
from pyspark.sql.functions import col
import sys
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger("S3-to-Iceberg-Hive")

# Replace with your username
username = "ygulati"  # Example: "apac01"

# Database and Table Details
db_name = username + "_customer_db"
table_name = "customer_data"
app_name = username + "-S3-to-Iceberg-Hive"
bucket_name = "project-axon-buk-364703ca"
bucket_path = "/user/ksahu/CRM/"

# S3 Bucket Path
s3_input_path = f"s3a://{bucket_name}{bucket_path}"  # Replace with your S3 bucket and path
logger.info(f"S3 Input Path: {s3_input_path}")

# Initialize SparkSession
logger.info("Initializing SparkSession")
spark = SparkSession.builder \
    .appName(app_name).enableHiveSupport() \
    .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.spark_catalog.type", "hive") \
    .config("spark.sql.catalog.spark_catalog.uri", "thrift://hs2-project-axon-hive-1.dw-project-axon-cdp-env.dp5i-5vkq.cloudera.site:9083") \
    .getOrCreate()

logger.info("SparkSession initialized successfully")

# Read JSON files from S3
logger.info("Reading JSON files from S3")
try:
    customer_df = spark.read.option("multiline", "true").json(s3_input_path)
    logger.info("JSON data loaded successfully")
except Exception as e:
    logger.error(f"Error reading JSON files: {str(e)}")
    sys.exit(1)

# Show a sample of the data
logger.info("Sample Data:")
customer_df.show(5)

# Check if database exists; if not, create it
logger.info(f"Creating database {db_name} if not exists")
spark.sql(f"CREATE DATABASE IF NOT EXISTS {db_name}")
logger.info(f"Database {db_name} checked/created successfully")

# Create the Iceberg table if it doesn't exist
logger.info(f"Creating table {db_name}.{table_name} if not exists")
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {db_name}.{table_name} (
    address STRING,
    city STRING,
    country STRING,
    created_at STRING,
    customer_id INT,
    customer_type STRING,
    dob STRING,
    email STRING,
    first_name STRING,
    gender STRING,
    kyc_status STRING,
    last_name STRING,
    phone STRING,
    postal_code STRING,
    relationship_manager_id INT,
    source STRING,
    state STRING,
    status STRING,
    updated_at STRING
)
"""
try:
    spark.sql(create_table_query)
    logger.info(f"Table {db_name}.{table_name} checked/created successfully")
except Exception as e:
    logger.error(f"Error creating table: {str(e)}")
    sys.exit(1)

# Write data to the Iceberg table
logger.info(f"Writing data to {db_name}.{table_name}")
try:
    customer_df.writeTo(f"{db_name}.{table_name}").overwrite()
    logger.info("Data written successfully")
except Exception as e:
    logger.error(f"Error writing data to table: {str(e)}")
    sys.exit(1)

# Validate Data Insertion
logger.info(f"Validating record count in {db_name}.{table_name}")
try:
    record_count_df = spark.sql(f"SELECT COUNT(*) AS RecordCount FROM {db_name}.{table_name}")
    record_count_df.show()
    logger.info("Record count validation completed")
except Exception as e:
    logger.error(f"Error validating record count: {str(e)}")

logger.info(f"Fetching sample data from {db_name}.{table_name}")
try:
    sample_data_df = spark.sql(f"SELECT * FROM {db_name}.{table_name} LIMIT 10")
    sample_data_df.show()
    logger.info("Sample data fetched successfully")
except Exception as e:
    logger.error(f"Error fetching sample data: {str(e)}")

# Stop the SparkSession
logger.info("Stopping SparkSession")
spark.stop()
logger.info("SparkSession stopped successfully")