#!/bin/bash

wifion=$(rfkill | grep "wlan      phy*[0-9]       unblocked")

if [ -z "$wifion" ]
then
      sudo rfkill unblock wifi
      echo 1 > /sys/devices/platform/gpio_leds/leds/heartbeat/brightness
      sleep 0.5
      echo 0 > /sys/devices/platform/gpio_leds/leds/heartbeat/brightness
else
      sudo rfkill block wifi
      echo 1 > /sys/devices/platform/gpio_leds/leds/heartbeat/brightness
      sleep 0.5
      echo 0 > /sys/devices/platform/gpio_leds/leds/heartbeat/brightness
      sleep 0.5
      echo 1 > /sys/devices/platform/gpio_leds/leds/heartbeat/brightness
      sleep 0.5
      echo 0 > /sys/devices/platform/gpio_leds/leds/heartbeat/brightness
fi
