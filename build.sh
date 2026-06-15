#!/usr/bin/env bash

# play nice with other processes
MYPID=$$
renice -n 19 -p $MYPID
ionice -c 3 -p $MYPID

if [ -d "FFmpeg-Builds" ]; then
	echo "FFmpeg-Builds exists — updating..."
	git -C FFmpeg-Builds fetch --depth 1 origin master
	git -C FFmpeg-Builds checkout master
	git -C FFmpeg-Builds reset --hard origin/master
else
	echo "Cloning FFmpeg-Builds..."
	git clone https://github.com/BtbN/FFmpeg-Builds.git --depth 1 --branch master --single-branch
fi
# ./FFmpeg-Builds/makeimage.sh linux64 nonfree 8.1 
./FFmpeg-Builds/build.sh linux64 nonfree 8.1 
mkdir -p temp
tar -xvf FFmpeg-Builds/artifacts/ffmpeg-n8.1.*.tar.xz -C temp --wildcards --strip-components=1 '*/bin/*'

# Explicitly check for update because the Dockerfile doesn't
docker pull nextpvr/nextpvr_amd64:stable

#docker build -t marklambert/nextpvr-ccextractor:latest -t marklambert/nextpvr-ccextractor:$(date -I) .
docker build -t nas:5000/marklambert/nextpvr-ccextractor:local -t nas:5000/marklambert/nextpvr-ccextractor:$(date -I) .
docker push nas:5000/marklambert/nextpvr-ccextractor:local
docker push nas:5000/marklambert/nextpvr-ccextractor:$(date -I)
