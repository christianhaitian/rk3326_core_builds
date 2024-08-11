#!/bin/bash

# Adapted from AmberElec (https://github.com/AmberELEC/AmberELEC/raw/dev/packages/games/emulators/piemu/bin/piemu.sh)

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  sdl_controllerconfig="03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,leftstick:b8,lefttrigger:b10,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux,"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    sdl_controllerconfig="190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,back:b12,leftstick:b13,lefttrigger:b14,rightstick:b16,righttrigger:b15,start:b17,platform:Linux,"
  else
    sdl_controllerconfig="190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,back:b10,lefttrigger:b12,righttrigger:b13,start:b15,platform:Linux,"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000011000000010000,GO-Super Gamepad,x:b2,a:b1,b:b0,y:b3,back:b12,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b14,rightstick:b15,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000111000000010000,retrogame_joypad,a:b1,b:b0,x:b2,y:b3,back:b8,start:b9,rightstick:b12,leftstick:b11,dpleft:b15,dpdown:b14,dpright:b16,dpup:b13,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
else
  sdl_controllerconfig="19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,"
fi

ROMNAME="$1"
ROMFILE=${ROMNAME##*/}
EXTENSION="${ROMNAME##*.}"
BASEROMNAME=${ROMFILE//.${EXTENSION}}
GAMEFOLDER="${ROMNAME//${ROMFILE}}"
ROMS_DIR=$(dirname "$ROMNAME" | cut -d "/" -f2)
STATES_DIR="$GAMEFOLDER/states"
BIOS_DIR="/$ROMS_DIR/bios"
RUN_DIR="/dev/shm/piemu"

mkdir -p "$STATES_DIR"

rm -rf $RUN_DIR
mkdir -p $RUN_DIR

# Check whether it's a pfi or pex file

cd $RUN_DIR

if [[ "$EXTENSION" == "pfi" ]]; then
	cp $ROMNAME $RUN_DIR
	mv "$RUN_DIR/$ROMFILE" "piece.pfi"
fi

if [ ! -f "$BIOS_DIR/all.bin" ]; then
  for FILE in update120.exe update118.exe update114a.exe update114.exe update112a.exe update.exe; do
    if [ -f "$BIOS_DIR/$FILE" ]; then
      break;
    fi
  done
  if [ ! -f "$BIOS_DIR/$FILE" ]; then
    printf "\nCouldn't find a all.bin or update120.exe or update118.exe or update114a.exe\n" > /dev/tty1
	printf "or update114.exe or update112a.exe or update.exe in the bios folder\n" > /dev/tty1
    sleep 5
    printf "\033c" > /dev/tty1
    exit
  fi
  7z e "$BIOS_DIR/$FILE" -bd -aoa -o/dev/shm/piemu/
  if [ $? != 0 ]; then
    printf "\nCouldn't decompress $FILE\nSomething seems to be wrong with this file." > /dev/tty1
    sleep 5
    printf "\033c" > /dev/tty1
    exit
  fi
  BIOSFILE=`find /dev/shm/piemu/ -iname "all.bin" | tac | head -n 1`
  if [ -z "$BIOSFILE" ]; then
    printf "\nCouldn't find a valid bios file in the $FILE file found\n" > /dev/tty1
    sleep 5
    printf "\033c" > /dev/tty1
    exit
  fi
else
  BIOSFILE="$BIOS_DIR/all.bin"
fi

if [[ "$EXTENSION" == "pex" ]]; then
	if [[ -f "$GAMEFOLDER/$BASEROMNAME.pfs" ]]; then
		cd $GAMEFOLDER
		dos2unix "$GAMEFOLDER/$BASEROMNAME.pfs"
		cat "$GAMEFOLDER/$BASEROMNAME.pfs" | xargs -I % cp % $RUN_DIR
		cd $RUN_DIR
		/opt/piemu/mkpfi "$BIOSFILE"
		cat "$GAMEFOLDER/$BASEROMNAME.pfs" | xargs -I  % /opt/piemu/pfar piece.pfi -a %
	else
		cp $ROMNAME $RUN_DIR
		/opt/piemu/mkpfi "$BIOSFILE"
		/opt/piemu/pfar piece.pfi -a "$ROMFILE"
		if [[ -f "$GAMEFOLDER/$BASEROMNAME.sav" ]]; then
			cp "$GAMEFOLDER/$BASEROMNAME.sav" $RUN_DIR
			/opt/piemu/pfar piece.pfi -a "$ROMFILE.sav"
		fi
	fi
fi

if [[ "$EXTENSION" == "pfs" ]]; then
	cd $GAMEFOLDER
	xargs -a $ROMNAME cp -t $RUN_DIR
	cd $RUN_DIR
	/opt/piemu/mkpfi "$BIOSFILE"
	cat $ROMNAME | xargs -I  % /opt/piemu/pfar piece.pfi -a %
fi

sudo /usr/local/bin/piemukeydemon.py &

SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" /opt/piemu/piemu

if [ -d $RUN_DIR ]; then
  rm -rf $RUN_DIR
fi

sudo killall python3

sudo systemctl restart oga_events &

printf "\033c" > /dev/tty1
