#!/bin/bash
if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  sdl_controllerconfig="03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,leftstick:b8,lefttrigger:b10,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux,"
  deadzone="32767"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    sdl_controllerconfig="190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,back:b12,leftstick:b13,lefttrigger:b14,rightstick:b16,righttrigger:b15,start:b17,platform:Linux,"
  else
    sdl_controllerconfig="190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,back:b10,lefttrigger:b12,righttrigger:b13,start:b15,platform:Linux,"
  fi
  deadzone="32100"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000011000000010000,GO-Super Gamepad,x:b2,a:b1,b:b0,y:b3,back:b12,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b14,rightstick:b15,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
  deadzone="32767"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000111000000010000,retrogame_joypad,a:b1,b:b0,x:b2,y:b3,back:b8,start:b9,rightstick:b12,leftstick:b11,dpleft:b15,dpdown:b14,dpright:b16,dpup:b13,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
  deadzone="32767"
else
  sdl_controllerconfig="19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,"
  deadzone="32100"
fi
sudo systemctl start solarushotkey
rm -rf ~/.solarus
directory=$(dirname "$1" | cut -d "/" -f2)
if [[ -d "/$directory/solarus/.solarus" ]]; then
  mv /$directory/solarus/.solarus /$directory/solarus/.saves
fi
if [[ ! -d "/$directory/solarus/.saves" ]]; then
  mkdir /$directory/solarus/.saves
fi
ln -s /$directory/solarus/.saves /home/ark/.solarus
cd /opt/solarus/
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" /opt/solarus/solarus-run -fullscreen=yes -joypad-deadzone=$deadzone "$1"
sudo systemctl stop solarushotkey
