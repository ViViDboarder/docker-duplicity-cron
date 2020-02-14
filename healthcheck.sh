#! /bin/bash

HEALTH_FILE=/unhealthy

if [ -f "$HEALTH_FILE" ]; then
    exit 1
else
    exit 0
fi
