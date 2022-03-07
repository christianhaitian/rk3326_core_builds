#!/bin/bash
printf "\033c" >> /dev/tty1
sed -i '/<extension>.exe .EXE .com .COM .bat .BAT .conf .CONF .cue .CUE .iso .ISO .zip .ZIP .m3u .M3U .dosz .DOSZ<\/extension>/s//<extension>.exe .EXE .com .COM .bat .BAT .conf .CONF .cue .CUE .iso .ISO .m3u .M3U .dosz .DOSZ<\/extension>/' /etc/emulationstation/es_systems.cfg
cp -f -v /usr/local/bin/"MSDOS - Show zip games.sh" /opt/system/"MSDOS - Show zip games.sh"
rm -f -v /opt/system/"MSDOS - Hide zip games.sh"
printf "MSDOS has been set to hide games with .zip extensions.\nEmulationstation will now be restarted." >> /dev/tty1
sleep 5
printf "\033c" >> /dev/tty1
sudo systemctl restart emulationstation
