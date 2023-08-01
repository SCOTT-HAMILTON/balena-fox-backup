#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
echo $RESTIC_S3_REPO_PASSWORD>/tmp/restic_pass
fcrontab -l &>/proc/1/fd/1
fcrontab -l &>1
fcron -f -d &>/proc/1/fd/1
