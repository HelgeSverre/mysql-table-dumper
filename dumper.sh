#!/bin/bash
#=====================================================
# MYSQL TABLE DUMPER
# Creates individual SQL dumps for each table in a database
# with timestamped folders for easy backup management
#=====================================================

# ====== DATABASE CONNECTION PARAMETERS ======
DB_USER="root"      # MySQL username
DB_PASS=""          # MySQL password (blank if none)
DB_NAME="db_name"   # Target database to dump
DB_HOST="127.0.0.1" # Database host (localhost IP)
DB_PORT="3306"      # MySQL port

# ====== OUTPUT CONFIGURATION ======
BASE_OUTPUT_DIR="./db_dumps" # Base output directory (configurable)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="${BASE_OUTPUT_DIR}/${TIMESTAMP}"
TOTAL_TABLES=0
DUMPED_TABLES=0

# ====== OUTPUT FUNCTIONS ======
print_header() {
    echo "=================================================="
    echo "  MySQL Table Dumper - Starting Operation"
    echo "=================================================="
}

print_success() {
    echo "=================================================="
    echo "  Dump Completed Successfully!"
    echo "  Location: $OUTPUT_DIR"
    echo "  Tables Dumped: $DUMPED_TABLES/$TOTAL_TABLES"
    echo "=================================================="
}

print_error() {
    echo "ERROR: $1"
    exit 1
}

# Function to format size in human-readable format
format_size() {
    local size=$1
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0

    while [ $size -gt 1024 ] && [ $unit -lt 4 ]; do
        size=$(($size / 1024))
        unit=$(($unit + 1))
    done

    printf "%4d %-2s" "$size" "${units[$unit]}"
}

# ====== MAIN SCRIPT ======
print_header

# Test database connection
echo "Testing connection to MySQL server..."
if ! mysql -u "$DB_USER" --password="$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" -e "USE $DB_NAME" 2> /dev/null; then
    print_error "Cannot connect to MySQL. Please check if server is running and credentials are correct."
fi
echo "Connection successful!"

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo "Created dump directory: $OUTPUT_DIR"

# Get list of all tables in the database
echo "Retrieving table list..."
TABLES=$(mysql -u "$DB_USER" --password="$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" --skip-column-names -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='$DB_NAME'" 2> /dev/null)

# Check if tables were found
if [ -z "$TABLES" ]; then
    print_error "No tables found in database $DB_NAME"
fi

# Count total tables
TOTAL_TABLES=$(echo "$TABLES" | wc -w | tr -d '[:space:]')
echo "Found $TOTAL_TABLES tables in database '$DB_NAME'"

# Loop through each table and create a separate dump file
echo "Starting dump process..."
echo ""
printf "%-10s %-12s %-40s %-10s %s\n" "SIZE" "ROWS" "TABLE NAME" "DURATION" "STATUS"
printf "%-10s %-12s %-40s %-10s %s\n" "----------" "------------" "----------------------------------------" "----------" "--------"

for TABLE in $TABLES; do
    # Get row count and data size for this table
    TABLE_INFO=$(mysql -u "$DB_USER" --password="$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" --skip-column-names -e "
        SELECT
            TABLE_ROWS,
            (DATA_LENGTH + INDEX_LENGTH)
        FROM
            INFORMATION_SCHEMA.TABLES
        WHERE
            TABLE_SCHEMA='$DB_NAME' AND
            TABLE_NAME='$TABLE';" 2> /dev/null)

    ROW_COUNT=$(echo $TABLE_INFO | cut -d' ' -f1)
    SIZE_BYTES=$(echo $TABLE_INFO | cut -d' ' -f2)

    # Format size for display
    SIZE_FORMATTED=$(format_size $SIZE_BYTES)

    # Print table info in aligned columns (without dumping yet)
    printf "%-10s %-12s %-40s " "$SIZE_FORMATTED" "$ROW_COUNT" "$TABLE"

    # Record start time in seconds
    START_TIME=$(date +%s)

    # Dump the table
    if mysqldump -u "$DB_USER" --password="$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" "$DB_NAME" "$TABLE" 2> /dev/null > "$OUTPUT_DIR/$TABLE.sql"; then
        # Calculate duration in seconds
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))

        printf "%-10s [OK]\n" "${DURATION}s"
        DUMPED_TABLES=$((DUMPED_TABLES + 1))
    else
        printf "%-10s [FAIL]\n" "---"
    fi
done

echo ""
# Show completion message with stats
print_success
