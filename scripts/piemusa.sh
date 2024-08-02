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

	# piemu Standalone build
	if [[ "$var" == "piemusa" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of piemu
	  if [ ! -d "piemu/" ]; then
		git clone --recursive https://github.com/YonKuma/piemu.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the piemu standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/piemusa-patch* piemu/.
	  else
		echo " "
		echo "A piemu subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the piemu folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd piemu
	 
	 piemusa_patches=$(find *.patch)
	 
	 if [[ ! -z "$piemusa_patches" ]]; then
	  for patching in piemusa-patch*
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
           cmake ..
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while verifying the necessary dependancies to build the newest piemu standalone.  Stopping here."
             exit 1
           fi
           make -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the piemu standalone.  Stopping here."
             exit 1
           fi
           strip piemu
           strip tools/mkpfi
           strip tools/pfar

           if [ ! -d "../../piemusa$bitness/" ]; then
		     mkdir -v ../../piemusa$bitness
	       fi

	       cp piemu ../../piemusa$bitness/piemu
	       cp tools/mkpfi ../../piemusa$bitness/mkpfi
	       cp tools/pfar ../../piemusa$bitness/pfar

	       echo " "
	       echo "The piemu executable and shared object has been created and has been placed in the rk3326_core_builds/piemusa$bitness subfolder"
	fi
