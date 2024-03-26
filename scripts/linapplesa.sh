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

	# linapple standalone package
	if [[ "$var" == "linapplesa" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of linapple
	  if [ ! -d "linapple/" ]; then
		git clone --recursive https://github.com/linappleii/linapple.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the linapple standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/linapplesa-patch* linapple/.
	  else
		echo " "
		echo "A linapple standalone subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the linapple folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( libzip-dev libsdl1.2-dev libsdl-image1.2-dev libcurl4-openssl-dev zlib1g-dev imagemagick )
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

	 cd linapple
	 
	 linapplesa_patches=$(find *.patch)
	 
	 if [[ ! -z "$linapplesa_patches" ]]; then
	  for patching in linapplesa-patch*
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

           make -j$(nproc)

           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the linapple standalone.  Stopping here."
             exit 1
           fi

           strip build/bin/linapple

	       #Get and build sdl12-compat to get the libSDL-1.2 libs needed for this emulator
	       git clone https://github.com/libsdl-org/sdl12-compat
	       cd sdl12-compat
	       mkdir build
	       cd build
	       cmake .. -DCMAKE_BUILD_TYPE=Release
	       make -j$(nproc)
	       cd ../../

           if [ ! -d "../linapplesa-$bitness/" ]; then
		     mkdir -v ../linapplesa-$bitness
	       fi

	       mkdir ../linapplesa-$bitness/libs
	       cp sdl12-compat/build/libSDL-1.2.so.* ../linapplesa-$bitness/libs/.
	       cp build/bin/linapple ../linapplesa-$bitness/.
           tar -zchvf ../linapplesa-$bitness/linapplesa_pkg_$(git rev-parse HEAD | cut -c -7).tar.gz ../linapplesa-$bitness/linapple ../linapplesa-$bitness/libs/

	       echo " "
	       echo "The linapple standalone executable has been created and has been placed in the rk3326_core_builds/linapplesa-$bitness subfolder"

	fi
