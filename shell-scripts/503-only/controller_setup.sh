#!/bin/bash

##################################################################
# Created by Christian Haitian for use to create new retroarch   #
# controller configurations for new controllers added to         #
# emulationstation's controller input configuration file         #
##################################################################

es_input_file_location="/etc/emulationstation/es_input.cfg"
ra_config_paths=( "/home/ark/.config/retroarch" "/home/ark/.config/retroarch32" )

last_controller_config="$(cat ${es_input_file_location} | grep '<inputConfig type="joystick"' | tail -1 | grep -o -P -w 'deviceName="\K[^"]+')"

if test -z "${1}"
then
  controller="${last_controller_config}"
else
  controller="${1}"
fi

if [[ -f "${ra_config_paths[0]}/autoconfig/udev/${controller}.cfg" ]]; then
  echo "\"${controller}\" controller configuration already exists for retroarch!"
  exit 0
fi

button_list=( left right up down a b x y leftshoulder rightshoulder \
              lefttrigger righttrigger leftthumb rightthumb select \
			        start leftanalogdown leftanalogup leftanalogleft leftanalogright \
			        rightanalogdown rightanalogup rightanalogleft rightanalogright )

printf "\nController name: $controller\n"

for button in "${button_list[@]}"
do
    isitahatoranalog="$(cat ${es_input_file_location} | sed -n "/${controller}/, /inputConfig/p" | grep "name=\"${button}\"" | grep -o -P -w "type=.{0,5}" | cut -c5- | cut -d '"' -f2)"

    unset value
    unset axis

    if [[ "$isitahatoranalog" == "hat" ]]; then
      value="hat found"
    elif [[ "$isitahatoranalog" == "axis" ]]; then
	    axis="$(cat ${es_input_file_location} | sed -n "/${controller}/, /inputConfig/p" | grep "name=\"${button}\"" | grep -o -P -w "value=.{0,5}" | cut -c5- | cut -d '"' -f2)"
      if [[ "${axis}" == *"-"* ]]; then
	    axis="-"
	  else
	    axis="+"
      fi
    fi

    get_button="$(cat ${es_input_file_location} | sed -n "/${controller}/, /inputConfig/p" | grep "name=\"${button}\"" | grep -o -P -w 'id="\K[^"]+')"
    
    #let a="${#button} + 3"
    #test_button="$(timeout 0.1s sdljoytest | grep 'retrogame_joypad,')"
    #test_buttons="$(echo ${test_button}_button | tr , '\n' | grep -o -P -w "${button}:.{0,4}" | cut -c${a}-)"

  if test -z "$axis"
	then
    if test ! -z "$value"
	  then
        [ ! -z $get_button ] && echo "$button = h${get_button}${button}"
		    retropad+=("h${get_button}${button}")
	  else
        [ ! -z $get_button ] && echo "$button = $get_button"
        retropad+=("${get_button}")
	  fi
	else
	  [ ! -z $get_button ] && echo "$button = $axis$get_button"
    retropad+=("${axis}${get_button}")
	fi
done

printf "\n"

let i=0

for raconfigcreate in "${ra_config_paths[@]}"
do
    echo "input_driver = \"udev\"" > "${raconfigcreate}/autoconfig/udev/${controller}".cfg
    echo "input_device = \"${controller}\"" >> "${raconfigcreate}/autoconfig/udev/${controller}".cfg
done

for retroA in "${retropad[@]}"
do
    retropad_list=( input_left_btn input_right_btn input_up_btn input_down_btn \
	                input_a_btn input_b_btn input_x_btn input_y_btn input_l_btn \
					        input_r_btn input_l2_btn input_r2_btn input_l3_btn input_r3_btn \
					        input_select_btn input_start_btn input_l_y_plus_axis input_l_y_minus_axis \
					        input_l_x_minus_axis input_l_x_plus_axis input_r_y_plus_axis \
					        input_r_y_minus_axis input_r_x_minus_axis input_r_x_plus_axis )
					 
    for raconfig in "${ra_config_paths[@]}"
    do
        [ ! -z "${retroA}" ] && echo "${retropad_list[$i]} = \"${retroA}\"" >> "${raconfig}/autoconfig/udev/${controller}.cfg"
    done
	  let i++
done

printf "\n"
