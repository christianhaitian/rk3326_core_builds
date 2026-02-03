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

	# ecwolf Standalone build
	if [[ "$var" == "ecwolfsa" ]]  && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of ecwolf
	  if [ ! -d "ecwolf/" ]; then
		git clone --recursive https://github.com/ECWolfEngine/ECWolf.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the ecwolf standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/ecwolf-patch* ecwolf/.
	  else
		echo " "
		echo "A ecwolf subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the ecwolf folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd ecwolf

	 ecwolf_patches=$(find *.patch)

	 if [[ ! -z "$ecwolf_patches" ]]; then
	  for patching in ecwolf-patch*
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
           cmake -DNO_GTK=ON -DCMAKE_BUILD_TYPE=Release ..
           make -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the ecwolf standalone.  Stopping here."
             exit 1
           fi
           strip ecwolf

           if [ ! -d "../../ecwolf-$bitness/" ]; then
	         mkdir -v ../../ecwolf-$bitness
           fi

	   cp ecwolf ../../ecwolf-$bitness/.
	   cp ecwolf.pk3 ../../ecwolf-$bitness/.

	   echo " "
	   echo "The ecwolf executable has been created and has been placed in the rk3326_core_builds/ecwolf-$bitness subfolder"

	fi
