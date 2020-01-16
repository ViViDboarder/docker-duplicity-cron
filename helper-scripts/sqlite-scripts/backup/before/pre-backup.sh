set -e

cd /data

# Dump the SQLite database
sqlite3 "$DB_PATH" ".backup $DB_PATH.bak"
