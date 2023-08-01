#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
pushd /usr/src/app
pwd &>/proc/1/fd/1
ls -lh &>/proc/1/fd/1
python3.10 push_temps.py  &>/proc/1/fd/1
popd
