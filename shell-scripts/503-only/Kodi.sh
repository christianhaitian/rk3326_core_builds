#!/bin/bash

export KODI_HOME=/opt/kodi/share
#export PYTHONHOME=/usr/bin
#export PYTHONPATH=/usr/lib/python2.7

printf "\n\n\e[32mStarting Kodi.  Please wait..."
export LD_LIBRARY_PATH=/opt/kodi/libs/:/opt/kodi/libs/samba

if [[ ! -d "/home/ark/.kodi" ]]; then
  mkdir /home/ark/.kodi
  cp -R /opt/kodi/userdata/ /home/ark/.kodi/
fi

sudo /opt/quitter/oga_controls kodi.bin rg503 &

/opt/kodi/kodi.bin

if [[ ! -z $(pidof oga_controls) ]]; then
  sudo kill -9 $(pidof oga_controls)
fi
sudo systemctl restart oga_events &
