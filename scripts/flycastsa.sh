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
TAG="v1.0"

	# flycastsa build
	if [[ "$var" == "flycastsa" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "flycast/" ]; then
		git clone --recursive https://github.com/flyinghead/flycast.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the flycast standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/flycastsa-patch* flycast/.
	  fi

	 cd flycast/
	 git checkout ${TAG}
	 sed -i 's/\-O[23]/-Ofast/' CMakeLists.txt
	 
	 flycastsa_patches=$(find *.patch)
	 
	 if [[ ! -z "$flycastsa_patches" ]]; then
	  for patching in flycastsa-patch*
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

      if [[ "$0" != *"builds-alt"* ]]; then
        update-alternatives --set gcc "/usr/local/bin/aarch64-linux-gnu-gcc-13"
        update-alternatives --set g++ "/usr/local/bin/aarch64-linux-gnu-g++-13"
        export CPLUS_INCLUDE_PATH=/usr/include/c++/13:/usr/include/c++/13/backward:/usr/local/include/c++/13/aarch64-linux-gnu
      fi

	  cd ..
	  mkdir flycast-build
	  cd flycast-build

	  export CXXFLAGS="${CXXFLAGS} -Wno-error=array-bounds"
	  cmake -S ../flycast \
	    -DCMAKE_RULE_MESSAGES=OFF \
	    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
	    -DCMAKE_BUILD_TYPE="Release" \
	    -DCMAKE_C_FLAGS_RELEASE="-DNDEBUG" \
	    -DCMAKE_CXX_FLAGS_RELEASE="-DNDEBUG" \
	    -DWITH_SYSTEM_ZLIB=ON \
	    -DUSE_PULSEAUDIO=OFF \
	    -DUSE_OPENMP=ON \
	    -DUSE_VULKAN=OFF \
	    -DUSE_GLES=ON -B .
	  
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
	    if [[ "$0" != *"builds-alt"* ]]; then
		  update-alternatives --set gcc "/usr/bin/gcc-8"
		  update-alternatives --set g++ "/usr/bin/g++-8"
		  unset CPLUS_INCLUDE_PATH
		fi
		echo " "
		echo "There was an error while building the newest flycast standalone emulator.  Stopping here."
		exit 1
	  fi

      if [[ "$0" != *"builds-alt"* ]]; then
	    update-alternatives --set gcc "/usr/bin/gcc-8"
	    update-alternatives --set g++ "/usr/bin/g++-8"
	    unset CPLUS_INCLUDE_PATH
	  fi

	  strip flycast

	  if [ ! -d "../flycastsa-$(getconf LONG_BIT)/" ]; then
		mkdir -v ../flycastsa-$(getconf LONG_BIT)
	  fi

	  cp flycast ../flycastsa-$(getconf LONG_BIT)/flycast-rk3326

	  echo " "
	  echo "Flycast standalone has been created and has been placed in the rk3326_core_builds/flycastsa-$(getconf LONG_BIT) subfolder"
	fi
