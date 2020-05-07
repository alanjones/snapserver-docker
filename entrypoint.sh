#!/bin/bash

mkdir -p /share/snapfifo
mkdir -p /share/snapcast

/usr/local/bin/librespot -v -n "Whole Home Audio" --backend pipe --device /share/snapfifo/librespot
/usr/bin/snapserver -c /share/snapcast/snapserver.conf

