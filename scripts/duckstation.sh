#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro duckstation package
	if [[ "$var" == "duckstation" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	 mkdir duckstation
	 cd duckstation
     wget -t 3 -T 60 --no-check-certificate https://www.duckstation.org/libretro/duckstation_libretro_linux_aarch64.zip
     unzip duckstation_libretro_linux_aarch64.zip -d ../cores$bitness
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while unpacking this core.  Did it download correctly? Is Internet active or did the download location change?  Stopping here."
		  exit 1
	 fi
	  gitcommit="N/A"
	  echo $gitcommit > ../cores$bitness/duckstation_libretro.so.commit

	  echo " "
	  echo "duckstation_libretro.so has been unpakcked and been placed in the rk3326_core_builds/cores$bitness subfolder"
	fi
