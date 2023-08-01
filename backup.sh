#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
pushd /usr/src/app
pwd &>/proc/1/fd/1
export AWS_SECRET_ACCESS_KEY=$(jq -r '.["s3"].secretAccessKey' auth.json)
export AWS_ACCESS_KEY_ID=$(jq -r '.["s3"].accessKeyId' auth.json)
export S3_ENDPOINT=$(jq -r '.["s3"].endpoint' auth.json)

python3.10 download_temps.py &>/proc/1/fd/1
restic snapshots -r s3:$S3_ENDPOINT/temps-backup -p /tmp/restic_pass &>/proc/1/fd/1
ls -lh downloads_backup &>/proc/1/fd/1
RESTIC_COMPRESSION=max restic backup -r s3:$S3_ENDPOINT/temps-backup downloads_backup/* -p /tmp/restic_pass &>/proc/1/fd/1
restic prune -r s3:$S3_ENDPOINT/temps-backup -p /tmp/restic_pass &>/proc/1/fd/1

popd
