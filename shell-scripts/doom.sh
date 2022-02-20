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

if [[ $1 == "standalone" ]]; then
        directory=$(dirname "$2" | cut -d "/" -f2)
        sudo /opt/quitter/oga_controls lzdoom $param_device &
	if [ ".$(echo "$2"| cut -d. -f2)" == ".sh" ] || [ ".$(echo "$2"| cut -d. -f2)" == ".SH" ]; then
	"$2"
	elif [ ".$(echo "$2"| cut -d. -f2)" == ".doom" ] || [ ".$(echo "$2"| cut -d. -f2)" == ".DOOM" ]; then
	  IWAD=""; MODS=""; DEH=""; SAVE=""; CONF=""; PARAMS=""; DOOM_BASE_DIR="/$directory/doom/"
	  dos2unix "${2}"
	  while IFS== read -r key value; do
	    if [ "$key" == "IWAD" ]; then IWAD+=" ${DOOM_BASE_DIR}${value}"
	    elif [ "$key" == "MOD" ]; then MODS+=" ${DOOM_BASE_DIR}${value}"
	    elif [ "$key" == "CONF" ]; then CONF+=" ${DOOM_BASE_DIR}${value}"
	    elif [ "$key" == "SAVE" ]; then SAVE+=" ${DOOM_BASE_DIR}${value}"
	    elif [ "$key" == "DEH" ]; then DEH+=" ${DOOM_BASE_DIR}${value}"
	    fi
	  done < "${2}"
	  if [ "$IWAD" ]; then PARAMS+=" -iwad ${IWAD:1}"; fi
	  if [ "$MODS" ]; then PARAMS+=" -file ${MODS:1}"; fi
	  if [ "$SAVE" ]; then PARAMS+=" -savedir ${SAVE:1}"; fi
	  if [ "$CONF" ]; then PARAMS+=" -config ${CONF:1}"; fi
	  if [ "$DEH" ]; then PARAMS+=" -deh ${DEH:1}"; fi
	  /opt/lzdoom/lzdoom ${PARAMS:1}
	else
	/opt/lzdoom/lzdoom -iwad "$2"
	fi
        if [[ ! -z $(pidof oga_controls) ]]; then
          sudo kill -9 $(pidof oga_controls)
        fi
        sudo systemctl restart oga_events &
elif [[ $1 == "standalone-gzdoom" ]]; then
        directory=$(dirname "$2" | cut -d "/" -f2)
        sudo /opt/quitter/oga_controls gzdoom $param_device &
        if [ ".$(echo "$2"| cut -d. -f2)" == ".sh" ] || [ ".$(echo "$2"| cut -d. -f2)" == ".SH" ]; then
        "$2"
        elif [ ".$(echo "$2"| cut -d. -f2)" == ".doom" ] || [ ".$(echo "$2"| cut -d. -f2)" == ".DOOM" ]; then
          IWAD=""; MODS=""; DEH=""; SAVE=""; CONF=""; PARAMS=""; DOOM_BASE_DIR="/$directory/doom/"
          dos2unix "${2}"
          while IFS== read -r key value; do
            if [ "$key" == "IWAD" ]; then IWAD+=" ${DOOM_BASE_DIR}${value}"
            elif [ "$key" == "MOD" ]; then MODS+=" ${DOOM_BASE_DIR}${value}"
            elif [ "$key" == "CONF" ]; then CONF+=" ${DOOM_BASE_DIR}${value}"
            elif [ "$key" == "SAVE" ]; then SAVE+=" ${DOOM_BASE_DIR}${value}"
            elif [ "$key" == "DEH" ]; then DEH+=" ${DOOM_BASE_DIR}${value}"
            fi
          done < "${2}"
          if [ "$IWAD" ]; then PARAMS+=" -iwad ${IWAD:1}"; fi
          if [ "$MODS" ]; then PARAMS+=" -file ${MODS:1}"; fi
          if [ "$SAVE" ]; then PARAMS+=" -savedir ${SAVE:1}"; fi
          if [ "$CONF" ]; then PARAMS+=" -config ${CONF:1}"; fi
          if [ "$DEH" ]; then PARAMS+=" -deh ${DEH:1}"; fi
          /opt/gzdoom/gzdoom ${PARAMS:1} +gl_es 1 +vid_preferbackend 3 +cl_capfps 0
        else
        /opt/gzdoom/gzdoom -iwad "$2" +gl_es 1 +vid_preferbackend 3 +cl_capfps 0
        fi
        if [[ ! -z $(pidof oga_controls) ]]; then
          sudo kill -9 $(pidof oga_controls)
        fi
        sudo systemctl restart oga_events &
else
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi
