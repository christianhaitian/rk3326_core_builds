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
bitness="$bitness"

   # Libretro uae4arm build
   if [[ "$var" == "uae4arm" || "$var" == "all" ]]; then
	 cd $cur_wd
	 if [ ! -d "uae4arm/" ]; then
	   git clone --recursive https://github.com/Chips-fr/uae4arm-rpi uae4arm
	   if [[ $? != "0" ]]; then
	     echo " "
	     echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
	     exit 1
	   fi
	   cp patches/uae4arm-patch* uae4arm/.
	 fi

	 # Ensure dependencies are installed and available
	 neededlibs=( zlib1g-dev libmpg123-dev libflac-dev )
	 updateapt="N"
	 for libs in "${neededlibs[@]}"
	 do
            dpkg -s "${libs}" &>/dev/null
            if [[ $? != "0" ]]; then
              if [[ "$updateapt" == "N" ]]; then
                apt-get -y update
                updateapt="Y"
              fi
              apt-get -y install --no-install-recommends "${libs}"
              if [[ $? != "0" ]]; then
                echo " "
                echo "Could not install needed library ${libs}.  Stopping here so this can be reviewed."
                exit 1
              fi
            fi
     	 done

	 cd uae4arm/
	 
	 uae4arm_patches=$(find *.patch)
	 
	 if [[ ! -z "$uae4arm_patches" ]]; then
	  for patching in uae4arm-patch*
	  do
	     patch -Np1 < "$patching"
	     if [[ $? != "0" ]]; then
	       echo " "
	       echo "There was an error while applying $patching.  Stopping here."
	       exit 1
	     fi
	     rm "$patching" 
	  done
	 fi

	 if [[ "$bitness" == "64" ]]; then
	   make -f Makefile.libretro platform=unix_aarch64 "CPU_FLAGS=-mcpu=cortex-a35+crypto+crc" -j$(($(nproc) - 1))
	 else
	   sed -i '/a53/s//a35/' Makefile.libretro
	   sed -i '/rpi3/s//rk3326/' Makefile.libretro
	   make -f Makefile.libretro platform=rk3326 -j$(($(nproc) - 1))
	 fi

	 if [[ $? != "0" ]]; then
	   echo " "
	   echo "There was an error while building the newest lr-uae4arm core.  Stopping here."
	   exit 1
	 fi

	 strip uae4arm_libretro.so

	 if [ ! -d "../cores$bitness/" ]; then
	   mkdir -v ../cores$bitness
	 fi

	 cp uae4arm_libretro.so ../cores$bitness/.

	 gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	 echo $gitcommit > ../cores$bitness/$(basename $PWD)_libretro.so.commit

	 echo " "
	 echo "uae4arm_libretro.so has been created and has been placed in the rk3326_core_builds/cores$bitness subfolder"
   fi
