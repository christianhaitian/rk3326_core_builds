#!/bin/bash

rootdirectory=$(dirname "$3" | cut -d "/" -f2)
romsdirectory=$(dirname "$3" | cut -d "/" -f3)
filename=$(basename "$3")
filename="${filename%.*}"

rm -rf ~/.mednafen/firmware
rm -rf ~/.mednafen/sav
rm -rf ~/.mednafen/mcs
rm -rf ~/.mednafen/b
rm -rf ~/.mednafen/pgconfig

ln -s /$rootdirectory/bios ~/.mednafen/firmware
ln -s /$rootdirectory/$romsdirectory ~/.mednafen/sav
ln -s /$rootdirectory/$romsdirectory ~/.mednafen/mcs
ln -s /$rootdirectory/$romsdirectory ~/.mednafen/b

if [ ! -d "/$rootdirectory/$romsdirectory/mednafen/gameconfigs" ]; then
  mkdir -p /$rootdirectory/$romsdirectory/mednafen/gameconfigs
fi

ln -s /$rootdirectory/$romsdirectory/mednafen/gameconfigs ~/.mednafen/pgconfig

event_num="2"
event_type="EV_KEY"
event_btn="BTN_EAST"
if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  param_device="anbernic"
  event_num="3"
  event_btn="BTN_SOUTH"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    param_device="oga"
  else
    param_device="rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  param_device="ogs"
else
  param_device="chi"
fi

ChooseYourscaler() {
          local options
          local choice

          selection=(dialog \
          --backtitle "What scaler you wish to set for $filename" \
          --title "Choose now" \
          --no-collapse \
          --clear \
          --cancel-label "You must select one" \
          --menu "$filename custom scaler is set to $custom_scaler.\n$console global scaler is set to $global_scaler." 14 55 10)

          options=(
                  "none" "."
                  "hq2x" "."
                  "hq3x" "."
                  "hq4x" "."
                  "scale2x" "."
                  "scale3x" "."
                  "scale4x" "."
                  "super2xsai" "."
                  "supereagle" "."
                  "nn2x" "."
                  "nn3x" "."
                  "nn4x" "."
                  "nny2x" "."
                  "nny3x" "."
                  "nny4x" "."
          )

          choice=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1)

          case $? in
          *) cusscaler[0]="$console.special $choice" 
             SaveSettings
             ;;
          esac
}

SaveSettings() {
  for j in "${cusscaler[@]}"
  do
    echo "$j"
  done > /$rootdirectory/$romsdirectory/mednafen/gameconfigs/"${filename}".$console.cfg
}


LetsPlay() {
if [[ "$2" == *"aspect"* ]]; then
  sed -i 's/.stretch.*/.stretch aspect/g' ~/.mednafen/mednafen.cfg
elif [[ "$2" == *"full"* ]]; then
  sed -i 's/.stretch.*/.stretch full/g' ~/.mednafen/mednafen.cfg
fi

if [[ "$2" != *"norecord"* ]]; then
  recordingname=$(echo "/$rootdirectory/videos/$(ls "$3" | cut -d "/" -f4).$RANDOM.mov")
  reqSpace=500000
  availSpace=$(df "/$rootdirectory" | awk 'NR==2 { print $4 }')
  if (( availSpace < reqSpace )); then
    printf "Not enough space to safely record this gameplay to $recordingname." >> /dev/tty1
    printf "\nYou need at least 500MBs of space left before" >> /dev/tty1
    printf "\na recording can be created for this gameplay." >> /dev/tty1
    sleep 10
    printf "\033c" >> /dev/tty1
    exit 1
  fi
  if [ ! -d "/$rootdirectory/videos" ]; then
   mkdir /$rootdirectory/videos
  fi
  if [ -f "$recordingname" ]; then
   rm -f "$recordingname"
  fi
  printf "\033c" >> /dev/tty1
  printf "\033[1;33m" >> /dev/tty1
  printf "\n This game play will be recorded to $recordingname" >> /dev/tty1
  printf "\n Be aware that this recording can use quite a bit of space." >> /dev/tty1
  printf "\n and can cause random emulation pauses during recording writes." >> /dev/tty1
  sleep 10
  printf "\033c" >> /dev/tty1
  if [ "$romsdirectory" == "snes" ] || [ "$romsdirectory" == "sfc" ] || [ "$romsdirectory" == "snes-hacks" ]; then
    /opt/mednafen/mednafen -force_module snes_faust -qtrecord "$recordingname" "$3"
  elif [ "$romsdirectory" == "pcengine" ] || [ "$romsdirectory" == "pcenginecd" ]; then
    /opt/mednafen/mednafen -force_module pce_fast -qtrecord "$recordingname" "$3"
  else
    /opt/mednafen/mednafen -qtrecord "$recordingname" "$3"
  fi
  recordingsize=$(ls -l -h "$recordingname" | awk 'NR==1 { print $5 }')
  afteravailSpace=$(df -h "/$rootdirectory" | awk 'NR==2 { print $4 }')
  printf "\033c" >> /dev/tty1
  printf "\033[1;33m" >> /dev/tty1
  printf "\n $recordingname is $recordingsize in size." >> /dev/tty1
  printf "\n You have $afteravailSpace of space left on your EASYROMS partition." >> /dev/tty1
  sleep 10
  printf "\033c" >> /dev/tty1
else
  if [ "$romsdirectory" == "snes" ] || [ "$romsdirectory" == "sfc" ] || [ "$romsdirectory" == "snes-hacks" ]; then
    /opt/mednafen/mednafen -force_module snes_faust "$3"
  elif [ "$romsdirectory" == "pcengine" ] || [ "$romsdirectory" == "pcenginecd" ]; then
    /opt/mednafen/mednafen -force_module pce_fast "$3"
  else
    /opt/mednafen/mednafen "$3"
  fi
fi
}

evtest --query /dev/input/event$event_num $event_type $event_btn
if [ "$?" -eq "10" ]; then
  if [ "$romsdirectory" == "snes" ] || [ "$romsdirectory" == "sfc" ] || [ "$romsdirectory" == "snes-hacks" ]; then
    console="snes"
  elif [ "$romsdirectory" == "nes" ] || [ "$romsdirectory" == "famicom" ] || [ "$romsdirectory" == "fds" ]; then
    console="nes"
  elif [ "$romsdirectory" == "gb" ] || [ "$romsdirectory" == "gbc" ]]; then
    console="gb"
  elif [[ "$romsdirectory" == *"pcengine"* ]] || [[ "$romsdirectory" == *"turbografx"* ]]; then
    console="pce_fast"
  elif [ "$romsdirectory" == "genesis" ] || [ "$romsdirectory" == "megadrive" ]; then
    console="md"
  elif [ "$romsdirectory" == "gba" ]; then
    console="gba"
  elif [ "$romsdirectory" == "atarilynx" ]; then
    console="lynx"
  elif [ "$romsdirectory" == "gamegear" ]; then
    console="gg"
  elif [ "$romsdirectory" == "mastersystem" ]; then
    console="sms"
  elif [ "$romsdirectory" == "virtualboy" ]; then
    console="vb"
  elif [[ "$romsdirectory" == *"wonderswan"* ]]; then
    console="wswan"
  elif [[ "$romsdirectory" == *"ngp"* ]]; then
    console="ngp"
  fi

  sudo kill -9 $(pidof menu_controls)
  sudo /opt/mednafen/menu_controls none $param_device &
  while true; do
          mapfile cusscaler < /$rootdirectory/$romsdirectory/mednafen/gameconfigs/"${filename}".$console.cfg
          custom_scaler="$(echo ${cusscaler[0]})"
          custom_scaler="$(echo ${custom_scaler##*.} | cut -c 9-)"
          global_scaler="$(cat ~/.mednafen/mednafen.cfg | grep ^$console.special)"
          global_scaler="$(echo ${global_scaler##*.} | cut -c 9-)"
          selection=(dialog \
          --backtitle "Let's throw some shade on this" \
          --title "scaler configuration" \
          --no-collapse \
          --clear \
          --cancel-label "You must select one" \
          --menu "$filename custom scaler is set to $custom_scaler.\n$console global scaler is set to $global_scaler." 14 55 10)

          options=(
                  "1)" "Set custom scaler for $filename"
                  "2)" "Remove custom scaler for $filename"
                  "3)" "Set global scaler for $console system"
                  "4)" "Remove global scaler for $console system"
                  "5)" "Play $console game - $filename"
                  "6)" "Exit back to ES"
          )

          choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1)

          for choice in $choices; do
                  case $choice in
                          "1)") ChooseYourscaler
                                SaveSettings
                                ;;
                          "2)") cusscaler[0]=""
                                SaveSettings
                                ;;
                          "3)") echo "placeholder"
                                ;;
                          "4)") echo "placeholder"
                                ;;
                          "5)") sudo kill -9 $(pidof menu_controls)
                                LetsPlay "$1" "$2" "$3"
                                exit 0
                                ;;
                          "6)") sudo kill -9 $(pidof menu_controls)
                                exit 0
                                ;;
                  esac
          done
  done
fi

LetsPlay "$1" "$2" "$3"
