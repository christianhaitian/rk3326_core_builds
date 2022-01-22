#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3326 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

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
