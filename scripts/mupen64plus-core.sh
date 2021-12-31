#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# mupen64plus-core Standalone build
	if [[ "$var" == "mupen64plus-core" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of mupen64plus-core
	  if [ ! -d "mupen64plus-core/" ]; then
        #git clone --depth=1 https://github.com/OtherCrashOverride/mupen64plus-core-go2 mupen64plus-core
		git clone https://github.com/mupen64plus/mupen64plus-core.git --recursive
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the mupen64plus-core standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/mupen64plus-core-patch* mupen64plus-core/.
	  else
		echo " "
		echo "A mupen64plus-core subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the mupen64plus-core folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd mupen64plus-core
	 
	 mupen64plus_core_patches=$(find *.patch)
	 
	 if [[ ! -z "$mupen64plus_core_patches" ]]; then
	  for patching in mupen64plus-core-patch*
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

      if [[ "$bitness" == "32" ]]; then
        _opts='USE_GLES=1 NEON=1 VFP_HARD=1 OPTFLAGS="-O3" V=1 PIE=1'
      else
        _opts='USE_GLES=1 NEW_DYNAREC=1 OPTFLAGS="-O3" V=1 PIE=1'
      fi
      
      export CFLAGS="$CFLAGS -Ofast -pipe -march=armv8-a+crc+simd -mtune=cortex-a35 -mcpu=cortex-a35 -U_FORTIFY_SOURCE -fno-stack-protector -fno-stack-clash-protection -ftree-vectorize -fdata-sections -ffunction-sections -fno-ident -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-math-errno -funsafe-math-optimizations -fomit-frame-pointer -ffast-math -fcommon"
      export CXXFLAGS="$CXXFLAGS $CFLAGS"
      
      make -C "projects/unix" clean
	  make -j$(($(nproc) - 1)) -C "projects/unix" $_opts all

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest mupen64plus-core standalone.  Stopping here."
		exit 1
	  fi

	  strip projects/unix/libmupen64plus.so.2.0.0

	  if [ ! -d "../mupen64plus-core$bitness/" ]; then
		mkdir -v ../mupen64plus-core$bitness
	  fi

	  cp projects/unix/libmupen64plus.so.2.0.0 ../mupen64plus-core$bitness/.
	  
	  echo " "
	  echo "mupen64plus-core executable has been placed in the rk3326_core_builds/mupen64plus-core$bitness subfolder"

	fi
