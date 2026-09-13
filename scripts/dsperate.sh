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

	# DSperate Standalone build
	if [[ "$var" == "dsperate" ]]  && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of dsperate
	  if [ ! -d "DSperate/" ]; then
		git clone --recursive https://github.com/beebono/DSperate.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the dsperate standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/dsperate-patch* dsperate/.
	  else
		echo " "
		echo "A dsperate subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the dsperate folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd DSperate

	 dsperate_patches=$(find *.patch)

	 if [[ ! -z "$dsperate_patches" ]]; then
	  for patching in dsperate-patch*
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

           #DS_ROMS=... DS_BIOS=... tools/pgo_refresh.sh
           cmake -DDSPERATE_TESTS=OFF \
                 -DDSPERATE_HEADLESS=OFF \
                 -DDSPERATE_WAYLAND=OFF \
                 -DDSPERATE_PGO=use --preset host
           sed -i '/fingerprint/d' pgo/aarch64/MANIFEST
           sed -i "1i fingerprint $(cat build/host/pgo-fingerprint)" pgo/aarch64/MANIFEST
           cmake -DDSPERATE_TESTS=OFF \
                 -DDSPERATE_HEADLESS=OFF \
                 -DDSPERATE_WAYLAND=OFF \
                 -DDSPERATE_PGO=use --preset host
           cmake --build --preset host

           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the dsperate standalone.  Stopping here."
              exit 1
           fi

           strip build/host/src/frontend/sdl/dsperate

           if [ ! -d "../dsperate-$bitness/" ]; then
	         mkdir -v ../dsperate-$bitness
           fi

	   cp build/host/src/frontend/sdl/dsperate ../dsperate-$bitness/.

	   echo " "
	   echo "The dsperate executable has been created and has been placed in the rk3326_core_builds/dsperate-$bitness subfolder"

	fi
