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

	# openmsx Standalone build
	if [[ "$var" == "openmsx" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of openmsx
	  if [ ! -d "openmsx/" ]; then
		git clone https://github.com/openMSX/openMSX.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the openmsx standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/openmsx-patch* openMSX/.
	  else
		echo " "
		echo "A openmsx subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the openmsx folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( tcl-dev libpng-dev zlib1g-dev libsdl2-ttf-dev libglew-dev libogg-dev libvorbis-dev libtheora-dev libasound2-dev )
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

	 cd openMSX
	 
	 openmsx_patches=$(find *.patch)
	 
	 if [[ ! -z "$openmsx_patches" ]]; then
	  for patching in openmsx-patch*
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

      ./configure
	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error that occured while verifying the necessary dependancies to build the newest openmsx standalone.  Stopping here."
		exit 1
	  fi

	  make -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest openmsx standalone.  Stopping here."
		exit 1
	  fi

	  strip derived/aarch64-linux-opt/bin/openmsx

	  if [ ! -d "../openmsx$bitness/" ]; then
		mkdir -v ../openmsx$bitness
	  fi

	  cp derived/aarch64-linux-opt/bin/openmsx ../openmsx$bitness/.
	  cp derived/aarch64-linux-opt/bin/openmsx .
	  tar -zchvf ../openmsx$bitness/openmsx_pkg_$(git rev-parse HEAD | cut -c -7).tar.gz share/ openmsx

	  echo " "
	  echo "The openmsx executable and openmsx_pkg_$(git rev-parse HEAD | cut -c -7).tar.gz package has been created and has been placed in the rk3326_core_builds/openmsx$bitness subfolder"

	fi
