#! /bin/bash
set -euf

BACKUP_CMD=""
if test $# -gt 0; then
    BACKUP_CMD="$1"
fi

(
    if ! flock -x -w "$FLOCK_WAIT" 200 ; then
        echo 'ERROR: Could not obtain lock. Exiting.'
        exit 1
    fi

    # Run pre-backup scripts
    for f in /scripts/backup/before/*; do
        if [ -f "$f" ] && [ -x "$f" ]; then
            bash "$f"
        fi
    done

    # Intentionally not wrapping BACKUP_CMD and OPT_ARGUMENTS
    # shellcheck disable=SC2086
    duplicity \
        $BACKUP_CMD \
        --asynchronous-upload \
        --log-file /root/duplicity.log \
        --name "$BACKUP_NAME" \
        $OPT_ARGUMENTS \
        "$PATH_TO_BACKUP" \
        "$BACKUP_DEST"

    if [ -n "$CLEANUP_COMMAND" ]; then
        # Intentionally not wrapping CLEANUP_COMMAND
        # shellcheck disable=SC2086
        duplicity $CLEANUP_COMMAND \
            --log-file /root/duplicity.log \
            --name "$BACKUP_NAME" \
            "$BACKUP_DEST"
    fi

    # Run post-backup scripts
    for f in /scripts/backup/after/*; do
        if [ -f "$f" ] && [ -x "$f" ]; then
            bash "$f"
        fi
    done

) 200>/var/lock/duplicity/.duplicity.lock
