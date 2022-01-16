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

	# yabasanshiro Standalone build
	if [[ "$var" == "yabasanshirosa" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of yabasanshiro
	  if [ ! -d "yabasanshiro/" ]; then
		git clone --recursive https://github.com/devmiyax/yabause -b pi4 yabasanshiro

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yabasanshiro standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yabasanshirosa-patch* yabasanshiro/.
	  else
		echo " "
		echo "A yabasanshiro subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the yabasanshiro folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( git python-pip cmake build-essential protobuf-compiler libprotobuf-dev libsecret-1-dev libssl-dev libsdl2-dev libboost-all-dev )
     updateapt="N"
     for libs in "${neededlibs[@]}"
     do
          dpkg -s "${libs}" &>/dev/null
          if [[ $? != "0" ]]; then
           if [[ "$updateapt" == "N" ]]; then
            apt-get -y update
            updateapt="Y"
           fi
           apt-get -y install "${libs}"
           if [[ $? != "0" ]]; then
            echo " "
            echo "Could not install needed library ${libs}.  Stopping here so this can be reviewed."
            exit 1
           fi
          fi
     done

	 cd yabasanshiro
	 
	 yabasanshirosa_patches=$(find *.patch)
	 
	 if [[ ! -z "$yabasanshirosa_patches" ]]; then
	  for patching in yabasanshirosa-patch*
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

             mkdir build
             cd build
             if [[ "$bitness" == "64" ]]; then
               cmake ../yabause \
                     -DYAB_PORTS=retro_arena \
                     -DYAB_WANT_DYNAREC_DEVMIYAX=ON \
                     -DYAB_WANT_ARM7=ON \
                     -DYAB_WANT_VULKAN=OFF \
                     -DCMAKE_TOOLCHAIN_FILE=../yabause/src/retro_arena/n2.cmake \
                     -DCMAKE_BUILD_TYPE=Release
               if [[ $? != "0" ]]; then
		       echo " "
		       echo "There was an error that occured while verifying the necessary dependancies to build the newest yabasanshiro standalone.  Stopping here."
                       exit 1
               fi
            else
               cmake ../yabause \
                     -DYAB_PORTS=retro_arena \
                     -DYAB_WANT_DYNAREC_DEVMIYAX=ON \
                     -DYAB_WANT_ARM7=ON \
                     -DYAB_WANT_VULKAN=OFF \
                     -DCMAKE_TOOLCHAIN_FILE=../yabause/src/retro_arena/pi4.cmake \
                     -DCMAKE_BUILD_TYPE=Release
               if [[ $? != "0" ]]; then
                       echo " "
                       echo "There was an error that occured while verifying the necessary dependancies to build the newest yabasanshiro s$
                       exit 1
               fi
            fi
           make -j$(($(nproc) - 1))
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the yabasanshiro standalone.  Stopping here."
             exit 1
           fi
           strip src/retro_arena/yabasanshiro

           if [ ! -d "../../yabasanshirosa$bitness/" ]; then
		     mkdir -v ../../yabasanshirosa$bitness
	       fi

	       cp src/retro_arena/yabasanshiro ../../yabasanshirosa$bitness/yabasanshiro

	       echo " "
	       echo "The yabasanshiro executable has been created and has been placed in the rk3326_core_builds/yabasanshirosa$bitness subfolder"

	fi
