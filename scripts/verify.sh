#! /bin/bash
set -e

duplicity verify \
    --compare-data \
    --log-file /root/duplicity.log \
    --name $BACKUP_NAME \
    $OPT_ARGUMENTS \
    $BACKUP_DEST \
    $PATH_TO_BACKUP
