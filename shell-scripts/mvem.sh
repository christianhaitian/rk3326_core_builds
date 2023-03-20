#!/bin/bash

res="480x320x1"
if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
    res="640x480x1"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  res="854x480x1"
  if [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
    res="640x480x1"
  fi
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  xres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)"
  yres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f2)"
  res="${xres}x${yres}x1"
else
  param_device="chi"
  res="640x480x1"
fi

directory="$(dirname "$1" | cut -d "/" -f2)"
gamecontrols=$(echo "$(ls "$1" | cut -d "/" -f4 | cut -d "." -f1)")

cd /opt/mvem

sudo chmod 666 /dev/uinput

export SDL_GAMECONTROLLERCONFIG_FILE="controls/gamecontrollerdb.txt"

if [ -f "/$directory/mv/controls/${gamecontrols}.gptk" ]; then
  echo "Loading custom user controls from /$directory/mv/controls/${gamecontrols}.gptk"
  ./gptokeyb -1 "mvem" -c "/$directory/mv/controls/${gamecontrols}.gptk" &
elif [ -f "/opt/mvem/controls/${gamecontrols}.gptk" ]; then
  echo "Loading provided controls from /opt/mvem/controls/${gamecontrols}.gptk"
  ./gptokeyb -1 "mvem" -c "/opt/mvem/controls/${gamecontrols}.gptk" &
else
  echo "Loading default controls /opt/mvem/controls/mvem.gptk"
  ./gptokeyb -1 "mvem" -c "/opt/mvem/controls/mvem.gptk" &
fi

./mvem "$1" "$res"

unset SDL_GAMECONTROLLERCONFIG_FILE
if [[ ! -z $(pidof gptokeyb) ]]; then
  sudo kill -9 $(pidof gptokeyb)
fi
sudo systemctl restart oga_events &
printf "\033c" >> /dev/tty1
exit 0
