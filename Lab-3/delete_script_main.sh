#!/bin/bash

BACKUP_DIR_MAIN="/var/db/postgres1/backups"
INDEX_DIR_MAIN="/var/db/postgres1/index_backups"
TABLES_DIR_MAIN="/var/db/postgres1/tables_backups"

SECONDS_IN_WEEK=$(( 7 * 24 * 3600 ))

current_time=$(date +%s)

for backup_dir in "$BACKUP_DIR_MAIN"/*; do
    file_modified_time=$(stat -f %m "$backup_dir")
    time_diff=$((current_time - file_modified_time))

    if [ "$time_diff" -gt "$SECONDS_IN_WEEK" ]; then
        rm -rf "$backup_dir"
        echo "file(dir) deleted $backup_dir"
    fi
done

for index_dir in "$INDEX_DIR_MAIN"/*; do
    file_modified_time=$(stat -f %m "$index_dir")
    time_diff=$((current_time - file_modified_time))

    if [ "$time_diff" -gt "$SECONDS_IN_WEEK" ]; then
        rm -rf "$index_dir"
        echo "file(dir) deleted $index_dir"
    fi
done

for tables_dir in "$TABLES_DIR_MAIN"/*; do
    file_modified_time=$(stat -f %m "$tables_dir")
    time_diff=$((current_time - file_modified_time))

    if [ "$time_diff" -gt "$SECONDS_IN_WEEK" ]; then
        rm -rf "$tables_dir"
        echo "file(dir) deleted $tables_dir"
    fi
done