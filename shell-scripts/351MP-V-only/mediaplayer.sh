#!/bin/bash

sudo /usr/local/bin/oga_controls &
ffplay -loglevel +quiet -seek_interval 1 -loop 0 -x 640 -y 480 "$1"
sudo kill $(pidof oga_controls)
printf "\033c" >> /dev/tty1
