name := "StockDatabase"

version := "1.0"


//For Spark 3
scalaVersion := "2.12.12"

//For Spark 3
val sparkVersion = "3.0.1"

val icebergVersion = "0.11.0"
resolvers += "Cloudera repo" at "https://nexus-private.hortonworks.com/nexus/content/groups/public"

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-sql" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-hive" % sparkVersion % "provided",
  "org.apache.spark" %% "spark-avro" % sparkVersion % "provided"
)