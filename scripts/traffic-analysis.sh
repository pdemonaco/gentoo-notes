#!/bin/bash
TARGET=96.27.16.1
FILE="/tmp/ping.dat"

# Run the ping in the background
(ping -i .2 "${TARGET}" | egrep --line-buffered -v 'PING|timeout' | sed -u \
    -e 's/^.* time=\(.*\) ms$/\1/g' > "${FILE}") &

while true
do
    tail -n 300 "${FILE}" | gnuplot -e "set term dumb size 300,40; plot '-'"
    sleep 1
done
