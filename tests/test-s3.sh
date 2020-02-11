#! /bin/bash

export DOCKER_IMAGE="$1"
docker-compose -f docker-compose-test-s3.yml up \
    --build --abort-on-container-exit --force-recreate
