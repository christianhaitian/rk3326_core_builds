#!/bin/bash

export KODI_HOME=/opt/kodi/share
#export PYTHONHOME=/usr/bin
#export PYTHONPATH=/usr/lib/python2.7

printf "\n\n\e[32mStarting Kodi.  Please wait..."

# Make some additional libs available for Kodi during launch
# and use.
export LD_LIBRARY_PATH=/opt/kodi/libs/:/opt/kodi/libs/samba

# Copy default userdata setup so we have menu controls 
# and other niceties on initial launch.
if [[ ! -d "/home/ark/.kodi" ]]; then
  mkdir /home/ark/.kodi
  cp -R /opt/kodi/userdata/ /home/ark/.kodi/
fi

# Change owner of volume keys or Kodi will grab them
sudo chown root:root /dev/input/event2

# Allow for quick kill of Kodi pressing and holding Select buttong 
# then press the Start button.
sudo /opt/quitter/oga_controls kodi.bin rg503 &

/opt/kodi/kodi.bin

# Make sure quitter is killed if exiting Kodi through the menu
# or ES navigation will be wonky.
if [[ ! -z $(pidof oga_controls) ]]; then
  sudo kill -9 $(pidof oga_controls)
fi

# Restart global hotkey deamon just in case it was impacted by the quitter
sudo systemctl restart oga_events &

# Clean up screen when done
printf "\033c" >> /dev/tty1
