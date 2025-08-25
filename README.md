# spark-setup

spark-submit \
--class com.example.sparkjob.CsvSortJobApp \
--master spark://localhost:7077 \
target/my-spring-spark-app-1.0.0-exec.jar \
/data/input.csv /data/output

bash script

#!/bin/bash

DIRECTORY="."

# Environment variable date range
START_DATE=${START_DATE:-20240101}
END_DATE=${END_DATE:-20241231}

shopt -s nullglob
FILES=("$DIRECTORY"/*)

# Array to hold only valid files
SELECTED_FILES=()

echo "Files between $START_DATE and $END_DATE:"
for file in "${FILES[@]}"; do
  filename=$(basename "$file")

  if [[ "$filename" =~ ([0-9]{8}) ]]; then
    file_date="${BASH_REMATCH[1]}"

    if [[ "$file_date" -ge "$START_DATE" && "$file_date" -le "$END_DATE" ]]; then
      echo "$filename"
      SELECTED_FILES+=("$file")   # add full path to array
    fi
  fi
done

if [ ${#SELECTED_FILES[@]} -eq 0 ]; then
  echo "No files found in date range!"
  exit 1
fi

# Run Spark job with all selected files as arguments
spark-submit \
  --class MySparkJob \
  --master local[2] \
  my-spark-job.jar \
  "${SELECTED_FILES[@]}"
