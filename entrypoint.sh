#!/bin/bash

mkdir -p /share/snapfifo
mkdir -p /share/snapcast

/usr/bin/snapserver -c /share/snapcast/snapserver.conf

