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
TAG="1.6.1"

	# yabasanshiro Standalone build
	if [[ "$var" == "yabasanshirosa-pirry" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of yabasanshiro
	  if [ ! -d "yabasanshiro-pirry/" ]; then
		git clone --recursive https://github.com/pirrypirrypirry/yabasanshiro-pirry.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the yabasanshiro standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/yabasanshirosa-pirry-patch* yabasanshiro-pirry/.
	  else
		echo " "
		echo "A yabasanshiro-pirry subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the yabasanshiro folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( git python3-pip cmake build-essential protobuf-compiler libglfw3-dev libprotobuf-dev libsecret-1-dev libshaderc-dev libssl-dev libsdl2-dev libboost-all-dev libvulkan-dev )
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

	 cd yabasanshiro-pirry
	 
	 yabasanshirosa_pirry_patches=$(find *.patch)
	 
	 if [[ ! -z "$yabasanshirosa_pirry_patches" ]]; then
	  for patching in yabasanshirosa-pirry-patch*
	  do
		 if [[ $patching == *"odroidgoa"* ]]; then
		   echo " "
		   echo "Skipping the $patching for now and making a note to apply that later"
		   sleep 3
		   yaba_menusizepatch="yes"
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

             mkdir build
             cd build
             cmake ../yabause \
                   -DYAB_PORTS=retro_arena \
                   -DYAB_WANT_DYNAREC_DEVMIYAX=ON \
                   -DYAB_WANT_ARM7=ON \
                   -DYAB_WANT_VULKAN=OFF \
                   -DUSE_EGL=ON \
                   -DCMAKE_BUILD_TYPE=Release \
                   -DCMAKE_C_FLAGS="-O3 -mcpu=cortex-a35 -fno-strict-aliasing -D_GNU_SOURCE -Wno-implicit-function-declaration -Wno-incompatible-pointer-types -Wno-int-conversion -flto=4 -fno-fat-lto-objects" \
                   -DCMAKE_CXX_FLAGS="-O3 -mcpu=cortex-a35 -fno-strict-aliasing -D_GNU_SOURCE -flto=4 -fno-fat-lto-objects" \
                   -DCMAKE_EXE_LINKER_FLAGS="-Wl,--allow-multiple-definition -flto=4 -O3 -mcpu=cortex-a35" \
                   -DCMAKE_AR=/usr/bin/gcc-ar -DCMAKE_RANLIB=/usr/bin/gcc-ranlib
             if [[ $? != "0" ]]; then
	       echo " "
	       echo "There was an error that occured while verifying the necessary dependancies to build the newest yabasanshiro standalone.  Stopping here."
               exit 1
             fi
             make -j$(nproc)
             if [[ $? != "0" ]]; then
	       echo " "
	       echo "There was an error that occured while making the yabasanshiro standalone.  Stopping here."
               exit 1
             fi
             strip -o yabasanshiro-pirry src/retro_arena/yabasanshiro

             if [ ! -d "../../yabasanshirosa-pirry$bitness/" ]; then
  	       mkdir -v ../../yabasanshirosa-pirry$bitness
             fi

	     cp yabasanshiro-pirry ../../yabasanshirosa-pirry$bitness/yabasanshiro-pirry

	     echo " "
	     echo "The yabasanshiro-pirry executable has been created and has been placed in the rk3326_core_builds/yabasanshirosa$bitness subfolder"
	  fi
