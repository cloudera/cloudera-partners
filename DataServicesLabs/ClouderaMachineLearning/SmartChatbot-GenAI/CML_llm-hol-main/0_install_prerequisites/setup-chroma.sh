#!/bin/bash
# Script to add three lines to the top of a Python file

# Path to the Python file
FILE="/home/cdsw/.local/lib/python3.10/site-packages/chromadb/__init__.py"

# Temporary file to store the new content
TEMP_FILE=$(mktemp)

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "The specified file does not exist."
    exit 1
fi

# Use sed to remove lines containing the specific logger initialization
sed -i '/logger = logging\.getLogger(__name__)/d' "$FILE"

# The three lines to be added
LINE1="__import__('pysqlite3')"
LINE2="import sys"
LINE3="sys.modules['sqlite3'] = sys.modules.pop('pysqlite3')"

# Write the new lines to the temp file
echo "$LINE1" > "$TEMP_FILE"
echo "$LINE2" >> "$TEMP_FILE"
echo "$LINE3" >> "$TEMP_FILE"

# Append the original file content to the temp file
cat "$FILE" >> "$TEMP_FILE"

# Replace the original file with the new file
mv "$TEMP_FILE" "$FILE"

echo "Lines added successfully."

# Define the path to the YAML file
yaml_file="/home/cdsw/.local/lib/python3.10/site-packages/chromadb/log_config.yml"

# Use sed to find the pattern and replace the line
# This command looks for a line containing 'uvicorn:' followed by any number of spaces and 'level: INFO'
# and replaces it with 'level: DEBUG'
sed -i '/uvicorn:/{n;s/level: INFO/level: ERROR/;}' "$yaml_file"