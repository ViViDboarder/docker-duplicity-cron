ARG REPO=library
FROM multiarch/qemu-user-static:4.1.0-1 AS qemu
FROM ${REPO}/ubuntu:eoan
LABEL maintainer="ViViDboarder <vividboarder@gmail.com>"

# Allow building/running non-amd64 images from amd64
COPY --from=qemu /usr/bin/qemu-* /usr/bin/

RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            cron \
            duplicity \
            # duplicity recommended
            python3-oauthlib \
            python3-paramiko \
            python3-pexpect \
            python3-urllib3 \
            rsync \
            # duplicity suggests
            lftp \
            ncftp \
            par2 \
            python3-boto \
            python3-swiftclient \
            # tahoe-lafs \ # This depends on Python 2 and is left out for now
        && apt-get clean \
        && rm -rf /var/apt/lists/*

VOLUME /root/.cache/duplicity
VOLUME /backups
VOLUME /var/lock/duplicity

ENV BACKUP_DEST="file:///backups"
ENV BACKUP_NAME="backup"
ENV PATH_TO_BACKUP="/data"
ENV PASSPHRASE="Correct.Horse.Battery.Staple"
ENV FLOCK_WAIT=60

# Cron schedules
ENV CRON_SCHEDULE=""
ENV FULL_CRON_SCHEDULE=""
ENV VERIFY_CRON_SCHEDULE=""

# Create script dirs
RUN mkdir -p /scripts/backup/before
RUN mkdir -p /scripts/backup/after
RUN mkdir -p /scripts/restore/before
RUN mkdir -p /scripts/restore/after

COPY backup.sh /
COPY restore.sh /
COPY start.sh /
COPY verify.sh /
COPY healthcheck.sh /
COPY cron-exec.sh /

HEALTHCHECK CMD /healthcheck.sh

CMD [ "/start.sh" ]
