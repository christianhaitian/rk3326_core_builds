#!/bin/bash

if [[ -f "/opt/system/Tools/wifikeyfile.txt" ]]; then

	sudo chmod 666 /dev/tty1
	export TERM=linux
	export XDG_RUNTIME_DIR=/run/user/$UID/
	printf "\033c" > /dev/tty1
	printf "\e[?25l" > /dev/tty1
	dialog --clear

	height="15"
	width="55"

	if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
	  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	  height="20"
	  width="60"
	elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
	  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	  height="20"
	  width="60"
	elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
	  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	  height="20"
	  width="60"
	else
	  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
	  height="20"
	  width="60"
	fi

    if [[ ! -z $(cat /etc/modprobe.d/blacklist.conf | grep 8821cs | tr -d '\0') ]]; then
	  dialog --infobox "Your wifi connection is off.  Please enable it in options>advanced then reboot so importing of your wifi credentials can be completed." 5 $width > /dev/tty1
	  sleep 10
	  exit 0
	fi

	dialog --infobox "Starting Wifi importer.  Please wait..." 5 $width > /dev/tty1
	#printf "Starting Wifi importer.  Please wait..." > /dev/tty1
	sudo systemctl stop networkwatchdaemon
	sudo systemctl start NetworkManager

	mapfile wificreds < /opt/system/Tools/wifikeyfile.txt
	ssid=$(echo ${wificreds[0]} | grep -oP '(?<=").*?(?=")')
	pass=$(echo ${wificreds[1]} | grep -oP '(?<=").*?(?=")')

	if [ ! -z "$ssid" ] && [ ! -z "$pass" ]; then
	  dialog --infobox "\nConnecting to Wi-Fi $ssid ..." 5 $width > /dev/tty1
	  clist=`sudo nmcli -f ALL --mode tabular --terse --fields IN-USE,SSID,CHAN,SIGNAL,SECURITY dev wifi`
	  WPA3=`echo "$clist" | grep "$ssid" | grep " WPA3"`

	  # try to connect
	  output=`nmcli con delete "$ssid"`
	  if [[ "$WPA3" != *" WPA3"* ]]; then
		output=`nmcli device wifi connect "$ssid" password "$pass"`
	  else
		#workaround for wpa2/wpa3 connectivity
		output=`nmcli device wifi connect "$ssid" password "$pass"`
		sudo sed -i '/key-mgmt\=sae/s//key-mgmt\=wpa-psk/' /etc/NetworkManager/system-connections/"$ssid".nmconnection
		sudo systemctl restart NetworkManager
		output=`nmcli con up "$ssid"`
	  fi
	  success=`echo "$output" | grep successfully`

	  if [ -z "$success" ]; then
		output="Activation failed: File has been renamed to wifikeyfile.txt.nogood in the tools folder.  Please review it, correct it, rename it back to wifikeyfile.txt and try again."
		cp -f /opt/system/Tools/wifikeyfile.txt /opt/system/Tools/wifikeyfile.txt.nogood
		sudo rm -f /opt/system/Tools/wifikeyfile.txt
	  else
		sudo rm -f /opt/system/Tools/wifikeyfile.txt
		output="Device successfully activated and connected to Wi-Fi.  wifikeyfile.txt has been deleted for security."
	  fi

	  dialog --infobox "\n$output" 6 $width > /dev/tty1
	  sleep 10
	else
	  cp -f /opt/system/Tools/wifikeyfile.txt /opt/system/Tools/wifikeyfile.txt.nogood
	  sudo rm -f /opt/system/Tools/wifikeyfile.txt
	  dialog --infobox "The contents of the wifikeyfile.txt are invalid.  Nothing can be imported at this time.  File has been renamed to wifikeyfile.txt.nogood in the tools folder." $height $width 2>&1 > /dev/tty1 
	  sleep 10
	fi
	sudo systemctl stop NetworkManager
	sudo systemctl start networkwatchdaemon
    printf "\033c" > /dev/tty1
	exit 0
fi

exit 0
