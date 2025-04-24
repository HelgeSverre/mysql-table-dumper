# MySQL Table Dumper

A simple utility script to create individual SQL dumps of each table in a MySQL database. The script automatically
creates timestamped directories for organized backups and provides detailed information about the process.

## Features

- Creates separate SQL dump files for each table
- Organizes dumps in timestamped folders
- Shows table sizes and row counts
- Tracks duration of each table dump
- Configurable output directory
- Easy to install and configure
- Works with macOS and Linux

## Quick Install

Run this one-liner to download, configure, and install the script in your current directory:

```bash
curl -s https://raw.githubusercontent.com/helgesverre/mysql-table-dumper/main/install.sh | bash
```

The installer will guide you through setting up your database connection parameters and output directory.

## Manual Installation

If you prefer to install manually:

1. Download the script:
   ```bash
   curl -s https://raw.githubusercontent.com/helgesverre/mysql-table-dumper/main/dumper.sh > mysql-dumper.sh
   ```

2. Make it executable:
   ```bash
   chmod +x mysql-dumper.sh
   ```

3. Edit the script to update database connection parameters and output directory:
   ```bash
   nano mysql-dumper.sh
   ```

## Usage

After installation, simply run the script:

```bash
./mysql-dumper.sh
```

The script will:

1. Create a timestamped directory under your configured output path
2. Connect to your MySQL database
3. Generate separate SQL files for each table
4. Display progress with size, row count, and duration information

## Sample Output

```
==================================================
  MySQL Table Dumper - Starting Operation
==================================================
Created dump directory: ./db_dumps/20250424_153010
Testing connection to MySQL server...
Connection successful!
Retrieving table list...
Found 42 tables in database 'my_database'
Starting dump process...

SIZE       ROWS         TABLE NAME                          DURATION   STATUS
---------- ------------ ---------------------------------------- ---------- --------
 864 KB    5756         users                               1s        [OK]
   4 MB    16214        posts                               3s        [OK]
  48 KB    164          categories                          0s        [OK]
 128 KB    620          comments                            1s        [OK]
   2 MB    1021         attachments                         2s        [OK]

==================================================
  Dump Completed Successfully!
  Location: ./db_dumps/20250424_153010
  Tables Dumped: 42/42
==================================================
```

## Development

If you want to modify or test the script locally, here's how to set up a development environment:

### Testing the Installer Locally

You can test the installer script without downloading from GitHub by using the `--fake` flag:

```bash
# Create a test directory (optional)
mkdir test_install
cd test_install

# Run the installer in fake mode
bash ../install.sh --fake
```

This will:

- Skip the actual download from GitHub
- Use your local copy of `dumper.sh` instead
- Run through the configuration process
- Create a working script in your current directory

```