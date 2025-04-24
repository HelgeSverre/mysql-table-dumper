#!/bin/bash

echo "MySQL Table Dumper Installer"
echo "==========================="

# Check for fake mode
FAKE_MODE=false
if [[ "$1" == "--fake" ]]; then
    FAKE_MODE=true
    echo "Running installer in fake/local mode"
fi

# Determine installation directory
INSTALL_DIR="$(pwd)"
echo "Installing to: $INSTALL_DIR"

# Download the dumper script
echo "Downloading script..."
if [[ "$FAKE_MODE" == true ]]; then
    # In fake mode, copy the local dumper.sh instead of downloading
    cp "$(dirname "$0")/dumper.sh" "$INSTALL_DIR/mysql-dumper.sh"
    echo "Copied local dumper.sh (fake mode)"
else
    # Normal mode: download from GitHub
    curl -s https://raw.githubusercontent.com/helgesverre/mysql-table-dumper/main/dumper.sh > "$INSTALL_DIR/mysql-dumper.sh"
fi
chmod +x "$INSTALL_DIR/mysql-dumper.sh"
# Configure the script
echo
echo "Let's configure your database connection:"
read -p "MySQL Username [root]: " DB_USER
DB_USER=${DB_USER:-root}

read -p "MySQL Password []: " DB_PASS
# Password can be empty

read -p "MySQL Database Name: " DB_NAME
while [ -z "$DB_NAME" ]; do
    echo "Database name is required!"
    read -p "MySQL Database Name: " DB_NAME
done

read -p "MySQL Host [127.0.0.1]: " DB_HOST
DB_HOST=${DB_HOST:-127.0.0.1}

read -p "MySQL Port [3306]: " DB_PORT
DB_PORT=${DB_PORT:-3306}

# Ask for output directory
read -p "Base Output Directory [./db_dumps]: " BASE_OUTPUT_DIR
BASE_OUTPUT_DIR=${BASE_OUTPUT_DIR:-./db_dumps}

# Create a temporary file for safe replacements
TMP_FILE=$(mktemp)
cat "$INSTALL_DIR/mysql-dumper.sh" > "$TMP_FILE"

# Define exact patterns to match and replace
# These need to be exactly as they appear in the dumper.sh file
DB_USER_PATTERN='DB_USER="root"'
DB_PASS_PATTERN='DB_PASS=""'
DB_NAME_PATTERN='DB_NAME="db_name"'
DB_HOST_PATTERN='DB_HOST="127.0.0.1"'
DB_PORT_PATTERN='DB_PORT="3306"'
BASE_DIR_PATTERN='BASE_OUTPUT_DIR="./db_dumps"'

# Perform sed replacements based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS requires an empty string after -i
    sed -i '' "s/$DB_USER_PATTERN/DB_USER=\"$DB_USER\"/" "$TMP_FILE"
    sed -i '' "s/$DB_PASS_PATTERN/DB_PASS=\"$DB_PASS\"/" "$TMP_FILE"
    sed -i '' "s/$DB_NAME_PATTERN/DB_NAME=\"$DB_NAME\"/" "$TMP_FILE"
    sed -i '' "s/$DB_HOST_PATTERN/DB_HOST=\"$DB_HOST\"/" "$TMP_FILE"
    sed -i '' "s/$DB_PORT_PATTERN/DB_PORT=\"$DB_PORT\"/" "$TMP_FILE"
    sed -i '' "s|$BASE_DIR_PATTERN|BASE_OUTPUT_DIR=\"$BASE_OUTPUT_DIR\"|" "$TMP_FILE"
else
    # Linux and other platforms
    sed -i "s/$DB_USER_PATTERN/DB_USER=\"$DB_USER\"/" "$TMP_FILE"
    sed -i "s/$DB_PASS_PATTERN/DB_PASS=\"$DB_PASS\"/" "$TMP_FILE"
    sed -i "s/$DB_NAME_PATTERN/DB_NAME=\"$DB_NAME\"/" "$TMP_FILE"
    sed -i "s/$DB_HOST_PATTERN/DB_HOST=\"$DB_HOST\"/" "$TMP_FILE"
    sed -i "s/$DB_PORT_PATTERN/DB_PORT=\"$DB_PORT\"/" "$TMP_FILE"
    sed -i "s|$BASE_DIR_PATTERN|BASE_OUTPUT_DIR=\"$BASE_OUTPUT_DIR\"|" "$TMP_FILE"
fi

# Move temp file back to final destination
mv "$TMP_FILE" "$INSTALL_DIR/mysql-dumper.sh"
chmod +x "$INSTALL_DIR/mysql-dumper.sh"

# Verify the changes
echo
echo "Configuration applied. Settings:"
grep -A 6 "DATABASE CONNECTION PARAMETERS" "$INSTALL_DIR/mysql-dumper.sh"
grep -A 3 "OUTPUT CONFIGURATION" "$INSTALL_DIR/mysql-dumper.sh"

echo
echo "Installation complete! Run your script with:"
echo "  $INSTALL_DIR/mysql-dumper.sh"
