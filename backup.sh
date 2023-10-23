#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
source <(cat /proc/1/environ | tr '\0' '\n' | sed 's/^/export /')

pushd /usr/src/app
pwd &>/proc/1/fd/1

export AWS_SECRET_ACCESS_KEY=$(echo "$FOX_BACKUP_CONF" | base64 -d | jq -r '.["s3"].secretAccessKey')
export AWS_ACCESS_KEY_ID=$(echo "$FOX_BACKUP_CONF" | base64 -d | jq -r '.["s3"].accessKeyId')
export S3_ENDPOINT=$(echo "$FOX_BACKUP_CONF" | base64 -d | jq -r '.["s3"].endpoint')

TMP_PASS=$(mktemp)
echo "$RESTIC_S3_REPO_PASSWORD" > "$TMP_PASS"
python3 download_temps.py &>/proc/1/fd/1
echo "snapshots..." &>/proc/1/fd/1
timeout 30 restic snapshots -r s3:$S3_ENDPOINT/temps-backup -p "$TMP_PASS" &>/proc/1/fd/1
ls -lh downloads_backup &>/proc/1/fd/1
echo "backup..." &>/proc/1/fd/1
RESTIC_COMPRESSION=max timeout 30 restic backup -r s3:$S3_ENDPOINT/temps-backup downloads_backup/* -p "$TMP_PASS" &>/proc/1/fd/1
echo "prune..." &>/proc/1/fd/1
timeout 30 restic prune -r s3:$S3_ENDPOINT/temps-backup -p "$TMP_PASS" &>/proc/1/fd/1

rm "$TMP_PASS"

popd
