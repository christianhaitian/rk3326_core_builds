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

	# amiberry package
	if [[ "$var" == "amiberry" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
     git clone --recursive https://github.com/BlitterStudio/amiberry.git
	 if [[ $? != "0" ]]; then
	   echo " "
	   echo "There was an error while cloning the mgba standalone git.  Is Internet active or did the git location change?  Stopping here."
	   exit 1
	 fi

     cp patches/amiberrysa-patch* amiberry/.
	 cd amiberry

	 amiberry_patches=$(find *.patch)
	 
	 if [[ ! -z "$amiberry_patches" ]]; then
	  for patching in amiberrysa-patch*
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

 	 # Ensure dependencies are installed and available
	 neededlibs=( autoconf libserialport-dev libportmidi-dev )
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
 
     git submodule update --init  
     make -j$(nproc) capsimg
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while building the capsimg.so library.  Stopping here."
		  exit 1
	 fi

     sed -i 's/\-O[23]//' Makefile

     make -j$(nproc) PLATFORM=RK3326
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while building the amiberry executable.  Stopping here."
		  exit 1
	 fi

	  if [ ! -d "../amiberry64/" ]; then
		mkdir -v ../amiberry64
	  fi

      strip amiberry
      strip capsimg.so*
      cp capsimg.so* ../amiberry64/
      cp -a amiberry* ../amiberry64/
      cp -a conf ../amiberry64/
      cp -a data ../amiberry64/
      cp -a savestates ../amiberry64/
      cp -a screenshots ../amiberry64/
      cp -a whdboot ../amiberry64/
      echo "03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,guide:b10,leftstick:b8,lefttrigger:b13,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux," >> ../amiberry64/conf/gamecontrollerdb.txt

      #UAE="../amiberry64/conf/*.uae"
      #for i in ${UAE}
      #do 
      #    echo -e "gfx_center_vertical=smart\ngfx_center_horizontal=smart" >> ${i}
      #done

	  echo " "
	  echo "amiberry has been created and has been placed in the rk3326_core_builds/amiberry64 subfolder"
	fi
