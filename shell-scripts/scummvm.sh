#!/bin/bash

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

directory="$(dirname "$2" | cut -d "/" -f2)"

if [[ $2 == *"Scan_for_new_games.scummvm"* ]]
then
  printf "\033c" >> /dev/tty1
  cd /${directory}/scummvm
  ./Scan_for_new_games.scummvm standalone "$2"
  printf "\n\nFinished scanning the scummvm folder for games." >> /dev/tty1
  printf "\nPlease restart emulationstaton to find the new shortcuts" >> /dev/tty1
  printf "\ncreated if any.\n" >> /dev/tty1
  sleep 5
  printf "\033c" >> /dev/tty1
elif [[ $1 == "standalone" ]] && [[ ${2,,} != *"menu.scummvm"* ]]
then
  sudo /opt/quitter/oga_controls scummvm $param_device &
  cd /opt/scummvm
  DIR="$( cd "$( dirname "${2}" )" >/dev/null 2>&1 && pwd )/"
  ./scummvm --auto-detect --path="$DIR"
  if [[ ! -z $(pidof oga_controls) ]]; then
    sudo kill -9 $(pidof oga_controls)
  fi
  sudo systemctl restart oga_events &
elif [[ $1 == "standalone" ]] && [[ ${2,,} == *"menu.scummvm"* ]]
then
  sudo /opt/quitter/oga_controls scummvm $param_device &
  cd /opt/scummvm
  ./scummvm
  if [[ ! -z $(pidof oga_controls) ]]; then
    sudo kill -9 $(pidof oga_controls)
  fi
  sudo systemctl restart oga_events &
else
  if  [[ ${3,,} == *"menu.scummvm"* ]]
  then
      /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so
  else
      /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
  fi
fi

