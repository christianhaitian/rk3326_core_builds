!/bin/bash

if  [[ $1 == "standalone" ]]; then
        if [ ".$(echo "$2"| cut -d. -f2)" == ".sh" ] || [ ".$(echo "$2"| cut -d. -f2)" == ".SH" ]; then
        "$2"
        else
        /opt/lzdoom/lzdoom -iwad "$2"
        fi
elif [ ".$(echo "$1"| cut -d. -f2)" == ".doom" ] || [ ".$(echo "$1"| cut -d. -f2)" == ".DOOM" ]; then
  IWAD=""; MODS=""; DEH=""; SAVE=""; CONF=""; PARAMS=""; DOOM_BASE_DIR="/roms/doom/"
  dos2unix "${1}"
  while IFS== read -r key value; do
    if [ "$key" == "IWAD" ]; then IWAD+=" ${DOOM_BASE_DIR}${value}"
    elif [ "$key" == "MOD" ]; then MODS+=" ${DOOM_BASE_DIR}${value}"
    elif [ "$key" == "CONF" ]; then CONF+=" ${DOOM_BASE_DIR}${value}"
    elif [ "$key" == "SAVE" ]; then SAVE+=" ${DOOM_BASE_DIR}${value}"
    elif [ "$key" == "DEH" ]; then DEH+=" ${DOOM_BASE_DIR}${value}"
    fi
  done < "${1}"
  if [ "$IWAD" ]; then PARAMS+=" -iwad ${IWAD:1}"; fi
  if [ "$MODS" ]; then PARAMS+=" -file ${MODS:1}"; fi
  if [ "$SAVE" ]; then PARAMS+=" -savedir ${SAVE:1}"; fi
  if [ "$CONF" ]; then PARAMS+=" -config ${CONF:1}"; fi
  if [ "$DEH" ]; then PARAMS+=" -deh ${DEH:1}"; fi
  /opt/lzdoom/lzdoom ${PARAMS:1} 2>&1 | tee -a ~/.emulationstation/last_launch.log
else
/usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi
