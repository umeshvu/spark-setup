package com.uuhere.sparktest.service;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.springframework.stereotype.Service;

@Service
public class CsvSortJob {

    public void runJob(String inputPath, String outputPath) {
        SparkSession spark = SparkSession.builder()
                .appName("CSV Sort Job")
                .master("spark://localhost:7077") // Connect to Docker Spark master
                .getOrCreate();

        Dataset<Row> csvData = spark.read()
                .option("header", "true")
                .option("inferSchema", "true")
                .csv(inputPath);

        Dataset<Row> sorted = csvData.orderBy(csvData.col("numberrange").desc());

        sorted.write()
                .option("header", "true")
                .mode("overwrite")
                .csv(outputPath);

        spark.stop();
    }
}
