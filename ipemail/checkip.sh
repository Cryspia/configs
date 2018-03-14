#!/bin/bash

IPFILE=previousip.txt
INTERVAL=10m

if [ ! -f "$IPFILE" ]; then
    touch "$IPFILE"
fi

while true
do
    pIP=$(cat "$IPFILE")
    nIP=$(curl -s ipinfo.io/ip)
    if [ ! -z "$nIP" ]; then
        if [ "$pIP" != "$nIP" ]; then
            python3 sendemail.py -h "New IP" -t "$nIP" &
        fi
        echo "$nIP" > "$IPFILE"
    fi
    sleep $INTERVAL
done
