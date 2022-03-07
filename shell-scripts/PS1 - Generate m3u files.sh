#!/bin/bash
# -*- coding: UTF8 -*-
#
# Copied from https://github.com/danyboy666/Generate-PSX-m3u-playlist/blob/master/generate_psx_m3u.sh 
# Modified by Christian Haitian
#
# Name : generate_psx_m3u.sh
# Usage : Copy script in working dir and execute.
# Simple script to generate an .m3u playlist file for every title found in the folder
# This will take care of multi disc as well as single disk.
#
# Copyright (C) 2018 Walter White - All Rights Reserved
# Permission to copy and modify is granted under the GNU GPL v3 license

# Clear the screen
printf "\033c" >> /dev/tty1
# Process psx games in the root of the psx folder if they exist
cd /roms/psx
if [ $(ls -1 *.cue 2>/dev/null | wc -l) != 0 ]
then
  for c in *.cue
  do
        title=$(echo "$c" | sed s'/.cue//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$c" >> "$title".m3u
  done
fi

if [ $(ls -1 *.chd 2>/dev/null | wc -l) != 0 ]
then
  for h in *.chd
  do
        title=$(echo "$h" | sed s'/.chd//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$h" >> "$title".m3u
  done
fi

if [ $(ls -1 *.CUE 2>/dev/null | wc -l) != 0 ]
then
  for c in *.CUE
  do
        title=$(echo "$c" | sed s'/.CUE//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$c" >> "$title".m3u
  done
fi

if [ $(ls -1 *.CHD 2>/dev/null | wc -l) != 0 ]
then
  for h in *.CHD
  do
        title=$(echo "$h" | sed s'/.CHD//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$h" >> "$title".m3u
  done
fi

# Process psx games in sub folders of the psx folder if they exist
for f in /roms/psx/*/
do
 cd "$f"

 if [ $(ls -1 *.cue 2>/dev/null | wc -l) != 0 ]
 then
   for c in *.cue
   do
         title=$(echo "$c" | sed s'/.cue//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "$c" >> "$title".m3u
   done
 fi

 if [ $(ls -1 *.chd 2>/dev/null | wc -l) != 0 ]
 then
    for h in *.chd
    do
         title=$(echo "$h" | sed s'/.chd//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "$h" >> "$title".m3u
   done
 fi

 if [ $(ls -1 *.CUE 2>/dev/null | wc -l) != 0 ]
 then
   for c in *.CUE
   do
         title=$(echo "$c" | sed s'/.CUE//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "$c" >> "$title".m3u
   done
 fi

 if [ $(ls -1 *.CHD 2>/dev/null | wc -l) != 0 ]
 then
   for h in *.CHD
   do
         title=$(echo "$h" | sed s'/.CHD//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "$h" >> "$title".m3u
   done
 fi
done

# Print all m3u files that were created to the screen
for f in /roms/psx/*/*.m3u
do
  printf "Added $f\n" >> /dev/tty1
done

for f in /roms/psx/*.m3u
do
  printf "Added $f\n" >> /dev/tty1
done
printf "\nEmulationstation will now be restarted." >> /dev/tty1
sleep 3
sudo systemctl restart emulationstation
