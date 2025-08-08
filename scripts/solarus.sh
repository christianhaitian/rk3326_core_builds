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

	# Solarus Standalone build
	if [[ "$var" == "solarus" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of solarus
	  if [ ! -d "solarus/" ]; then
		git clone --recursive https://gitlab.com/solarus-games/solarus.git -b release-2.0.1

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the solarus standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/solarus-patch* solarus/.
	  else
		echo " "
		echo "A solarus subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the solarus folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( build-essential cmake pkg-config libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libluajit-5.1-dev libphysfs-dev libopenal-dev libvorbis-dev libmodplug-dev qtbase5-dev qttools5-dev qttools5-dev-tools libglm-dev )
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

	 cd solarus
	 
	 solarus_patches=$(find *.patch)
	 
	 if [[ ! -z "$solarus_patches" ]]; then
	  for patching in solarus-patch*
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
	  cmake -DSOLARUS_GL_ES=ON -DSOLARUS_GUI=OFF -DSOLARUS_USE_LUAJIT=ON -DSOLARUS_TESTS=OFF ..
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest solarus standalone.  Stopping here."
		exit 1
	  fi

	  strip solarus-run
	  strip libsolarus.so.1.*

	  if [ ! -d "../../solarus$bitness/" ]; then
		mkdir -v ../../solarus$bitness
	  fi

	  cp solarus-run ../../solarus$bitness/.
	  cp libsolarus.so.* ../../solarus$bitness/.
	  
	  echo " "
	  echo "solarus-run executable and related files have been created and has been placed in the rk3326_core_builds/solarus$bitness subfolder"

	fi
