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
#
# Modified by Rocky5, cleanup, better screen logging and m3u placement.

if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
then
  directory="roms2"
else
  directory="roms"
fi

# Clean previous m3u files
sudo rm -f -v /$directory/psx/*.m3u > /dev/null
sudo rm -f -v /$directory/psx/*/*.m3u > /dev/null
sudo rm -f -v /$directory/psx/*.M3U > /dev/null
sudo rm -f -v /$directory/psx/*/*.M3U > /dev/null
# Clear the screen
printf "\033c" >> /dev/tty1
# Process psx games in the root of the psx folder if they exist
printf "Processing files\n" >> /dev/tty1
sleep .5
cd /$directory/psx
if [ $(ls -1 *.cue 2>/dev/null | wc -l) != 0 ]
then
  for c in *.cue
  do
        title=$(echo "$c" | sed s'/.cue//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$c" >> "$title".m3u
        printf "Added $title\n" >> /dev/tty1
  done
fi

if [ $(ls -1 *.chd 2>/dev/null | wc -l) != 0 ]
then
  for h in *.chd
  do
        title=$(echo "$h" | sed s'/.chd//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$h" >> "$title".m3u
        printf "Added $title\n" >> /dev/tty1
  done
fi

if [ $(ls -1 *.CUE 2>/dev/null | wc -l) != 0 ]
then
  for c in *.CUE
  do
        title=$(echo "$c" | sed s'/.CUE//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$c" >> "$title".m3u
        printf "Added $title\n" >> /dev/tty1
  done
fi

if [ $(ls -1 *.CHD 2>/dev/null | wc -l) != 0 ]
then
  for h in *.CHD
  do
        title=$(echo "$h" | sed s'/.CHD//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

        echo "$h" >> "$title".m3u
        printf "Added $title\n" >> /dev/tty1
  done
fi

# Process psx games in sub folders of the psx folder if they exist
printf "\nProcessing sub folders\n" >> /dev/tty1
sleep .5
for f in /$directory/psx/*/
do

cd "$f"
subdir=$(basename "$f")

 if [ $(ls -1 *.cue 2>/dev/null | wc -l) != 0 ]
 then
   printf "Added $subdir\n" >> /dev/tty1
   for c in *.cue
   do
         title=$(echo "$c" | sed s'/.cue//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "./$subdir/$c" >> "../$title".m3u
   done
 fi

 if [ $(ls -1 *.chd 2>/dev/null | wc -l) != 0 ]
 then
   printf "Added $subdir\n" >> /dev/tty1
    for h in *.chd
    do
         title=$(echo "$h" | sed s'/.chd//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "./$subdir/$h" >> "../$title".m3u
   done
 fi

 if [ $(ls -1 *.CUE 2>/dev/null | wc -l) != 0 ]
 then
   printf "Added $subdir\n" >> /dev/tty1
   for c in *.CUE
   do
         title=$(echo "$c" | sed s'/.CUE//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "./$subdir/$c" >> "../$title".m3u
   done
 fi

 if [ $(ls -1 *.CHD 2>/dev/null | wc -l) != 0 ]
 then
   printf "Added $subdir\n" >> /dev/tty1
   for h in *.CHD
   do
         title=$(echo "$h" | sed s'/.CHD//g;s/ (Disc..)//g;s/ Disc..*$//g;s/ (.*//g')

         echo "./$subdir/$h" >> "../$title".m3u
   done
 fi
done

# Print all m3u files that were created to the screen
printf "\nEmulationstation will now be restarted." >> /dev/tty1
sleep 3
printf "\033c" >> /dev/tty1
sudo systemctl restart emulationstation
