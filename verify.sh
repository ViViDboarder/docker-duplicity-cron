#! /bin/bash
set -euf

# Intentionally not wrapping OPT_ARGUMENTS
# shellcheck disable=SC2086
duplicity verify \
    --compare-data \
    --log-file /root/duplicity.log \
    --name "$BACKUP_NAME" \
    $OPT_ARGUMENTS \
    "$BACKUP_DEST" \
    "$PATH_TO_BACKUP"
