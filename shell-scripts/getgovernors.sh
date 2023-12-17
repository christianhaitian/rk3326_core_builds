#!/bin/bash

if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3326"* ]]; then
  gpu="ff400000"
else
  gpu="fde60000"
fi

printf "\nGPU is set to the $(cat /sys/devices/platform/${gpu}.gpu/devfreq/${gpu}.gpu/governor) governor"
if [[ $(cat /sys/devices/platform/${gpu}.gpu/devfreq/${gpu}.gpu/governor) == "userspace" ]]; then
  printf "\n  GPU speed is set to $(cat /sys/devices/platform/${gpu}.gpu/devfreq/${gpu}.gpu/userspace/set_freq)"
  printf "\n  GPU speed is actually $(cat /sys/devices/platform/${gpu}.gpu/devfreq/${gpu}.gpu/cur_freq)"
fi
printf "\nCPU is set to the $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor) governor"
if [[ $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor) == "userspace" ]]; then
  printf "\n  CPU speed is set to $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed)"
  printf "\n  CPU speed is actually $(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq)"
fi
printf "\nDMC is set to the $(cat /sys/devices/platform/dmc/devfreq/dmc/governor) governor"
if [[ $(cat /sys/devices/platform/dmc/devfreq/dmc/governor) == "userspace" ]]; then
  printf "\n  DMC speed is set to $(cat /sys/devices/platform/dmc/devfreq/dmc/userspace/set_freq)"
  printf "\n  DMC speed is actually $(cat /sys/devices/platform/dmc/devfreq/dmc//cur_freq)"
fi
printf "\n"
