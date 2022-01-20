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
  param_device="rg552"
else
  param_device="chi"
fi

directory=$(dirname "$2" | cut -d "/" -f2)

if [[ ! -f "/$directory/pico-8/sdl_controllers.txt" ]]; then
echo "19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,
190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,guide:b10,leftstick:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,
190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,
190000004b4800000011000000010000,GO-Super Gamepad,x:b2,a:b1,b:b0,y:b3,back:b12,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b14,rightstick:b15,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,
03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,guide:b7,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,leftx:a0~,lefty:a1~,start:b6,platform:Linux," > /$directory/pico-8/sdl_controllers.txt
fi

pico8executable=pico8_dyn
if [[ -f "/$directory/pico-8/pico8_64" ]]; then
  pico8executable=pico8_64
fi

if [[ ! -f "/$directory/pico-8/$pico8executable" ]]; then
      printf "\033c" >> /dev/tty1
      printf "\033[1;33m" >> /dev/tty1
      printf "\n I don't detect a pico8_dyn or pico8_64 file in the" >> /dev/tty1
      printf "\n /$directory/pico-8 folder.  Please place your purchased" >> /dev/tty1
      printf "\n pico-8 files in this location and try to launch your" >> /dev/tty1
      printf "\n cart again." >> /dev/tty1
      sleep 10
      printf "\033[0m" >> /dev/tty1
fi

basefile=$(basename -- $2)
basefilenoext=${basefile%.*}

sudo /opt/quitter/oga_controls $pico8executable $param_device &

if [[ $1 == "float-scaled" ]]; then
	if [[ ${basefilenoext,,} == "zzzsplore" ]]; then
		/$directory/pico-8/$pico8executable -splore -home /$directory/pico-8/ -root_path /$directory/pico-8/carts/ -joystick 0
	else
		/$directory/pico-8/$pico8executable -home /$directory/pico-8/ -root_path /$directory/pico-8/carts/ -joystick 0 -run "$2"
	fi
elif [[ $1 == "pixel-perfect" ]]; then
	if [[ ${basefilenoext,,} == "zzzsplore" ]]; then
		/$directory/pico-8/$pico8executable -splore -home /$directory/pico-8/ -root_path /$directory/pico-8/carts/ -joystick 0 -pixel_perfect 1
	else
		/$directory/pico-8/$pico8executable -home /$directory/pico-8/ -root_path /$directory/pico-8/carts/ -joystick 0 -pixel_perfect 1 -run "$2"
	fi
else
	if [[ ${basefilenoext,,} == "zzzsplore" ]]; then
		/$directory/pico-8/$pico8executable -splore -home /$directory/pico-8/ -root_path /$directory/pico-8/carts/ -joystick 0 -draw_rect 0,0,480,320
	else
		/$directory/pico-8/$pico8executable -home /$directory/pico-8/ -root_path /$directory/pico-8/carts/ -joystick 0 -draw_rect 0,0,480,320 -run "$2"
	fi
fi

if [[ ! -z $(pidof oga_controls) ]]; then
  sudo kill -9 $(pidof oga_controls)
fi
sudo systemctl restart oga_events &

mv -f /$directory/pico-8/bbs/carts/*.png /$directory/pico-8/carts/
mv -f /$directory/pico-8/bbs/carts/*.PNG /$directory/pico-8/carts/
mv -f /$directory/pico-8/bbs/carts/*.p8 /$directory/pico-8/carts/
mv -f /$directory/pico-8/bbs/carts/*.P8 /$directory/pico-8/carts/
