#!/bin/bash
##################################################################
# Created by Christian Haitian and EnsignRutherford              #
##################################################################

EMULATOR=$1
CORE=$2
GAME="$3"

# We'll get the root folder here so we can pass that info to the xroar executable for locating bios rom files
directory=$(dirname "$GAME" | cut -d "/" -f2)
# The next 2 variables are for use with custom game controls if the user creates some
gamecontrols=$(echo "$(ls "$GAME" | cut -d "/" -f4 | cut -d "." -f1)")
custom_gamecontrols_nocase=$(find "/$directory/dragon/controls" -maxdepth 1 -iname "${gamecontrols}".gptk)
alt_default_controls=$(find "/$directory/dragon/controls" -maxdepth 1 -iname xroar.gptk)
# The next variable is for getting the extension of the game file
ext="${GAME##*.}"

# The next 3 lines below are for preparing the environment so the keyboard/mouse emulator can successfully launch
sudo chmod 666 /dev/tty1
sudo chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"

# This guard is here because there's a weird issue with the latest SDL2 that makes the odroid go advance type units controls look weird
# So we'll use an available older sdl2 just for the keyboard/mouse emulator if need be.
if [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  PRELOAD="/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.18.2"
else
  PRELOAD=""
fi

# This guard is specifically for the Chi to change the exit hotkey to be 1 and Start as other emulators and tools are for that unit
if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]] || [[ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]]; then
  export HOTKEY="l3"
fi

# Here we can load custom game controls instead of the default controls.
# Users can create their own mappings for each game.
# Just create a controls subfolder within the roms/coco3 (roms2/coco3 for 2 sd card setups)
# folder and create a text file named exactly similar to game name but with a .gptk extension.
# See https://raw.githubusercontent.com/christianhaitian/arkos/main/mvem%20pics/mvem.gptk
# for an example of how to setup the structure of this file.
# Unused gamepad keys should be commented out with \" like the start key is in the example .gptk
# file linked in the previous sentence.
# To enable keyboard mode for the emulator, insert #keyboard mode at the top of the file
# To enable mouse mode, insert #mouse mode at the top of the file
if [ -f "$custom_gamecontrols_nocase" ]; then
  #echo "Loading custom user controls from $custom_gamecontrols_nocase" >> /dev/tty1
  LD_PRELOAD=${PRELOAD} /opt/inttools/gptokeyb -1 "xroar" -c "$custom_gamecontrols_nocase" &
  if [[ "$(cat "$custom_gamecontrols_nocase")" == *"#keyboard mode"* ]]; then
    params="-joy-left kjoy0"
  elif [[ "$(cat "$custom_gamecontrols_nocase")" == *"#mouse mode"* ]]; then
    params="-joy-left mjoy0"
  else
    params="-joy-left joy0"
  fi
elif [ -f "$alt_default_controls" ]; then
  #echo "Loading alternate default controls from $alt_default_controls" >> /dev/tty1
  LD_PRELOAD=${PRELOAD} /opt/inttools/gptokeyb -1 "xroar" -c "$alt_default_controls" &
  params="-joy-left joy0"
else
  #echo "Loading default controls /opt/xroar/controls/xroar.gptk" >> /dev/tty1
  LD_PRELOAD=${PRELOAD} /opt/inttools/gptokeyb -1 "xroar" -c "/opt/xroar/controls/xroar.gptk" &
  params="-joy-left joy0"
fi

# The joystick is inverted for the gameforce chi.  That is accounted for here
if [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
  params="$params -joy joy0 -joy-axis X=physical:1 -joy-axis Y=physical:0"
fi

# The standalone xroar emulator doesn't support zip files.  We'll take care of that here
if [[ "${ext,,}" == "zip" ]]; then
  if [ ! -d "/dev/shm/dragonroms" ]; then
    mkdir -p /dev/shm/dragonroms
  else
    rm -rf /dev/shm/dragonroms/*
  fi
  # 'GAME' will be updated with the file that is found in the zip archive
  ROM="$GAME"
  unzip -qq -o "$ROM" -d /dev/shm/dragonroms/
  for CART in cas ccc dsk rom; do
    GAME=`find /dev/shm/dragonroms/ -iname "*.${CART}" | tac | head -n 1`
    ext="${GAME##*.}"
    if [ ! -z "$GAME" ]; then
      break;
    fi
  done
  if [ -z "$GAME" ]; then
    printf "\nCouldn't find a compatible cartridge or type .cas, .ccc, .dsk or .rom from $ROM\n" > /dev/tty1
    sleep 5
    exit
  fi
fi

# GAME contains the location of the game and ext contains the extension of the game
if [[ "${ext,,}" == "dsk" ]]; then
  # for dsk images the name of the binary or BASIC file must match the dsk image name,
  # e.g. BANDIT.DSK and on the disk image there must be a BANDIT.BIN or BANDIT.BAS
  gamename=$(basename "${GAME^^}" .DSK)
  cmd="-load"
  type="-type LOADM\"${gamename}\":EXEC\rRUN\"${gamename}\"\rDOS\r"
else
  # No file with a .zip extension is detected so we can just pass the file directly to xroar and run it
  # We're now ready to try and run the game
  cmd="-run"
  type=""
fi

# Now run the game
/opt/xroar/xroar -vo-picture title -rompath /$directory/bios -machine $CORE -tv-input cmp-br -ram 2048 ${cmd} "$GAME" ${params} ${type}
#/opt/xroar/xroar -ccr partial -vo-picture title -rompath /$directory/bios -machine $CORE -tv-input cmp-br -ram 2048 ${cmd} "$GAME" ${params} ${type}

# Done running the game.  Time to clean up the temp memory space if needed.
printf "\033c" >> /dev/tty1

if [ -d "/dev/shm/dragonroms" ]; then
  rm -rf /dev/shm/dragonroms/*
fi

# Let us unset the SDL Gamecontroller config file in the environment and make to to kill gptokeyb if it is still running somehow.
unset SDL_GAMECONTROLLERCONFIG_FILE
if [[ ! -z $(pidof gptokeyb) ]]; then
  sudo kill -9 $(pidof gptokeyb)
fi

# Make sure the hotkey daemon is still fine, clean up the screen buffer, then we outta here!
sudo systemctl restart oga_events &
printf "\033c" >> /dev/tty1
exit 0
