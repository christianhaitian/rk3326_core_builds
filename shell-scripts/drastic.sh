#!/bin/bash

directory="$(dirname "$1" | cut -d "/" -f2)"

if  [[ ! -d "/${directory}/nds/backup" ]]; then
  mkdir /${directory}/nds/backup
fi
if  [[ ! -d "/${directory}/nds/cheats" ]]; then
  mkdir /${directory}/nds/cheats
fi
if  [[ ! -d "/${directory}/nds/savestates" ]]; then
  mkdir /${directory}/nds/savestates
fi
if  [[ ! -d "/${directory}/nds/slot2" ]]; then
  mkdir /${directory}/nds/slot2
fi

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  param_device="anbernic"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    param_device="oga"
  else
    param_device="rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  param_device="ogs"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  param_device="rg503"
else
  param_device="chi"
fi

sudo /opt/quitter/oga_controls drastic $param_device &
cd /opt/drastic
./drastic "$1"
if [[ ! -z $(pidof oga_controls) ]]; then
  sudo kill -9 $(pidof oga_controls)
fi
sudo systemctl restart oga_events &
