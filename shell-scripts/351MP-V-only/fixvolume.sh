#!/bin/bash
# Only used for the RG351MP during initial boot to fix volume output path
amixer -c 0 cset iface=MIXER,name='Playback Path' SPK_HP
exit 0
