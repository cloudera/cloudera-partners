#
#Copyright (c) 2020 Cloudera, Inc. All rights reserved.
#

from pyspark.sql import SparkSession
from pyspark.sql.functions import split, col
import sys

### Update the username
username = "<ENTER YOUR USERNAME HERE>".replace("-", "_") ## Example : "apac01"

####  DB Name and App Name accordingly
db_name = username + "_TexasPPP"
appName = username + "-CDE-Lab3-Job2-Pyspark PPP ETL"

spark = SparkSession \
    .builder \
    .appName(appName) \
    .getOrCreate()

#Path of our file in s3
input_path ="s3a://<ENTER BUCKET_NAME HERE>/cde-workshop/PPP-Sub-150k-TX.csv"

#This is to deal with tables existing before running this code. Not needed if you're starting fresh.
#spark.conf.set("spark.sql.legacy.allowCreatingManagedTableUsingNonemptyLocation","true")

#Bring data into Spark from S3 Bucket
base_df=spark.read.option("header","true").option("inferSchema","true").csv(input_path)
#Print schema so we can see what we're working with
print("...............................")
print(f"printing schema")
base_df.printSchema()

#Filter out only the columns we actually care about
filtered_df = base_df.select("LoanAmount", "City", "State", "Zip", "BusinessType", "NonProfit", "JobsRetained", "DateApproved", "Lender")

#This is a Texas only dataset but lets do a quick count to feel good about it
print("...............................")
print(f"How many TX records did we get?")
tx_cnt = filtered_df.count()
print(f"We got: %i " % tx_cnt)

#Create the database if it doesnt exist
print("...............................")
print(f"Creating {db_name} Database \n")
spark.sql(f"CREATE DATABASE IF NOT EXISTS {db_name}")
spark.sql(f"SHOW databases like '{username}*' ").show()

print("...............................")
print(f"Inserting Data into {db_name}.loan_data table \n")

#insert the data
filtered_df.\
  write.\
  mode("append").\
  saveAsTable(db_name+'.'+"loan_data", format="parquet")

#Another sanity check to make sure we inserted the right amount of data
print("...............................")
print(f"Number of records \n")
spark.sql(f"Select count(*) as RecordCount from {db_name}.loan_data").show()

print("...............................")
print(f"Retrieve 15 records for validation \n")
spark.sql(f"Select * from {db_name}.loan_data limit 15").show()
