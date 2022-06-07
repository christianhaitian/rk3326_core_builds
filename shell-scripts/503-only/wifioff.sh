#!/bin/bash
#c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
#sudo nmcli n off
printf "\n\n\n\e[32mDisabling wifi and related services...\n"
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo systemctl stop networkwatchdaemon
sudo systemctl disable networkwatchdaemon
sudo modprobe -r 8821cs
sudo sed -i '$ablacklist 8821cs' /etc/modprobe.d/blacklist.conf
printf "\n\n\n\e[32mWifi has been disabled.\n"
sleep 2
#echo 3 > /sys/class/backlight/backlight/brightness
#sleep 1
#echo $c_brightness > /sys/class/backlight/backlight/brightness
#sleep 1
#echo 3 > /sys/class/backlight/backlight/brightness
#sleep 1
#echo $c_brightness > /sys/class/backlight/backlight/brightness

