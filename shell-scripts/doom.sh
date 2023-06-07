#!/bin/bash

if [[ $1 == "standalone" ]]; then
        directory=$(dirname "$2" | cut -d "/" -f2)
	sudo /usr/local/bin/doomkeydemon.py &
	if [ ".$(echo "$2"| cut -d. -f2)" == ".sh" ] || [ ".$(echo "$2"| cut -d. -f2)" == ".SH" ]; then
	dos2unix "${2}"
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
	sudo killall python3
        sudo systemctl restart oga_events &
elif [[ $1 == "standalone-gzdoom" ]]; then
        directory=$(dirname "$2" | cut -d "/" -f2)
	sudo /usr/local/bin/doomkeydemon.py &
        if [ ".$(echo "$2"| cut -d. -f2)" == ".sh" ] || [ ".$(echo "$2"| cut -d. -f2)" == ".SH" ]; then
        dos2unix "${2}"
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
	sudo killall python3
        sudo systemctl restart oga_events &
else
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi

