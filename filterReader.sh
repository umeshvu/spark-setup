#!/bin/bash

FILTER_FILE="filter.csv"
ARCHIVE_DIR="archive"
MIGRATION_DIR="migration"

# 1. Check if filter file exists
if [[ ! -f "$FILTER_FILE" ]]; then
  echo "Filter file not found: $FILTER_FILE"
  exit 1
fi

# 2. Find oldest cycle date (format: YYYY-MM-DD)
oldest_date=$(tail -n +2 "$FILTER_FILE" | cut -d',' -f2 | sort | head -n 1)

if [[ -z "$oldest_date" ]]; then
  echo "No cycle dates found in $FILTER_FILE"
  exit 1
fi

echo "Oldest cycleDate: $oldest_date"

# 3. Convert dates into comparable numeric format (yyyyMMdd)
oldest_date_num=$(date -d "$oldest_date" +"%Y%m%d")
today_date_num=$(date +"%Y%m%d")

echo "Copying files from $ARCHIVE_DIR to $MIGRATION_DIR between $oldest_date_num and $today_date_num"

# 4. Ensure migration directory exists
mkdir -p "$MIGRATION_DIR"

# 5. Loop through archive files and copy if in range
shopt -s nullglob
for file in "$ARCHIVE_DIR"/*; do
  filename=$(basename "$file")

  if [[ "$filename" =~ ([0-9]{8}) ]]; then
    file_date="${BASH_REMATCH[1]}"

    if [[ "$file_date" -ge "$oldest_date_num" && "$file_date" -le "$today_date_num" ]]; then
      echo "Copying $filename"
      cp "$file" "$MIGRATION_DIR/"
    fi
  fi
done




#!/bin/bash

ARCHIVE_DIR="./archive"
MIGRATION_DIR="./migration"
FILTER_FILE="./filter.txt"

# Ensure migration directory exists
mkdir -p "$MIGRATION_DIR"

# Check filter file existence
if [[ ! -f "$FILTER_FILE" ]]; then
  echo "Filter file not found: $FILTER_FILE"
  exit 1
fi

# Read oldest cycleDate (format yyyy-MM-dd) from filter file
OLDEST_DATE=$(awk -F',' 'NR>1 {print $2}' "$FILTER_FILE" | sort | head -n1)
TODAY=$(date +%Y-%m-%d)

echo "Oldest cycleDate: $OLDEST_DATE"
echo "Today's date    : $TODAY"
echo "Copying files between $OLDEST_DATE and $TODAY ..."

# Convert to yyyymmdd for numeric comparison
OLDEST_DATE_NUM=$(date -d "$OLDEST_DATE" +%Y%m%d)
TODAY_NUM=$(date -d "$TODAY" +%Y%m%d)

# Loop through archive files
for file in "$ARCHIVE_DIR"/*; do
  filename=$(basename "$file")

  # Extract 8-digit date (yyyymmdd) from filename
  if [[ "$filename" =~ ([0-9]{8}) ]]; then
    FILE_DATE="${BASH_REMATCH[1]}"
    FILE_DATE_FMT=$(date -d "$FILE_DATE" +%Y-%m-%d)
    FILE_DATE_NUM=$(date -d "$FILE_DATE_FMT" +%Y%m%d)

    # Compare dates
    if [[ $FILE_DATE_NUM -ge $OLDEST_DATE_NUM && $FILE_DATE_NUM -le $TODAY_NUM ]]; then
      echo "Copying $filename ..."
      cp "$file" "$MIGRATION_DIR/"
    else
      echo "Skipping $filename (out of range)"
    fi
  else
    echo "Skipping $filename (no date found)"
  fi
done

# Move filter file itself
mv "$FILTER_FILE" "$MIGRATION_DIR/"

echo "Migration complete."


# 6. Move filter file itself to migration directory
echo "Moving filter file to $MIGRATION_DIR"
mv "$FILTER_FILE" "$MIGRATION_DIR/"
