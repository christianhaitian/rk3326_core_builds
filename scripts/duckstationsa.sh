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

	# Duckstation standalone package
	if [[ "$var" == "duckstationsa" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of duckstation
	  if [ ! -d "duckstation/" ]; then
		git clone --recursive https://github.com/stenzek/duckstation.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the duckstation standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/duckstationsa-patch* duckstation/.
	  else
		echo " "
		echo "A duckstation standalone subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the duckstation folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=(  )
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

	 cd duckstation
     git checkout 5ab5070d73f1acc51e064bd96be4ba6ce3c06f5c
	 
	 duckstationsa_patches=$(find *.patch)
	 
	 if [[ ! -z "$duckstationsa_patches" ]]; then
	  for patching in duckstationsa-patch*
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

           if [ ! -d "build" ]; then
             mkdir build
             cd build
             cmake -DANDROID=OFF \
	               -DENABLE_DISCORD_PRESENCE=OFF \
	               -DUSE_X11=OFF \
	               -DBUILD_QT_FRONTEND=OFF \
	               -DBUILD_NOGUI_FRONTEND=ON \
	               -DCMAKE_BUILD_TYPE=Release \
	               -DBUILD_SHARED_LIBS=OFF \
	               -DUSE_SDL2=ON \
	               -DENABLE_CHEEVOS=ON \
                   -DUSE_FBDEV=OFF \
                   -DUSE_EVDEV=ON \
                   -DUSE_EGL=ON \
                   -DUSE_DRMKMS=ON \
                   -DUSE_MALI=OFF \
                   ..
             if [[ $? != "0" ]]; then
		       echo " "
		       echo "There was an error that occured while verifying the necessary dependancies to build the duckstation standalone.  Stopping here."
               exit 1
             fi
           fi

           make -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the duckstation standalone.  Stopping here."
             exit 1
           fi
           strip bin/duckstation-nogui

           if [ ! -d "../../duckstationsa-$bitness/" ]; then
		     mkdir -v ../../duckstationsa-$bitness
	       fi

	       cp bin/duckstation-nogui ../../duckstationsa-$bitness/duckstation-nogui
           tar -zchvf ../../duckstationsa-$bitness/duckstationsa_pkg_$(git rev-parse HEAD | cut -c -7).tar.gz bin/duckstation-nogui ../data/database/ ../data/resources/ ../data/shaders/ 

	       echo " "
	       echo "The duckstation standalone executable has been created and has been placed in the rk3326_core_builds/duckstationsa-$bitness subfolder"

	fi
