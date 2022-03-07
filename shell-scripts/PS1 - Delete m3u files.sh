#!/bin/bash
printf "\033c" >> /dev/tty1
sudo rm -f -v /roms2/psx/*.m3u >> /dev/tty1
sudo rm -f -v /roms2/psx/*.M3U >> /dev/tty1
sudo rm -f -v /roms2/psx/*/*.m3u >> /dev/tty1
sudo rm -f -v /roms2/psx/*/*.M3U >> /dev/tty1
printf "\nDone with deleting m3u files for for PS1.\nEmulationstation will now be restarted." >> /dev/tty1
sleep 3
printf "\033c" >> /dev/tty1
sudo systemctl restart emulationstation
