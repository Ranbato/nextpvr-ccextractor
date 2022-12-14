#!/usr/bin/env bash

# play nice with other processes
MYPID=$$
renice -n 19 -p $MYPID
ionice -c 3 -p $MYPID

# Explicitly check for Ubuntu update
docker pull ubuntu:jammy

#docker build -t marklambert/nextpvr-ccextractor:latest -t marklambert/nextpvr-ccextractor:$(date -I) .
docker build -t marklambert/nextpvr-ccextractor:local .

