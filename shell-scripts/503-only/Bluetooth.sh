#!/bin/bash

# Copyright (c) 2022
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
# Authored by: Christian_Haitian
#
# Bluetooth-dialog
#

sudo chmod 666 /dev/tty1
printf "\033c" > /dev/tty1

# hide cursor
printf "\e[?25l" > /dev/tty1

export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

printf "\033c" > /dev/tty1
printf "Starting Bluetooth Manager.  Please wait..." > /dev/tty1

#
# Joystick controls
#
# only one instance
CONTROLS="/opt/wifi/oga_controls"
sudo $CONTROLS Bluetooth.sh rg552 &
sleep 2

old_ifs="$IFS"

ExitMenu() {
  printf "\033c" > /dev/tty1
  pgrep -f oga_controls | sudo xargs kill -9
  exit 0
}

Activate() {

  alist=`timeout 5s bluetoothctl paired-devices`

  IFS=' '
  unset aoptions
  while IFS= read -r alist; do
    # Read the split words into an array based on space delimiter
    read -a strarr <<< "$alist"

    MACADD=`printf '%-5s' "${strarr[1]}"`
    NAME1="${strarr[2]}"
    NAME2="${strarr[3]}"
    NAME3="${strarr[4]}"

    aoptions+=("$MACADD" "$NAME1")
  done <<< "$alist"


  while true; do
    aselection=(dialog \
   	--backtitle "Existing Connections" \
   	--title "Which device would you like to connect to?" \
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

DisconnectExisting() {

  dialog --infobox "\nDisconnecting $1 from Bluetooth ..." 5 55 > /dev/tty1
  bluetoothctl --timeout 5 scan on >> /dev/null
  
  output=`bluetoothctl disconnect "$1"`
  success=`echo "$output" | grep "Successful disconnected"`

  if [ -z "$success" ]; then
    output="disconnecting to $1 failed"
  else
    output="Device $1 successfully disconnected from Bluetooth ..."
  fi
  
  dialog --infobox "\n$output" 6 55 > /dev/tty1
  sleep 3
  Deactivate
}

Deactivate() {

  dalist=`timeout 5s bluetoothctl paired-devices`

  IFS=' '
  unset daoptions
  while IFS= read -r dalist; do
    # Read the split words into an array based on space delimiter
    read -a strarr <<< "$dalist"

    MACADD=`printf '%-5s' "${strarr[1]}"`
    NAME1="${strarr[2]}"
    NAME2="${strarr[3]}"
    NAME3="${strarr[4]}"

    daoptions+=("$MACADD" "$NAME1")
  done <<< "$dalist"


  while true; do
    daselection=(dialog \
   	--backtitle "Existing Connections" \
   	--title "Which would you like to disconnect from Bluetooth?" \
   	--no-collapse \
   	--clear \
	--cancel-label "Back" \
    --menu "" 15 55 15)

    dachoices=$("${daselection[@]}" "${daoptions[@]}" 2>&1 > /dev/tty1) || MainMenu

    for dachoice in $dachoices; do
      case $dachoice in
        *) DisconnectExisting $dachoice ;;
      esac
    done
  done  

}

ConnectExisting() {

  dialog --infobox "\nConnecting to $1 via Bluetooth ..." 5 55 > /dev/tty1
  bluetoothctl --timeout 5 scan on >> /dev/null
  
  output=`timeout 5s bluetoothctl connect "$1"`
  success=`echo "$output" | grep "Connection successful"`

  if [ -z "$success" ]; then
    output="Connecting to $1 failed"
  else
    output="Device $1 successfully connected via Bluetooth ..."
  fi
  
  dialog --infobox "\n$output" 6 55 > /dev/tty1
  sleep 3
  Activate
}

Select() {
  dialog --infobox "\nPairing and Connecting to Bluetooth device $1 ..." 5 55 > /dev/tty1
  # try to connect

  alreadypaired=`bluetoothctl paired-devices | grep "$1"`
  if [ ! -z "$alreadypaired" ]; then
    bluetoothctl remove "$1"
    output=`bluetoothctl pair "$1"`
  else
    output=`bluetoothctl pair "$1"`
  fi
  
  success=`echo "$output" | grep "Paired: yes"`

  if [ -z "$success" ]; then
    output="Activation failed"
  else
    bluetoothctl trust "$1"
	success=`bluetoothctl connect "$1"`
	if [ -z "$success" ]; then
      output="Controller paired successfully but failed to connect."
	else
      output="Device successfully paired and connected via Bluetooth ..."
	fi
  fi
  
  dialog --infobox "\n$output" 6 55 > /dev/tty1
  sleep 3
  MainMenu
}

Connect() {
  dialog --infobox "\nScanning for available bluetooth devices ..." 5 55 > /dev/tty1

  sudo systemctl stop bluetooth
  sleep 1
  sudo hciconfig hci0 down
  sleep 1
  sudo hciconfig hci0 up
  sleep 1
  sudo systemctl start bluetooth
  sleep 2

  clist=`bluetoothctl --timeout 10 scan on`

  # Set space as the delimiter
  IFS=' '
  unset coptions
  unset coptions2
  while IFS= read -r clist; do
    # Read the split words into an array based on space delimiter
    read -a strarr <<< "$clist"

    NEWDEVICE="${strarr[0]}"
    MACADD=`printf '%-5s' "${strarr[2]}"`
    NAME1="${strarr[3]}"

    if [[ "$NEWDEVICE" == *"NEW"* ]]; then
      coptions+=("$MACADD" "$NAME1")
	fi
  done <<< "$clist"

  while true; do
    cselection=(dialog \
   	--backtitle "Available Connections" \
   	--title "Mac Address        Device Name" \
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

DeleteConnect() {

  dialog --clear --backtitle "Delete Connection" --title "Removing $1" --clear \
  --yesno "\nWould you like to continue to remove this connection?" 15 55 2>&1 > /dev/tty1

  case $? in
     0) dialog --infobox "\nUnpairing Bluetooth device $1 ..." 5 55 > /dev/tty1 
	    bluetoothctl untrust "$1" >> /dev/null
	    bluetoothctl remove "$1" >> /dev/null
	    if [ $? != 0 ]; then
	      output="Unpairing failed"
	    else
	      output="$1 successfully unpaired from this device via Bluetooth ..."
	    fi
	    dialog --infobox "\n$output" 6 55 > /dev/tty1
	    sleep 3
		;;
  esac

  Delete
}

Delete() {
  dellist=`timeout 5s bluetoothctl paired-devices`

  IFS=' '
  unset deloptions
  while IFS= read -r dellist; do
    # Read the split words into an array based on space delimiter
    read -a strarr <<< "$dellist"

    MACADD=`printf '%-5s' "${strarr[1]}"`
    NAME1="${strarr[2]}"
    NAME2="${strarr[3]}"
    NAME3="${strarr[4]}"

    deloptions+=("$MACADD" "$NAME1")
  done <<< "$dellist"
  
  while true; do
    delselection=(dialog \
   	--backtitle "Existing Connections" \
   	--title "Which paired connection would you like to delete?" \
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

PairedDevices() {

  pairedlist=`timeout 5s bluetoothctl paired-devices`

  IFS=' '
  unset list
  while IFS= read -r pairedlist; do
    # Read the split words into an array based on space delimiter
    read -a strarr <<< "$pairedlist"

    MACADD=`printf '%-5s' "${strarr[1]}"`
    NAME1="${strarr[2]}"
    NAME2="${strarr[3]}"
    NAME3="${strarr[4]}"

    list+=("    $MACADD     $NAME1 $NAME2 $NAME3")
  done <<< "$pairedlist"

  dialog --clear --backtitle "Your Paired devices" --title "" --clear \
   	     --title "MAC Address    Device Name" \
         --msgbox "\n\n$list" 15 55 2>&1 > /dev/tty1
}

MainMenu() {
  mainoptions=( 1 "Connect to new Bluetooth device" 2 "Activate existing Bluetooth device" 3 "Deactivate existing Bluetooth device" 4 "Delete exiting Bluetooth device" 5 "Currently paired Bluetooth devicess" 6 "Exit" )
  IFS="$old_ifs"
  while true; do
    mainselection=(dialog \
   	--backtitle "Bluetooth Manager" \
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
		3) Deactivate ;;
		4) Delete ;;
		5) PairedDevices ;;
		6) ExitMenu ;;
      esac
    done
  done
}

MainMenu

