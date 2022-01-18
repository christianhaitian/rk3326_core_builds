#!/bin/bash

if  [[ $1 == "standalone" ]]; then

  directory=$(dirname "$2" | cut -d "/" -f2)
  unlink /opt/hypseus-singe/roms
  ln -sfv /$directory/daphne/roms/ /opt/hypseus-singe/roms

  dir="$2"
  basedir=$(basename -- $dir)
  basefilename=${basedir%.*}

  if [ -f "$dir/$basefilename.commands" ]; then
     extraparams=$(<"$dir/$basefilename.commands")
  fi

  sudo systemctl start singehotkey.service

  rm -f /home/ark/.asoundrc
#  cd /opt/hypseus/
  cd /opt/hypseus-singe
#  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 ./hypseus "$basefilename" vldp -framefile "$dir/$basefilename.txt" -fullscreen -useoverlaysb 2 $extraparams
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 ./hypseus-singe "$basefilename" vldp -framefile "$dir/$basefilename.txt" -fullscreen -useoverlaysb 2 $extraparams
  rm *.csv
  cp /home/ark/.asoundrcbak /home/ark/.asoundrc

  sudo systemctl stop singehotkey.service
else
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi
