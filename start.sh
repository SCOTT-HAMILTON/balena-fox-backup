#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
fcrontab -l &>/proc/1/fd/1
fcrontab -l &>1
fcron -f &>/proc/1/fd/1
