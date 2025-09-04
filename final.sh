#!/bin/bash

# ================================
# CONFIGURABLE PATHS
# ================================
# FILTER_FILE="${1:-filter.csv}"       # 1st arg or default filter.csv
# ARCHIVE_DIR="${2:-archive}"          # 2nd arg or default "archive"
# REMIGRATION_DIR="${3:-remigration}"  # 3rd arg or default "remigration"

# ================================
# CONFIGURABLE PATHS (via ENV variables or defaults)
# ================================
FILTER_FILE="${FILTER_FILE:-filter.csv}"
ARCHIVE_DIR="${ARCHIVE_DIR:-archive}"
REMIGRATION_DIR="${REMIGRATION_DIR:-remigration}"

# ================================
# Detect OS (Linux vs Mac)
# ================================
convert_date() {
  input_date="$1"
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    date -j -f "%Y-%m-%d" "$input_date" +"%Y%m%d"
  else
    # Linux
    date -d "$input_date" +"%Y%m%d"
  fi
}

today_date_num=$(date +"%Y%m%d")
log_time=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$REMIGRATION_DIR/remigration_$log_time.log"

# ================================
# LOGGING FUNCTION
# ================================
log() {
  local msg="[$(date +"%Y-%m-%d %H:%M:%S")] $1"
  echo "$msg" | tee -a "$LOG_FILE"
}

# ================================
# 1. Create remigration dir if not exists
# ================================
mkdir -p "$REMIGRATION_DIR"
touch "$LOG_FILE"

# ================================
# 2. Check archive dir presence
# ================================
if [[ ! -d "$ARCHIVE_DIR" ]]; then
  log "ERROR: Archive directory not found: $ARCHIVE_DIR"
  exit 1
fi

# ================================
# 3. Read filter.csv and find oldest date
# ================================
if [[ ! -f "$FILTER_FILE" ]]; then
  log "ERROR: Filter file not found: $FILTER_FILE"
  exit 1
fi

oldest_date=$(cut -d',' -f2 "$FILTER_FILE" | sort | head -n 1)

# ================================
# 4. If no data, stop
# ================================
if [[ -z "$oldest_date" ]]; then
  log "ERROR: No cycle dates found in $FILTER_FILE"
  exit 1
fi

log "Oldest cycleDate: $oldest_date"

# ================================
# 5. Convert dates for comparison
# ================================
oldest_date_num=$(convert_date "$oldest_date")
log "Oldest cycleDate (numeric): $oldest_date_num"
log "Today’s date (numeric): $today_date_num"

# ================================
# 6. Copy eligible files
# ================================
log "Looking for files in range $oldest_date_num → $today_date_num"
shopt -s nullglob
copied=0
for file in "$ARCHIVE_DIR"/*; do
  filename=$(basename "$file")

  if [[ "$filename" =~ ([0-9]{8}) ]]; then
    file_date="${BASH_REMATCH[1]}"

    if [[ "$file_date" -ge "$oldest_date_num" && "$file_date" -le "$today_date_num" ]]; then
      log "Copying $filename → $REMIGRATION_DIR/"
      cp "$file" "$REMIGRATION_DIR/"
      ((copied++))
    fi
  fi
done

if [[ $copied -eq 0 ]]; then
  log "No files matched the date range."
else
  log "$copied files copied."
fi

# ================================
# 7. Move filter.csv into archive
# ================================
log "Moving $FILTER_FILE → $ARCHIVE_DIR/"
mv "$FILTER_FILE" "$ARCHIVE_DIR/"

log "Migration complete."
