#!/bin/sh
sudo systemctl start openborhotkey.service
#cp "$1" /opt/OpenBor/Paks
file="$1"
basefile=$(basename -- "$file")
basefilename=${basefile%.*}
ln -s "$1" /opt/OpenBor/Paks/"$basefile"
if [ ! -f "/opt/OpenBor/Saves/${basefilename}.cfg" ]; then
  cp "/opt/OpenBor/Saves/master.cfg" "/opt/OpenBor/Saves/${basefilename}.cfg"
fi
cd /opt/OpenBor/
LD_LIBRARY_PATH=. ./OpenBOR
rm -rf /opt/OpenBor/Paks/*
sudo systemctl stop openborhotkey.service
printf "\033c" >> /dev/tty1
