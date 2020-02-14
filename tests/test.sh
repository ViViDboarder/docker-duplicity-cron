#! /bin/bash
set -euf


if [ -z "${IN_CONTAINER+x}" ] ; then
    # Run the test script within the container
    image="$1"
    docker run --rm \
        -e IN_CONTAINER=true \
        -e SKIP_ON_START=true \
        -v "$(pwd)/test.sh:/test.sh" \
        "$image" \
        bash -c "/test.sh"
else
    # Optionally sleep at beginning for compose tests that may need it
    sleep "${SLEEP:-0}"

    echo "Performing backup tests"

    echo "Verify cron and crontab exist"
    type cron
    type crontab

    echo "Create test data..."
    mkdir -p /data && echo Test > /data/test.txt

    echo "Making backup..."
    /cron-exec.sh /backup.sh || { cat /cron.log && exit 1; }

    echo "Verify backup..."
    /cron-exec.sh /verify.sh || { cat /cron.log && exit 1; }

    echo "Delete test data..."
    rm -fr /data/test.txt

    echo "Verify deleted..."
    test -f /data/test.txt && exit 1 || echo "Gone"

    echo "Restore backup..."
    /cron-exec.sh /restore.sh || { cat /cron.log && exit 1; }
    /healthcheck.sh || { cat /cron.log && exit 1; }

    echo "Verify restore..."
    test -f /data/test.txt
    cat /data/test.txt

    echo "Verify backup..."
    /cron-exec.sh /verify.sh || { cat /cron.log && exit 1; }

    echo "Delete test data again..."
    rm -fr /data/test.txt

    echo "Verify deleted..."
    test -f /data/test.txt && exit 1 || echo "Gone"

    echo "Simulate a restart with RESTORE_ON_EMPTY_START..."
    RESTORE_ON_EMPTY_START=true /start.sh || { cat /cron.log && exit 1; }
    /healthcheck.sh || { cat /cron.log && exit 1; }

    echo "Verify restore happened..."
    test -f /data/test.txt
    cat /data/test.txt

    echo "Verify restore with incorrect passphrase fails..."
    echo "Fail to restore backup..."
    PASSPHRASE=Incorrect.Mule.Solar.Paperclip /cron-exec.sh /restore.sh && exit 1 || echo "OK"

    echo "Verify failed healthcheck"
    /healthcheck.sh && exit 1 || echo "OK"
fi
