#!/bin/bash

curspeed=$(cat /usr/local/bin/lightshow.sh | grep sleep | head -n1 | awk '{print $2}')
discorunning=$(pgrep lightshow.sh)

if [ $curspeed \< 1 ]; then
  if [ ! -z "$discorunning" ]; then
    newspeed=$(cat /usr/local/bin/lightshow.sh | grep sleep | head -n1 | awk '{print $2+0.1}')
    sudo sed -i "/sleep/c\       sleep $newspeed" /usr/local/bin/lightshow.sh
    sudo pkill lightshow.sh; lightshow.sh 8 &
  fi
fi
