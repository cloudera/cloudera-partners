#
#Copyright (c) 2020 Cloudera, Inc. All rights reserved.
#

from pyspark.sql import SparkSession
from pyspark.sql.functions import split, col, regexp_replace
import sys

### Update the username and dbname
username = "<ENTER YOUR USERNAME HERE>".replace("-", "_") ## Example: "apac01"

####  DB Name and App Name accordingly
db_name = username + "_TexasPPP"
appName = username + "-CDE-Lab3-Job3-Pyspark PPP ETL"

spark = SparkSession \
    .builder \
    .appName(appName) \
    .getOrCreate()

#Path of input file in s3
input_path ="s3a://<ENTER BUCKET_NAME HERE>/cde-workshop/PPP-Over-150k-ALL.csv"

#This is to deal with tables existing before running this code. Not needed if you're starting fresh.
#spark.conf.set("spark.sql.legacy.allowCreatingManagedTableUsingNonemptyLocation","true")

#Bring data into our Spark job from S3 bucket
base_df=spark.read.option("header","true").option("inferSchema","true").csv(input_path)

#Check the schema so we know what we're dealing with
print("...............................")
print(f"printing schema")
base_df.printSchema()

#We'll use this for the > 150k as data from all states exists in this data set
texas_df = base_df.filter(base_df.State == 'TX')

#Sanity check to see how many records we ended up with after Texas filtering
print("...............................")
print(f"How many TX records did we get?")
tx_cnt = texas_df.count()
print(f"We got: %i " % tx_cnt)

#Rename our LoanRange column to an estimated loan amount to match the existing sub 150k loan data.
filtered_df = texas_df.select(col("LoanRange").alias("LoanAmount"), "City", "State", "Zip", "BusinessType", "NonProfit", "JobsRetained", "DateApproved", "Lender")

#Doing some regular expressions to replace the text values with the average dollar amount and turning the column into a double type
value_df=filtered_df.select("City", "State", "Zip", "BusinessType", "NonProfit", "JobsRetained", "DateApproved", "Lender")
value_df=filtered_df.withColumn("LoanAmount",regexp_replace(col("LoanAmount"), "[a-z] \$5-10 million", "7500000").cast("double"))
value_df=value_df.withColumn('LoanAmount',regexp_replace(col("LoanAmount"), "[a-z] \$1-2 million", "1500000").cast("double"))
value_df=value_df.withColumn('LoanAmount',regexp_replace(col("LoanAmount"), "[a-z] \$5-10 million", "7500000").cast("double"))
value_df=value_df.withColumn('LoanAmount',regexp_replace(col("LoanAmount"), "[a-z] \$2-5 million", "3500000").cast("double"))
value_df=value_df.withColumn('LoanAmount',regexp_replace(col("LoanAmount"), "[a-z] \$350,000-1 million", "675000").cast("double"))

#Simple test to see if our data looks correct
testdf = value_df.filter(value_df.LoanAmount != "7500000")
print("...............................")
print("Simple test to see if our data looks correct")
testdf.show()
#Show the final results for one more sanity check
print("...............................")
print("Show the final results for one more sanity check")
value_df.show()

#Create the databases if it doesnt exist
print("...............................")
print(f"Creating {db_name} Database if it doesn't exist\n")
spark.sql(f"CREATE DATABASE IF NOT EXISTS {db_name}")
spark.sql(f"SHOW databases like '{username}*' ").show()

print("...............................")
print(f"Inserting Data into {db_name}.loan_data table \n")

#Write the data into our Hive table
value_df.\
  write.\
  mode("overwrite").\
  saveAsTable(db_name+'.'+"loan_data", format="parquet")

#Another sanity check to make sure we inserted the right amount of data
print("...............................")
print(f"Number of records \n")
spark.sql(f"Select count(*) as RecordCount from {db_name}.loan_data").show()

print("...............................")
print(f"Retrieve 15 records for validation \n")
spark.sql(f"Select * from {db_name}.loan_data limit 15").show()
