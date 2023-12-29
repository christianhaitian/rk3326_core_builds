#!/bin/bash

. /usr/local/bin/buttonmon.sh

if [ -e "/home/ark/.config/.MBROLA_VOICE_FEMALE" ]; then
  voice="1"
elif [ -e "/home/ark/.config/.MBROLA_VOICE_MALE3" ]; then
  voice="3"
else
  voice="2"
fi

Test_Button_R2
if [ "$?" -eq "10" ]; then
  runuser -u ark -- espeak-ng -vmb-us${voice} -s130 "The current performance governor is $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor)"
  if [[ $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor) == "userspace" ]]; then
    runuser -u ark -- espeak-ng -vmb-us${voice} -s130 "CPU speed is currently $(awk 'length==6{printf("%.0f MHz\n", $0/10^3); next} length==7{printf("%.1f GHz\n", $0/10^6)}' /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq)" &
  fi
else
  if [[ ! -z "$@" ]]; then
    runuser -u ark -- espeak-ng -vmb-us${voice} -s130 "${@} $(cat /sys/class/power_supply/battery/capacity) percent"
  else
    runuser -u ark -- espeak-ng -vmb-us${voice} -s130 "Your battery level is at $(cat /sys/class/power_supply/battery/capacity) percent"
  fi

  Test_Button_R2
  if [ "$?" -eq "10" ]; then
    runuser -u ark -- espeak-ng -vmb-us${voice} -s130 "The current performance governor is $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor)"
    if [[ $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor) == "userspace" ]]; then
      runuser -u ark -- espeak-ng -vmb-us${voice} -s130 "CPU speed is currently $(awk 'length==6{printf("%.0f MHz\n", $0/10^3); next} length==7{printf("%.1f GHz\n", $0/10^6)}' /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq)" &
    fi
  fi
fi
