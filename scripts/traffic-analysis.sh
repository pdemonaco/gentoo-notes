#!/bin/bash
TARGET=96.27.16.1
FILE="/tmp/ping.dat"

# Ping Parameters
INTERVAL=".2"

# Plot Parameters
PLOT_SAMPLES=300

# Run the ping in the background
(ping -i "${INTERVAL}" "${TARGET}" | egrep --line-buffered -v 'PING|timeout' | sed -u \
    -e 's/^.* time=\(.*\) ms$/\1/g' > "${FILE}") &

while true
do
    clear
    tail -n "${PLOT_SAMPLES}" "${FILE}" | \
        gnuplot -e "set term dumb size ${PLOT_SAMPLES},40; plot '-'"
    sleep 1
done
