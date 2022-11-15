#!/bin/bash

if test -z "$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep 'cap32_model' | tr -d '\0')"
then
  sed -i -e '$acap32_model \= "6128+ (experimental)"' /home/ark/.config/retroarch/retroarch-core-options.cfg
fi

if test -z "$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep 'cap32_gfx_colors' | tr -d '\0')"
then
  sed -i -e '$acap32_gfx_colors \= "24bit"' /home/ark/.config/retroarch/retroarch-core-options.cfg
fi

cpcmode=$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep "cap32_model" | grep -oP '"\K[^"]+')
colordepth=$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep "cap32_gfx_colors" | grep -oP '"\K[^"]+')
sed -i '/cap32_model \=/c\cap32_model \= "6128+ (experimental)"' /home/ark/.config/retroarch/retroarch-core-options.cfg
sed -i '/cap32_gfx_colors \=/c\cap32_gfx_colors \= "24bit"' /home/ark/.config/retroarch/retroarch-core-options.cfg
/usr/local/bin/${1} -L /home/ark/.config/${1}/cores/${2}_libretro.so "${3}"

sed -i "/cap32_model \=/c\cap32_model \= \"${cpcmode}\"" /home/ark/.config/retroarch/retroarch-core-options.cfg
sed -i "/cap32_gfx_colors \=/c\cap32_gfx_colors \= \"${colordepth}\"" /home/ark/.config/retroarch/retroarch-core-options.cfg
