#!/bin/bash

if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ] || [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
  xres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)"
  yres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f2)"
else
  xres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f2)"
  yres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)"
fi

if [ "$#" -gt 2 ]; then
  game="${3}"
else
  game="${2}"
fi

if [[ $1 == "standalone-Rice" ]]; then
  if [[ $2 == "Widescreen_Aspect" ]]; then
    /opt/mupen64plus/mupen64plus --resolution "${xres}x${yres}" --plugindir /opt/mupen64plus --gfx mupen64plus-video-rice.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$game"
  else
    ricewidthhack=$(((yres * 4) / 3))
    /opt/mupen64plus/mupen64plus --resolution "${ricewidthhack}x${yres}" --plugindir /opt/mupen64plus --gfx mupen64plus-video-rice.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$game"
  fi
elif [[ $1 == "standalone-Glide64mk2" ]]; then
  if [[ $2 == "Widescreen_Aspect" ]]; then
    /opt/mupen64plus/mupen64plus --set Video-Glide64mk2[aspect]=1 --resolution "${xres}x${yres}" --plugindir /opt/mupen64plus --gfx mupen64plus-video-glide64mk2.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$game"
  else
    /opt/mupen64plus/mupen64plus --set Video-Glide64mk2[aspect]=-1 --resolution "${xres}x${yres}" --plugindir /opt/mupen64plus --gfx mupen64plus-video-glide64mk2.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$game"
  fi
elif [[ $1 == "standalone-GlideN64" ]]; then
  if [[ $2 == "Widescreen_Aspect" ]]; then
    /opt/mupen64plus/mupen64plus --set Video-GLideN64[AspectRatio]=3 --resolution "${xres}x${yres}" --plugindir /opt/mupen64plus --gfx mupen64plus-video-GLideN64.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$game"
  else
    /opt/mupen64plus/mupen64plus --set Video-GLideN64[AspectRatio]=1 --resolution "${xres}x${yres}" --plugindir /opt/mupen64plus --gfx mupen64plus-video-GLideN64.so --corelib /opt/mupen64plus/libmupen64plus.so.2 --datadir /opt/mupen64plus "$game"
  fi
else
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi

