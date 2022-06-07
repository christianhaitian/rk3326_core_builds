#!/bin/bash
#c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
printf "\n\n\n\e[32mEnabling wifi and related services...\n"
sudo modprobe -r 8821cs
sudo modprobe -i 8821cs
#sudo systemctl start NetworkManager
#sudo nmcli n on
sudo sed -i '/blacklist 8821cs/d' /etc/modprobe.d/blacklist.conf
sudo systemctl enable NetworkManager
sudo systemctl enable networkwatchdaemon
printf "\n\n\n\e[32mWifi has been enabled.  Now rebooting.\n"
sleep 2
sudo reboot
#echo 3 > /sys/class/backlight/backlight/brightness
#sleep 1
#echo $c_brightness > /sys/class/backlight/backlight/brightness

