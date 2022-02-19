#!/bin/bash
c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
sudo nmcli n off
echo 3 > /sys/class/backlight/backlight/brightness
sleep 1
echo $c_brightness > /sys/class/backlight/backlight/brightness
sleep 1
echo 3 > /sys/class/backlight/backlight/brightness
sleep 1
echo $c_brightness > /sys/class/backlight/backlight/brightness

