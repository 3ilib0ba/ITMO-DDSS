#!/bin/bash

BACKUP_DIR="/var/db/postgres1/backups"
INDEX_SPACE="/var/db/postgres1/u10/dir1"
TABLE_SPACE="/var/db/postgres1/u11/tables"

DATE=$(date +%Y%m%d%H%M%S)
BACKUP_NAME="backup_${DATE}"

FULL_PATH_NAME="${BACKUP_DIR}/${BACKUP_NAME}"
NEW_INDEX_SPACE="/var/db/postgres1/index_backups/${BACKUP_NAME}"
NEW_TABLE_SPACE="/var/db/postgres1/tables_backups/${BACKUP_NAME}"

SECOND_STORAGE="postgres0@pg155:~"

pg_basebackup -D "${FULL_PATH_NAME}" -p 9120 -U replica -X stream -T "${INDEX_SPACE}"="${NEW_INDEX_SPACE}" -T "${TABLE_SPACE}"="${NEW_TABLE_SPACE}"

/usr/local/bin/rsync -av "${FULL_PATH_NAME}" "${SECOND_STORAGE}/backups/${BACKUP_NAME}" --rsync-path="/usr/local/bin/rsync"
/usr/local/bin/rsync -av "${NEW_INDEX_SPACE}" "${SECOND_STORAGE}/index_backups/${BACKUP_NAME}" --rsync-path="/usr/local/bin/rsync"
/usr/local/bin/rsync -av "${NEW_TABLE_SPACE}" "${SECOND_STORAGE}/tables_backups/${BACKUP_NAME}" --rsync-path="/usr/local/bin/rsync"