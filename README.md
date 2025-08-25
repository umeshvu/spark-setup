# spark-setup

spark-submit \
--class com.example.sparkjob.CsvSortJobApp \
--master spark://localhost:7077 \
target/my-spring-spark-app-1.0.0-exec.jar \
/data/input.csv /data/output