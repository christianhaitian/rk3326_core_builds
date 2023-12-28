#!/bin/bash

#
# This fix should allow ScummVM games to launch from a root .scummvm file and not from a subfolder
#
# This now makes the requirement that the .scummvm file has the same name as the folder the game is stored in
# and this will work without the subfolders.  This also works if the .scummvm file is within the folder
#
# Thanks to EnsignRutherford for this fix. (https://github.com/christianhaitian/arkos/issues/858)
#
fbname=$(basename "$2" .scummvm)
fbdir=$(dirname "$2")
if [ -d "$fbdir/$fbname" ]; then
   game=$(dirname "$2")/"$fbname"/"$(basename "$2")"
   set -- "$1" "$game" "$3"
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
  cd /opt/scummvm
  sudo /usr/local/bin/scummvmkeydemon.py &
  DIR="$( cd "$( dirname "${2}" )" >/dev/null 2>&1 && pwd )/"
  ./scummvm --auto-detect --path="$DIR"
  sudo killall python3
  sudo systemctl restart oga_events &
elif [[ $1 == "standalone" ]] && [[ ${2,,} == *"menu.scummvm"* ]]
then
  cd /opt/scummvm
  sudo /usr/local/bin/scummvmkeydemon.py &
  ./scummvm
  sudo killall python3
  sudo systemctl restart oga_events &
else
  if  [[ ${3,,} == *"menu.scummvm"* ]]
  then
      /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so
  else
      /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
  fi
fi
