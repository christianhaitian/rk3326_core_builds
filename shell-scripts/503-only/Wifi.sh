#!/bin/bash
#sudo nmui

# Copyright (c) 2021
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the
# Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
# Boston, MA 02110-1301 USA
#
# Authored by: Kris Henriksen <krishenriksen.work@gmail.com>
#
# Wi-Fi-dialog
#

sudo chmod 666 /dev/tty1
printf "\033c" > /dev/tty1

# hide cursor
printf "\e[?25l" > /dev/tty1

export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

printf "\033c" > /dev/tty1
printf "Starting Wifi Manager.  Please wait..." > /dev/tty1
sudo systemctl stop networkwatchdaemon
sudo systemctl start NetworkManager

#cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
old_ifs="$IFS"

ExitMenu() {
  printf "\033c" > /dev/tty1
  pgrep -f oga_controls | sudo xargs kill -9
  sudo systemctl stop NetworkManager
  sudo systemctl start networkwatchdaemon
  exit 0
}

DeleteConnect() {

  cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
  dialog --clear --backtitle "Delete Connection: Currently connected to $cur_ap" --title "Removing $1" --clear \
  --yesno "\nWould you like to continue to remove this connection?" 15 55 2>&1 > /dev/tty1

  case $? in
     0) sudo rm -f /etc/NetworkManager/system-connections/$1.nmconnection ;;
  esac

  Delete
}

Activate() {

  cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
  aoptions=( $(ls -1 /etc/NetworkManager/system-connections/ | rev | cut -c 14- | rev | sed -e 's/$/ ./') )

  while true; do
    aselection=(dialog \
   	--backtitle "Existing Connections: Currently connected to $cur_ap" \
   	--title "Which existing connection would you like to connect to?" \
   	--no-collapse \
   	--clear \
	--cancel-label "Back" \
    --menu "" 15 55 15)

    achoices=$("${aselection[@]}" "${aoptions[@]}" 2>&1 > /dev/tty1) || MainMenu

    for achoice in $achoices; do
      case $achoice in
        *) ConnectExisting $achoice ;;
      esac
    done
  done  

}

Select() {
  KEYBOARD="osk"

  # get password from input
  PASS=`$KEYBOARD "Enter Wi-Fi password" | tail -n 1`

  dialog --infobox "\nConnecting to Wi-Fi $1 ..." 5 55 > /dev/tty1

  # try to connect
  output=`nmcli con delete "$1"`
  output=`nmcli device wifi connect "$1" password "$PASS"`

  success=`echo "$output" | grep successfully`

  if [ -z "$success" ]; then
    output="Activation failed: Secrets were required, but not provided ..."
  else
    output="Device successfully activated and connected to Wi-Fi ..."
	cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
  fi
  
  dialog --infobox "\n$output" 6 55 > /dev/tty1
  sleep 3
  Connect
}

#
# Joystick controls
#
# only one instance
  CONTROLS="/opt/wifi/oga_controls"

  sudo $CONTROLS Wifi.sh rg552 &

ConnectExisting() {
  cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`

  #nmcli con down "$cur_ap"
  
  output=`nmcli con down "$cur_ap" && nmcli con up "$1"`

  success=`echo "$output" | grep successfully`

  if [ -z "$success" ]; then
    output="Failed to connect to $1"
  else
    output="Device successfully activated and connected to $1"
	cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
  fi
  
  dialog --infobox "\n$output" 6 55 > /dev/tty1
  sleep 3
  Activate
}

Connect() {
  dialog --infobox "\nScanning available Wi-Fi access points ..." 5 55 > /dev/tty1
  sleep 5
  clist=`sudo nmcli -f ALL --mode tabular --terse --fields IN-USE,SSID,CHAN,SIGNAL,SECURITY dev wifi`
  cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`

  # Set colon as the delimiter
  IFS=':'
  unset coptions
  while IFS= read -r clist; do
    # Read the split words into an array based on colon delimiter
    read -a strarr <<< "$clist"

    INUSE=`printf '%-5s' "${strarr[0]}"`
    SSID="${strarr[1]}"
    CHAN=`printf '%-5s' "${strarr[2]}"`
    SIGNAL=`printf '%-5s' "${strarr[3]}%"`
    SECURITY="${strarr[4]}"

    coptions+=("$SSID" "$INUSE $CHAN $SIGNAL $SECURITY")
  done <<< "$clist"

  while true; do
    cselection=(dialog \
   	--backtitle "Available Connections: Currently connected to $cur_ap" \
   	--title "SSID  IN-USE  CHANNEL  SIGNAL  SECURITY" \
   	--no-collapse \
   	--clear \
	--cancel-label "Back" \
    --menu "" 15 55 15)

    cchoices=$("${cselection[@]}" "${coptions[@]}" 2>&1 > /dev/tty1) || MainMenu

    for cchoice in $cchoices; do
      case $cchoice in
        *) Select $cchoice ;;
      esac
    done
  done
}

Delete() {
  deloptions=( $(ls -1 /etc/NetworkManager/system-connections/ | rev | cut -c 14- | rev | sed -e 's/$/ ./') )
  cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
  
  while true; do
    delselection=(dialog \
   	--backtitle "Existing Connections: Currently connected to $cur_ap" \
   	--title "Which connection would you like to delete?" \
   	--no-collapse \
   	--clear \
	--cancel-label "Back" \
    --menu "" 15 55 15)

    delchoices=$("${delselection[@]}" "${deloptions[@]}" 2>&1 > /dev/tty1) || MainMenu

    for delchoice in $delchoices; do
      case $delchoice in
        *) DeleteConnect $delchoice ;;
      esac
    done
  done  

}

NetworkInfo() {

  gateway=`ip r | grep default | awk '{print $3}'`
  currentip=`ip -f inet addr show wlan0 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p'`
  currentssid=`iw dev wlan0 info | grep ssid | cut -c 7-30`
  currentdns=`( nmcli dev list || nmcli dev show ) 2>/dev/null | grep DNS | awk '{print $2}'`

  dialog --clear --backtitle "Your Network Information" --title "" --clear \
  --msgbox "\n\nSSID: $cur_ap\nIP: $currentip\nGateway: $gateway\nDNS: $currentdns" 15 55 2>&1 > /dev/tty1
}

MainMenu() {
  mainoptions=( 1 "Connect to new Wifi connection" 2 "Activate existing Wifi Connection" 3 "Delete exiting connections" 4 "Current Network Info" 5 "Exit" )
  cur_ap=`iw dev wlan0 info | grep ssid | cut -c 7-30`
  IFS="$old_ifs"
  while true; do
    mainselection=(dialog \
   	--backtitle "Wifi Manager: Currently connected to $cur_ap" \
   	--title "Main Menu" \
   	--no-collapse \
   	--clear \
	--cancel-label "Select + Start to Exit" \
    --menu "Please make your selection" 15 55 15)
	
	mainchoices=$("${mainselection[@]}" "${mainoptions[@]}" 2>&1 > /dev/tty1)

    for mchoice in $mainchoices; do
      case $mchoice in
        1) Connect ;;
		2) Activate ;;
		3) Delete ;;
		4) NetworkInfo ;;
		5) ExitMenu ;;
      esac
    done
  done
}

MainMenu

