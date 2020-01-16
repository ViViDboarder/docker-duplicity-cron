FROM vividboarder/docker-duplicity-cron
MAINTAINER ViViDboarder <vividboarder@gmail.com>

# Install SQLite
RUN apt-get update \
        && apt-get install -y --no-install-recommends sqlite3 \
        && apt-get clean \
        && rm -rf /var/apt/lists/*

# Copy SQLite backup scripts
COPY ./backup /scripts/backup
COPY ./restore /scripts/restore

# Env that points to sqlite db
ENV DB_PATH /data/db.sqlite3
