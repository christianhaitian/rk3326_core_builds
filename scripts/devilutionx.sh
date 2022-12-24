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
devilutionX_git="https://github.com/diasurgical/devilutionX.git"
divXtag="1.4.1"
bitness="$(getconf LONG_BIT)"

	# Nxengine-evo build
	if [[ "$var" == "devilutionx" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "devilutionX/" ]; then
		git clone --recursive $devilutionX_git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the devilutionX git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/devilutionx-patch* devilutionX/.
	  fi

	 cd devilutionX/

     git checkout tags/${divXtag}

     if [[ $? != "0" ]]; then
       echo " "
       echo "There was an error while checking out the tag ${divXtag} version of devilutionX.  Stopping here."
       exit 1
     fi

	 devilutionx_patches=$(find *.patch)
	 
	  if [[ ! -z "$devilutionx_patches" ]]; then
	  for patching in devilutionx-patch*
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

	  cmake -S. -Bbuild -DCMAKE_BUILD_TYPE="Release" -DDISABLE_ZERO_TIER=ON -DBUILD_TESTING=OFF -DBUILD_ASSETS_MPQ=OFF -DDEBUG=OFF -DPREFILL_PLAYER_NAME=ON

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while configuring the tag ${divXtag} version of devilutionX for building.  Stopping here."
		exit 1
	  fi

      cmake --build build -j $(getconf _NPROCESSORS_ONLN)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest devilutionX.  Stopping here."
		exit 1
	  fi

	  strip build/devilutionx

	  if [ ! -d "../devilutionX-$bitness/" ]; then
		mkdir -v ../devilutionX-$bitness
	  fi

      cp build/devilutionx ../devilutionX-$bitness/.
      cp -rf build/assets/ ../devilutionX-$bitness/
      cp LICENSE ../devilutionX-$bitness/.
      cp README.md ../devilutionX-$bitness/.

	  echo " "
	  echo "devilutionX has been created and has been placed in the rk3326_core_builds/devilutionX-$bitness subfolder along with needed assets"
	fi
