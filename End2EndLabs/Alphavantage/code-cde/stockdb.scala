/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * Author: Luiz Carrossoni
 */

package com.cloudera.cde.stocks

import scala.collection.JavaConverters._

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.Path

import org.apache.iceberg.Table
import org.apache.iceberg.catalog.TableIdentifier
import org.apache.iceberg.hive.HiveCatalog
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types.DecimalType
import org.apache.spark.sql.types.IntegerType

//Create schema for temporary table from csv files

case class stocks_part(interv: String, output_size: String, time_zone: String, open: String, high: String, low: String, close: String, volume: String, ticker: String, last_refreshed: String, refreshed_at: String)

object StockProcessIceberg {
  def main(args: Array[String]): Unit = {

     val database = args(0)
     val bucket = args(1)
     val path = args(2)
     val user = args(3)

    val spark = SparkSession.builder()
           .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog")
           .config("spark.sql.catalog.spark_catalog.type", "hive")
           .config("spark.yarn.access.hadoopFileSystems", "$bucket")
           .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions")
           .getOrCreate()

    import spark.implicits._

//bucket name construction
     val dir = bucket+"user/"+user+"/"+path+"/new"
     val dirprocessed = bucket+"user/"+user+"/"+path+"/processed"
     val datatemp = database+".stock_intraday_1min_temp"
     val datafinal = database+".stock_intraday_1min"
     println(dir)
     println(datatemp)
     println(datafinal)

     println("Generating temp data")
//temporary table from csv data processing

     val dfToSchema = spark.read.option("delimiter", ",").csv(dir)
       .map(s=> stocks_part(s(2).toString, s(3).toString, s(4).toString, s(6).toString, s(7).toString, s(8).toString, s(9).toString, s(10).toString,s(0).toString, s(1).toString, s(5).toString))

//convert to decimal
     val ds = dfToSchema
              .withColumn("open", $"open".cast(DecimalType(8,4)))
              .withColumn("high", $"high".cast(DecimalType(8,4)))
              .withColumn("low", $"low".cast(DecimalType(8,4)))
              .withColumn("close", $"close".cast(DecimalType(8,4)))
              .withColumn("volume", $"volume".cast(IntegerType))
       .as('left)

//create temp view
     ds.select("left.interv","left.output_size","left.time_zone","left.open","left.high","left.low","left.close","left.volume","left.ticker","left.last_refreshed","left.refreshed_at")
       .sortWithinPartitions("left.ticker", "left.last_refreshed", "left.refreshed_at")
       .createOrReplaceTempView("temp_view")

//group data from temp view to not duplicate data
     val dsgrouped = spark.sql(s"select max(interv) as interv, max(output_size) as output_size, max(time_zone) as time_zone, max(open) as open, max(high) as high, max(low) as low, max(close) as close, max(volume) as volume, max(ticker) as ticker,max(last_refreshed) as last_refreshed, max(refreshed_at) as refreshed_at from temp_view group by ticker, last_refreshed, refreshed_at")

     dsgrouped.createOrReplaceTempView("temp_view")

     println("Merging final data")

//MERGE INTO the final table created in Impala
     spark.sql(s"MERGE INTO $database.stock_intraday_1min final USING temp_view tmp on tmp.ticker = final.ticker and tmp.last_refreshed = final.last_refreshed and tmp.refreshed_at = final.refreshed_at WHEN MATCHED THEN UPDATE SET * WHEN NOT MATCHED THEN INSERT *")

     println("Processing temp dirs")

//Clean processed files and archive

    import java.util.Calendar
    val now = Calendar.getInstance().getTime()

    import org.apache.hadoop.fs.{FileSystem, Path}
    val srcPath=new Path(dir)
    val destPath= new Path(dirprocessed+now)

    val fssource = srcPath.getFileSystem(spark.sparkContext.hadoopConfiguration)
    val fsdest = destPath.getFileSystem(spark.sparkContext.hadoopConfiguration)

    assert(fssource.mkdirs(destPath),
      s"Cannot create dir for archiving processed files")

    fssource.rename(srcPath, destPath)
    spark.stop()
  }
}