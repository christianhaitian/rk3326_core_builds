#!/bin/bash

if [[ -z ${@} ]]; then
  printf "\nNo valid argument provided such as pico8, retroarch or retroarch32\n\n"
  exit 1
fi

if [[ ${@} == "pico8" ]]; then
  filename="$2"
  ext="${filename##*.}"
  Directory=`grep pico-8 /etc/emulationstation/es_systems.cfg | head -1 | grep -oP '(?<path>/).*?(?=/pico-8)' | cut -c2-`
  if [[ ! -e /dev/shm/Splore_Loaded ]]; then
    Last_Game=`tac /${Directory}/pico-8/activity_log.txt | grep -m1 "${ext}" | grep -oP '(?<= /).*'`
    Last_Game_Name=`tac /${Directory}/pico-8/activity_log.txt | grep -m1 "${ext}" | grep -oP '(?<= /).*' | awk 'BEGIN {FS="/" } { print $4 }'`
    Last_Game_Name_Noext=`echo "$Last_Game_Name" | rev | cut -d"." -f2-8  | rev`
    if [ -f "/home/ark/.emulationstation/recovery/PICO-8/"$Last_Game_Name_Noext".xml" ]; then
      Last_Emulator=`sed -n "/$Last_Game_Name/{n;n;p}" /home/ark/.emulationstation/recovery/PICO-8/"$Last_Game_Name_Noext".xml | grep "<emulator>" |  grep -oP '(?<=>).*?(?=<)'`
    fi
    if [[ -z ${Last_Emulator} ]]; then
      Last_Emulator=`sed -n "/$Last_Game_Name/{n;n;p}" /${Directory}/pico-8/carts/gamelist.xml | grep "<emulator>" |  grep -oP '(?<=>).*?(?=<)'`
      if [[ -z ${Last_Emulator} ]]; then
        Last_Emulator=`grep PICO-8 /home/ark/.emulationstation/es_settings.cfg | grep -oP '(?<=PICO-8.emulator" value=").*?(?=")'`
          if [[ -z ${Last_Emulator} ]]; then
            Last_Emulator="float-scaled"
          fi
      fi
    fi

    echo "nice -n -19 /usr/local/bin/pico8.sh \"${Last_Emulator}\" \"/${Last_Game}\""
  else
    if [ -f "/home/ark/.emulationstation/recovery/PICO-8/zzzsplore.xml" ]; then
      Last_Emulator=`sed -n "/zzzsplore.p8/{n;n;p}" /home/ark/.emulationstation/recovery/PICO-8/zzzsplore.xml | grep "<emulator>" |  grep -oP '(?<=>).*?(?=<)'`
    fi
    if [[ -z ${Last_Emulator} ]]; then
      Last_Emulator=`sed -n "/zzzsplore.p8/{n;n;p}" /${Directory}/pico-8/carts/gamelist.xml | grep "<emulator>" |  grep -oP '(?<=>).*?(?=<)'`
      if [[ -z ${Last_Emulator} ]]; then
        Last_Emulator=`grep PICO-8 /home/ark/.emulationstation/es_settings.cfg | grep -oP '(?<=PICO-8.emulator" value=").*?(?=")'`
        if [[ -z ${Last_Emulator} ]]; then
          Last_Emulator="float-scaled"
        fi
      fi
    fi
    echo "nice -n -19 /usr/local/bin/pico8.sh \"${Last_Emulator}\" \"/${Directory}/pico-8/carts/zzzsplore.png\""
  fi
  exit 0
elif [[ -e /dev/shm/PNG_Loaded ]]; then
  Last_Game=`grep '"path":' /home/ark/.config/${@}/content_image_history.lpl | head -1 | grep -oP '(?<=": ").*?(?=")'`
  Last_Core="/home/ark/.config/retroarch/cores/fake08_libretro.so"
else
  Last_Game=`grep '"path":' /home/ark/.config/${@}/content_history.lpl | head -1 | grep -oP '(?<=": ").*?(?=")'`
  Last_Core=`grep '"core_path":' /home/ark/.config/${@}/content_history.lpl | head -1 | grep -oP '(?<=": ").*?(?=")'`
fi

if [[ ${@} != "pico8" ]] && [[ ! -z $(pgrep quickmode.sh) ]]; then
  echo ". /usr/local/bin/buttonmon.sh"
  echo "Test_Button_R1"
  echo "if [ \"\$?\" -eq \"10\" ]; then"
  echo "  sudo systemctl start plymouth"
  echo "  sudo chmod 666 /dev/tty1"
  echo "  basefile=\"${Last_Game}\""
  echo "  basefilenoext=\"\${basefile%.*}\""
  echo "  printf \"\nAre you sure you want to delete the ${Last_Game} auto savestate?\n\" >> /dev/tty1"
  echo "  printf \"\nPress A to continue.  Press B to exit.\n\n\" >> /dev/tty1"
  echo "  while true"
  echo "  do"
  echo "      Test_Button_A"
  echo "      if [ \"\$?\" -eq \"10\" ]; then"
  echo "        printf \"\033[0mDeleteing the auto save state.  Please wait...\n\" >> /dev/tty1"
  echo "        sudo rm -fv \"\${basefilenoext}\".state.auto >> /dev/tty1"
  echo "        printf \"Done\n\" >> /dev/tty1"
  echo "        sleep 2"
  echo "        break"
  echo "      fi"
  echo ""
  echo "      Test_Button_B"
  echo "      if [ \"\$?\" -eq \"10\" ]; then"
  echo "        printf \"\033[0mSkipping the deletion of the auto save state of this game.\n\" >> /dev/tty1"
  echo "        sleep 2"
  echo "        break"
  echo "      fi"
  echo "  done"
  echo "fi"
  echo ""
fi

echo "/usr/local/bin/${@} -L ${Last_Core} \"${Last_Game}\""

exit 0
