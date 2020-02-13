ARG REPO=library
FROM multiarch/qemu-user-static:4.1.0-1 AS qemu
FROM ${REPO}/ubuntu:eoan
LABEL maintainer="ViViDboarder <vividboarder@gmail.com>"
LABEL duplicity-version=0.8.04

# Allow building/running non-amd64 images from amd64
COPY --from=qemu /usr/bin/qemu-* /usr/bin/

RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            cron=3.0pl1-134ubuntu1 \
            duplicity=0.8.04-2ubuntu1 \
            # duplicity recommended
            python3-oauthlib=2.1.0-1 \
            python3-paramiko=2.6.0-1 \
            python3-pexpect=4.6.0-1 \
            python3-urllib3=1.24.1-1ubuntu1 \
            rsync=3.1.3-6 \
            # duplicity suggests
            lftp=4.8.4-2build2 \
            ncftp=2:3.2.5-2.1 \
            par2=0.8.0-1 \
            python3-boto=2.49.0-2ubuntu1 \
            python3-swiftclient=1:3.8.1-0ubuntu1 \
            python3-pip=18.1-5 \
            # tahoe-lafs \ # This depends on Python 2 and is left out for now
        && pip3 install --no-cache-dir b2==1.4.2 \
        && apt-get autoremove -y python3-pip \
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
