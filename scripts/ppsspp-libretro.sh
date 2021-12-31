#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# PPSSPP Libretro build
	if [[ "$var" == "ppsspp-libretro" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of PPSSPP-libretro
	  if [ ! -d "ppsspp/" ]; then
		git clone https://github.com/hrydgard/ppsspp.git --recursive
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the ppsspp standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/ppsspp-patch* ppsspp/.
	  else
		echo " "
		echo "A ppsspp subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the ppsspp folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( libx11-dev libsm-dev libxext-dev git cmake mercurial libudev-dev libdrm-dev zlib1g-dev pkg-config libasound2-dev libfreetype6-dev libx11-xcb1 libxcb-dri2-0 )
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

	 cd ppsspp/ffmpeg
	 ./linux_arm64.sh
	 cd ..
	 
	 ppsspp_patches=$(find *.patch)
	 
	 if [[ ! -z "$ppsspp_patches" ]]; then
	  for patching in ppsspp-patch*
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
	  cmake -DLIBRETRO=ON -DUSING_FBDEV=ON -DUSING_EGL=ON -DUSING_GLES2=ON -DUSE_FFMPEG=YES -DUSE_SYSTEM_FFMPEG=NO ../.
	  make -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest ppsspp libretro core.  Stopping here."
		exit 1
	  fi

	  strip lib/ppsspp_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

      cp lib/ppsspp_libretro.so ../../cores$(getconf LONG_BIT)/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../cores$bitness/ppsspp_libretro.so.commit

	  echo " "
	  echo "ppsspp_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"

	fi
