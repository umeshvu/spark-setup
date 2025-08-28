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

# 5. Loop through archive files and copy only those within range
shopt -s nullglob
for file in "$ARCHIVE_DIR"/*; do
  filename=$(basename "$file")

  # Expecting filenames to have YYYYMMDD inside
  if [[ "$filename" =~ ([0-9]{8}) ]]; then
    file_date="${BASH_REMATCH[1]}"

    if [[ "$file_date" -ge "$oldest_date_num" && "$file_date" -le "$today_date_num" ]]; then
      echo "✅ Copying $filename"
      cp "$file" "$MIGRATION_DIR/"
    else
      echo "❌ Skipping $filename (out of range)"
    fi
  else
    echo "⚠️ Skipping $filename (no date found in name)"
  fi
done
