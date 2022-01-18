#!/bin/bash

if  [[ $1 == "retroarch" ]]; then
/usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
elif [[ $1 == "retroarch32" ]]; then
/usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
elif [[ $1 == "retrorun" ]]; then
/usr/bin/retrorun --triggers -n -s /roms/atomiswave -d /roms/bios /home/ark/.config/retroarch/cores/"$2"_libretro.so "$3"
else
/usr/bin/retrorun32 --triggers -n -s /roms/atomiswave -d /roms/bios /home/ark/.config/retroarch32/cores/"$2"_libretro.so "$3"
fi
