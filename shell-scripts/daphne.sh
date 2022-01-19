#!/bin/bash

if  [[ $1 == "standalone" ]]; then

  directory=$(dirname "$2" | cut -d "/" -f2)

  unlink /opt/hypseus-singe/roms
  if [ $? != 0 ]; then
    sudo rm -rf /opt/hypseus-singe/roms
  fi
  ln -sfv /$directory/daphne/roms/ /opt/hypseus-singe/roms

  dir="$2"
  basedir=$(basename -- $dir)
  basefilename=${basedir%.*}

  if [ -f "$dir/$basefilename.commands" ]; then
     extraparams=$(<"$dir/$basefilename.commands")
  fi

  sudo systemctl start singehotkey.service

  rm -f /home/ark/.asoundrc
  cd /opt/hypseus-singe
  
  # Preloading sdl 2.0.10 because daphne emulation audio lags with sdl 2.0.16 for some reason
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 ./hypseus-singe "$basefilename" vldp -framefile "$dir/$basefilename.txt" -fullscreen -useoverlaysb 2 $extraparams
  rm *.csv
  cp /home/ark/.asoundrcbak /home/ark/.asoundrc

  sudo systemctl stop singehotkey.service
else
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi
