#!/bin/bash

mkdir -p /var/run/dbus
mkdir -p /share/snapfifo
mkdir -p /share/snapcast

supervisord
