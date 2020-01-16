set -e

cd /data

# Restore the backedup database
mv "$DB_PATH.bak" "$DB_PATH"
