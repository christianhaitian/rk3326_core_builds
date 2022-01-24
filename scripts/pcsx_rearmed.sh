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

	# Libretro Pcsx_rearmed build
	if [[ "$var" == "pcsx_rearmed" || "$var" == "all" ]]; then
	 pcsx_rearmed_rumblepatch="no"
	 cd $cur_wd
	  if [ ! -d "pcsx_rearmed/" ]; then
		git clone https://github.com/libretro/pcsx_rearmed.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the pcsx_rearmed libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/pcsx_rearmed-patch* pcsx_rearmed/.
	  fi

	 cd pcsx_rearmed/

	 pcsx_rearmed_patches=$(find *.patch)

	 if [[ ! -z "$pcsx_rearmed_patches" ]]; then
	  for patching in pcsx_rearmed-patch*
	  do
		 if [[ $patching == *"rumble"* ]]; then
		   echo " "
		   echo "Skipping the $patching for now and making a note to apply that later"
		   sleep 3
		   pcsx_rearmed_rumblepatch="yes"
		 else  
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching" 
		 fi
	  done
	 fi
	  make clean

	  sed -i '/a53/s//a35/g' Makefile.libretro
 	  sed -i '/a72/s//a35/g' Makefile.libretro

	  if [[ "$bitness" == "64" ]]; then
	    make -f Makefile.libretro ARCH=arm64 BUILTIN_GPU=unai DYNAREC=ari64 platform=rpi3_64 -j$(nproc)
	  else
	    make -f Makefile.libretro HAVE_NEON=1 ARCH=arm BUILTIN_GPU=neon DYNAREC=ari64 platform=rpi3 -j$(nproc)
	  fi

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-pcsx_rearmed core.  Stopping here."
		exit 1
	  fi

	  strip pcsx_rearmed_libretro.so

	  if [ ! -d "../cores$bitness/" ]; then
		mkdir -v ../cores$bitness
	  fi

	  mv pcsx_rearmed_libretro.so ../cores$bitness/.

          if [[ "$bitness" == "32" ]]; then
            make -f Makefile.libretro HAVE_NEON=1 ARCH=arm BUILTIN_GPU=peops THREAD_RENDERING=1 DYNAREC=ari64 platform=rk3326
            if [[ $? != "0" ]]; then
                  echo " "
                  echo "There was an error while building the newest lr-pcsx_rearmed_peops core.  Stopping here."
                  exit 1
            fi
            mv pcsx_rearmed_libretro.so ../cores$bitness/pcsx_rearmed_peops_libretro.so
          fi

	  if [[ $pcsx_rearmed_rumblepatch == "yes" ]]; then
		for patching in pcsx_rearmed-patch*
		do
		  patch -Np1 < "$patching"
		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while patching in the rumble feature from $patching.  Stopping here."
			exit 1
		  fi
		  rm "$patching"

		  if [[ "$bitness" == "64" ]]; then
		    make -f Makefile.libretro ARCH=arm64 BUILTIN_GPU=unai DYNAREC=ari64 platform=rk3326_64 -j$(nproc)
		  else
		    make -f Makefile.libretro HAVE_NEON=1 ARCH=arm BUILTIN_GPU=neon DYNAREC=ari64 platform=rpi3 -j$(nproc)
		  fi

		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while building the newest lr-pcsx_rearmed core with the patched in rumble feature.  Stopping here."
			exit 1
		  fi

		  strip pcsx_rearmed_libretro.so
		  mv pcsx_rearmed_libretro.so pcsx_rearmed_rumble_libretro.so
		  cp pcsx_rearmed_rumble_libretro.so ../cores$bitness/.
		  echo " "
		  echo "pcsx_rearmed_libretro.so and pcsx_rearmed_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores32 subfolder"
	      gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	      echo $gitcommit > ../cores$bitness/pcsx_rearmed_rumble_libretro.so.commit
		done
	  fi

          if [[ "$bitness" == "32" ]]; then
            make -f Makefile.libretro HAVE_NEON=1 ARCH=arm BUILTIN_GPU=peops THREAD_RENDERING=1 DYNAREC=ari64 platform=rk3326
            if [[ $? != "0" ]]; then
                  echo " "
                  echo "There was an error while building the newest lr-pcsx_rearmed_rumble_peops core.  Stopping here."
                  exit 1
            fi
            mv pcsx_rearmed_libretro.so ../cores$bitness/pcsx_rearmed_rumble_peops_libretro.so
            gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
            echo $gitcommit > ../cores$bitness/$(basename $PWD)_libretro.so.commit

            echo " "
            echo "pcsx_rearmed_libretro.so has been created and has been placed in the rk3326_core_builds/cores32 subfolder"
          fi

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$bitness/$(basename $PWD)_libretro.so.commit

	  echo " "
	  echo "pcsx_rearmed_libretro.so has been created and has been placed in the rk3326_core_builds/cores32 subfolder"
	fi
