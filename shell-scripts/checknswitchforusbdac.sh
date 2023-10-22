#!/bin/bash

DAC="0"
DAC_EXIST=""
NUM_CHECK='^[1-9]+$'

for (( ; ; ))
do
  if [ ! -e "/dev/snd/controlC7" ] && [[ "$DAC_EXIST" != "None" ]]; then
    sed -i '/hw:[0-9]/s//hw:0/' /home/ark/.asoundrc /home/ark/.asoundrcbak
    sudo systemctl restart oga_events &
    DAC_EXIST="None"
  elif [ -e "/dev/snd/controlC7" ] && [[ "$DAC" != "$DAC_EXIST" ]]; then
    DAC=$(ls -l /dev/snd/controlC7 | awk 'NR>=control {print $11;}' | cut -d 'C' -f2)
    if [[ $DAC =~ $NUM_CHECK ]]; then
      readarray -t USB_DAC < <(amixer -q -c ${DAC} scontents | grep 'Simple mixer control ' | cut -d "'" -f2)
      for i in "${USB_DAC[@]}"
      do
        amixer -q -c ${DAC} sset "${i}" 100%
      done
      sed -i '/hw:[0-9]/s//hw:'$DAC'/' /home/ark/.asoundrc /home/ark/.asoundrcbak
      sudo systemctl restart oga_events &
      DAC_EXIST="$DAC"
    fi
  fi
  if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3326"* ]] && [[ "$DAC" == "$DAC_EXIST" ]]; then
      for i in "${USB_DAC[@]}"
      do
        amixer -q -c ${DAC} sset "${i}" $(current_volume)
      done
  fi
  sleep 1
done
