#! /bin/bash

docker-compose up -d
docker-compose exec duplicity sh -c "mkdir -p /data && echo Test > /data/test.txt"
docker-compose down
docker-compose up
docker volumes rm duplicity-test-data
docker-compose up -d
docker-compose exec duplicity /restore.sh
