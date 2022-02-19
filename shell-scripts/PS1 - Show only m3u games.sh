#!/bin/bash
printf "\033c" >> /dev/tty1
sed -i '/<extension>.cue .CUE .img .IMG .mdf .MDF .pbp .PBP .toc .TOC .cbn .CBN .m3u .M3U .ccd .CCD .chd .CHD .zip .ZIP .7z .7Z .iso .ISO<\/extension>/s//<extension>.m3u .M3U<\/extension>/' /etc/emulationstation/es_systems.cfg
cp -f -v /usr/local/bin/"PS1 - Show all games.sh" /opt/system/"PS1 - Show all games.sh"
rm -f -v /opt/system/"PS1 - Show only m3u games.sh"
printf "PS1 has been set to show only games with .m3u extensions.\nEmulationstation will now be restarted." >> /dev/tty1
sleep 5
printf "\033c" >> /dev/tty1
sudo systemctl restart emulationstation
