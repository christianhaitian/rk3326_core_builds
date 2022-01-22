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

	# hypseus Standalone build
	if [[ "$var" == "hypseus" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of hypseus
	  if [ ! -d "hypseus/" ]; then
		git clone https://github.com/btolab/hypseus.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the hypseus standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/hypseus-patch* hypseus/.
	  else
		echo " "
		echo "A hypseus subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the hypseus folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( autotools-dev cmake zlib1g-dev libogg-dev libvorbis-dev libmpeg2-4-dev libsdl2-image-dev )
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

	 cd hypseus
	 
	 hypseus_patches=$(find *.patch)
	 
	 if [[ ! -z "$hypseus_patches" ]]; then
	  for patching in hypseus-patch*
	  do
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
           if [ ! -d "build" ]; then
             mkdir build
             cd build
             cmake ../src
             if [[ $? != "0" ]]; then
		       echo " "
		       echo "There was an error that occured while verifying the necessary dependancies to build the newest hypseus standalone.  Stopping here."
               exit 1
             fi
           fi

           cd $cur_wd/hypseus/build
           make -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the hypseus.$(echo $patching | cut -d '-' -f 4 | cut -d '.' -f 1) standalone.  Stopping here."
             exit 1
           fi
           strip hypseus

           if [ ! -d "../../hypseus$bitness/" ]; then
		     mkdir -v ../../hypseus$bitness
	       fi

	       cp hypseus ../../hypseus$bitness/hypseus.$(echo $patching | cut -d '-' -f 4 | cut -d '.' -f 1)

	       echo " "
	       echo "The hypseus.$(echo $patching | cut -d '-' -f 4 | cut -d '.' -f 1) executable has been created and has been placed in the rk3326_core_builds/hypseus$bitness subfolder"

		   cd ..
		   rm "$patching"
	  done
	 fi
	fi
