#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
source <(cat /proc/1/environ | tr '\0' '\n' | sed 's/^/export /')

pushd /usr/src/app
pwd &>/proc/1/fd/1
ls -lh &>/proc/1/fd/1
PYTHONPATH=/usr/lib/python3.11/site-packages python3 push_temps.py  &>/proc/1/fd/1
popd
