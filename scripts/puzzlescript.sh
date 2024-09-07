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

	# puzzlescript standalone package
	if [[ "$var" == "puzzlescript" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of puzzlescript
	  if [ ! -d "puzzlescript/" ]; then
		git clone --recursive https://github.com/nwhitehead/pzretro.git puzzlescript

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the puzzlescript libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/puzzlescriptsa-patch* puzzlescript/.
	  else
		echo " "
		echo "A puzzlescript libretro subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the puzzlescript folder and rerun this script."
		echo " "
		exit 1
	  fi

	  cd puzzlescript
 
	  sed -i '/cortex-a72/s//cortex-a35/g' Makefile
	  sed -i '/rpi4_64/s//rk3326/g' Makefile
      make platform=rk3326 -j$(nproc)
      if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error that occured while making the puzzlescript libretro core.  Stopping here."
        exit 1
      fi
      strip puzzlescript_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp puzzlescript_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/puzzlescript_libretro.so.commit

	  echo " "
	  echo "puzzlescript_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
