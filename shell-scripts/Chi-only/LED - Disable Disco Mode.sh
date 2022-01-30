#!/bin/bash
sudo cp -v /usr/local/bin/lightshow-nd.sh /usr/local/bin/lightshow.sh
sudo chmod 777 /usr/local/bin/lightshow.sh
sudo cp /usr/local/bin/LED\ -\ Enable\ Disco\ Mode.sh /opt/system/Advanced/.
sudo rm /opt/system/Advanced/LED\ -\ Disable\ Disco\ Mode.sh
printf "\n\n\n\e[32mDisco LED mode has been disabled. Emulationstation will now restart.\n"
sleep 2
printf "\033c" >> /dev/tty1
sudo systemctl restart emulationstation
