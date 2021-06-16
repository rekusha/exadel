#!/bin/bash
set -m
./task3mainproc.sh &
./task3helperproc.sh
fg %1
