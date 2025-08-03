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
TAG="g4.14.2"

	# gzdoom Standalone build
	if [[ "$var" == "gzdoom" ]] && [[ "$bitness" == "64" ]]; then
	 chi_patch="no"
	 rg351v_patch="no"
	 cd $cur_wd

	  # Now we'll start the clone and build of gzdoom
	  if [ ! -d "gzdoom/" ]; then
		git clone --recursive https://github.com/coelckers/gzdoom.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the gzdoom standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/gzdoomsa-patch* gzdoom/.
	  else
		echo " "
		echo "A gzdoom subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the gzdoom folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( g++ make cmake libsdl2-dev git zlib1g-dev libbz2-dev libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm libgl1-mesa-dev tar libsdl1.2-dev libglew-dev )
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

     wget -t 3 -T 60 --no-check-certificate https://raw.githubusercontent.com/coelckers/ZMusic/master/CMakeLists.txt -O /dev/shm/CMakeLists.txt
     if [[ ! -f "/usr/lib/libzmusic.so.$(grep 'VERSION 1.' /dev/shm/CMakeLists.txt | cut -d ' ' -f 2)" ]]; then
       echo "We need to build and install the zmusic library version $(grep 'VERSION 1.' /dev/shm/CMakeLists.txt | cut -d ' ' -f 2)"
       git clone https://github.com/coelckers/ZMusic.git zmusic
       cd zmusic
       mkdir build
       cd build
       cmake .. -DCMAKE_BUILD_TYPE=Release
       if [[ $? != "0" ]]; then
          echo " "
          echo "There was an error that occured while verifying the necessary dependancies to build the newest ZMusic.  Stopping here."
          exit 1
       fi

       make -j$(nproc)
       if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error that occured while making the latest ZMusic.  Stopping here."
          exit 1
       fi
       make install
     else
       echo "We already have the newest version ($(grep 'VERSION 1.' /dev/shm/CMakeLists.txt | cut -d ' ' -f 2)) of the zmusic library installed."
     fi

	 cd $cur_wd/gzdoom
	 git checkout $TAG
	 git config --local --add remote.origin.fetch +refs/tags/*:refs/tags/*
	 git pull
	 
	 gzdoomsa_patches=$(find *.patch)
	 
	 if [[ ! -z "$gzdoomsa_patches" ]]; then
	  for patching in gzdoomsa-patch*
	  do
		 if [[ $patching == *"chi"* ]]; then
		   echo " "
		   echo "Skipping the $patching for now and making a note to apply that later"
		   sleep 3
		   chi_patch="yes"
		 elif [[ $patching == *"351v"* ]]; then
                   echo " "
                   echo "Skipping the $patching for now and making a note to apply that later"
                   sleep 3
                   rg351v_patch="yes"
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

           cmake -DNO_GTK=ON \
                 -DCMAKE_BUILD_TYPE=Release \
                 -DHAVE_GLES2=ON \
                 -DHAVE_VULKAN=OFF \
                 ..
           if [[ $? != "0" ]]; then
	         echo " "
	         echo "There was an error that occured while verifying the necessary dependancies to build the newest gzdoom standalone.  Stopping here."
             exit 1
           fi

           make -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the gzdoom standalone.  Stopping here."
             exit 1
           fi

           strip gzdoom

           if [ ! -d "../../gzdoom$bitness/" ]; then
		     mkdir -v ../../gzdoom$bitness
	       fi

	       cp gzdoom ../../gzdoom$bitness/gzdoom
	       cp *.pk3 ../../gzdoom$bitness/

          if [[ $rg351v_patch == "yes" ]]; then
                cd ..
                for patching in gzdoomsa-patch-351v*
                do
                  patch -Np1 < "$patching"
                  if [[ $? != "0" ]]; then
                        echo " "
                        echo "There was an error while patching in the key fix for the RG351V from $patching.  Stopping here."
                        exit 1
                  fi
                  rm "$patching"
                done
                cd build
                make -j$(nproc)
                if [[ $? != "0" ]]; then
                     echo " "
                     echo "There was an error that occured while making the gzdoom standalone for the RG351V.  Stopping here."
                     exit 1
                fi
                strip gzdoom

                cp gzdoom ../../gzdoom$bitness/gzdoom.351v
                echo " "
                echo "The gzdoom.351v executable file haa been created and been placed in the rk3326_core_builds/gzdoom$bitness subfolder"
          fi

	  if [[ ${chi_patch} == "yes" ]]; then
                cd ..
		for patching in gzdoomsa-patch-chi*
		do
		  patch -Np1 < "$patching"
		  if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while patching in the key fix for the Gameforce Chi from $patching.  Stopping here."
			exit 1
		  fi
		  rm "$patching"
		done
		cd build
		make -j$(nproc)
		if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the gzdoom standalone for the chi.  Stopping here."
		     exit 1
		fi
		strip gzdoom

		cp gzdoom ../../gzdoom$bitness/gzdoom.chi
		echo " "
		echo "The gzdoom.chi executable file haa been created and been placed in the rk3326_core_builds/gzdoom$bitness subfolder"
	  fi

	fi
