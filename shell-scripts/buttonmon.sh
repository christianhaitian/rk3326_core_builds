#!/bin/bash

##################################################################
# Created by Christian Haitian for use as a sourced file         #
# to add button monitoring for confirmation capability in        #
# various scripts where needed.                                  #
# Copyright (c) [2023] [Christian Haitian]                       #
# MIT License                                                    #
##################################################################

event_num="3"
event_type="EV_KEY"
event_btn_a="BTN_EAST"
event_btn_b="BTN_SOUTH"

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  event_btn_b="BTN_EAST"
  event_btn_a="BTN_SOUTH"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]] \
     || [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] \
     || [[ -e "/dev/input/by-path/platform-gameforce-gamepad-joystick" ]]; then
  event_num="2"
fi

function Test_Button_A(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_a
}

function Test_Button_B(){
  evtest --query /dev/input/event$event_num $event_type $event_btn_b
}
