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

	# fbneo Standalone build
	if [[ "$var" == "fbneosa" ]]  && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of fbneo
	  if [ ! -d "fbneo/" ]; then
		git clone --recursive https://github.com/finalburnneo/FBNeo fbneo

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the fbneo standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/fbneosa-patch* fbneo/.
	  else
		echo " "
		echo "A fbneo subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the fbneo folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd fbneo

	 git revert -n 5c8ee4d9773d74ae06d34887dcf8bb8da4f33e90 # Enable Killer Instinct driver
	 git revert -n 458f9551e69d34589538d5b3b26d5941174ae0f9 # Enable Killer Instinct driver
	 fbneosa_patches=$(find *.patch)

	 if [[ ! -z "$fbneosa_patches" ]]; then
	  for patching in fbneosa-patch*
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

           make sdl2 RELEASEBUILD=1 FORCE_SYSTEM_LIBPNG=1 -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the fbneo standalone.  Stopping here."
             exit 1
           fi
           strip fbneo

           if [ ! -d "../fbneosa$bitness/" ]; then
	     mkdir -v ../fbneosa$bitness
           fi

	   cp fbneo ../fbneosa$bitness/fbneo

	   echo " "
	   echo "The fbneo executable has been created and has been placed in the rk3326_core_builds/fbneosa$bitness subfolder"

	fi
