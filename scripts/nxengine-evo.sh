#!/bin/bash
cur_wd="$PWD"
nxengevo_git="https://github.com/nxengine/nxengine-evo.git"
bitness="$(getconf LONG_BIT)"

	# Nxengine-evo build
	if [[ "$var" == "nxengine-evo" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "nxengine-evo/" ]; then
		git clone $nxengevo_git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the nxengine-evo git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/nxengine-evo-patch* nxengine-evo/.
	  fi

	 cd nxengine-evo/
	 
	 nxengine_patches=$(find *.patch)
	 
	  if [[ ! -z "$nxengine_patches" ]]; then
	  for patching in nxengine-evo-patch*
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
	  cmake -DCMAKE_BUILD_TYPE=Release ..
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest nxengine-evo engine.  Stopping here."
		exit 1
	  fi

	  strip nxextract
	  strip nxengine-evo

	  if [ ! -d "../../nxengine-evo-$bitness/" ]; then
		mkdir -v ../../nxengine-evo-$bitness
	  fi

	  cp nxengine-evo ../../nxengine-evo-$bitness/.
	  cp nxextract ../../nxengine-evo-$bitness/.
	  cp -rf ../data/ ../../nxengine-evo-$bitness/

	  #Get language pack
	  wget -t 3 -T 60 --no-check-certificate https://github.com/nxengine/translations/releases/download/v1.14/all.zip
	  unzip -o all.zip -d ../../nxengine-evo-$bitness/

	  echo " "
	  echo "nxengine-evo has been created and has been placed in the rk3326_core_builds/nxengine-evo-$bitness subfolder"
	fi
