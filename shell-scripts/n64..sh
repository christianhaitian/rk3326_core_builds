#!/bin/bash

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
	  RES="480x320"
      if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
        RES="640x480"
      fi
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
	  RES="480x320"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
	  RES="640x480"
elif [[ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]]; then
	  RES="640x480"
else
	  RES="640x480"
fi

if [[ $1 == "standalone-Rice" ]]; then
  /opt/mupen64plus/mupen64plus --resolution $RES --plugindir /opt/mupen64plus --gfx mupen64plus-video-rice.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$2"
elif [[ $1 == "standalone-Glide64mk2" ]]; then
  /opt/mupen64plus/mupen64plus --resolution $RES --plugindir /opt/mupen64plus --gfx mupen64plus-video-glide64mk2.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$2"
else
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi

