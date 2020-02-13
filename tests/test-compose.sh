#! /bin/bash

export COMPOSE_FILE="docker-compose-test-$1.yml"
export DOCKER_IMAGE="$2"
docker-compose -f "$COMPOSE_FILE" up \
    --build --abort-on-container-exit --force-recreate
