#
#Copyright (c) 2020 Cloudera, Inc. All rights reserved.
#

from pyspark.sql import SparkSession
from pyspark.sql.functions import split, col
import sys

### Update the username and dbname
username = "<ENTER YOUR USERNAME HERE>".replace("-", "_") ##Example: "apac01"

#### DB Name and App Name accordingly
db_name = username + "_TexasPPP"
appName = username + "-CDE-Lab3-Job4-Pyspark PPP Report"

spark = SparkSession \
    .builder \
    .appName(appName) \
    .getOrCreate()

#A simple script that runs aggregate queries to be used for reporting purposes.
#spark.conf.set("spark.sql.legacy.allowCreatingManagedTableUsingNonemptyLocation","true")

print("...............................")
print(f"Running report for Jobs Retained by City")

#Delete any reports that were previously run
spark.sql(f"drop table IF EXISTS {db_name}.Jobs_Per_City_Report")
spark.sql(f"drop table IF EXISTS {db_name}.Jobs_Per_Company_Type_Report")

#Create the Jobs Per City Report
cityReport = f"create table {db_name}.Jobs_Per_City_Report as \
select * from (Select \
  sum(jobsretained) as jobsretained, \
  city \
from \
  {db_name}.loan_data \
group by \
  city \
) A order by A.jobsretained desc"

#Run the query to make the new table with the result data
print("...............................")
print(f"Running - Jobs Per City Report \n")
spark.sql(cityReport)

#Show the top 10 results
print("...............................")
print(f"Results - Jobs Per City Report \n")
cityReportResults = f"select * from {db_name}.Jobs_Per_City_Report limit 10"
spark.sql(cityReportResults).show()

#Create the Jobs Retained per Company Type Report
companyTypeReport = f"create table {db_name}.Jobs_Per_Company_Type_Report as \
select * from (Select \
  sum(jobsretained) as jobsretained, \
  businesstype \
from \
  {db_name}.loan_data \
group by \
  businesstype \
) A order by A.jobsretained desc"

#Run the query to make the new table with the result data
print("...............................")
print(f"Running - Jobs Per Company Type Report \n")
spark.sql(companyTypeReport)

#Show the top 10 results
print("...............................")
print(f"Results - Jobs Per Company Type Report \n")
cityReportResults = f"select * from {db_name}.Jobs_Per_Company_Type_Report limit 10"
spark.sql(cityReportResults).show()
