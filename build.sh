#!/usr/bin/env bash

# play nice with other processes
MYPID=$$
renice -n 19 -p $MYPID
ionice -c 3 -p $MYPID

# Explicitly check for update because the Dockerfile doesn't
docker pull nextpvr/nextpvr_amd64:stable

#docker build -t marklambert/nextpvr-ccextractor:latest -t marklambert/nextpvr-ccextractor:$(date -I) .
docker build --progress plain -t marklambert/nextpvr-ccextractor:local .

