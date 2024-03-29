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

	# applewin standalone package
	if [[ "$var" == "applewin" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of applewin
	  if [ ! -d "AppleWin/" ]; then
		git clone --recursive https://github.com/audetto/AppleWin.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the applewin standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/AppleWinsa-patch* AppleWin/.
	  else
		echo " "
		echo "A applewin standalone subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the applewin folder and rerun this script."
		echo " "
		exit 1
	  fi

	 # Ensure dependencies are installed and available
     neededlibs=( libyaml-dev libminizip-dev )
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

	 cd AppleWin
	 
	 applewinsa_patches=$(find *.patch)
	 
	 if [[ ! -z "$applewinsa_patches" ]]; then
	  for patching in AppleWinsa-patch*
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

           update-alternatives --set gcc "/usr/local/bin/gcc"
           update-alternatives --set g++ "/usr/local/bin/g++"
           if [ ! -d "build" ]; then
             mkdir build
             cd build
             cmake DCMAKE_BUILD_TYPE=RELEASE -DBUILD_LIBRETRO=ON ..
             if [[ $? != "0" ]]; then
		       echo " "
		       echo "There was an error that occured while verifying the necessary dependancies to build the applewin standalone.  Stopping here."
               exit 1
             fi
           fi

           make -j$(nproc)

           if [[ $? != "0" ]]; then
		     echo " "
             update-alternatives --set gcc "/usr/bin/gcc-8"
             update-alternatives --set g++ "/usr/bin/g++-8"
		     echo "There was an error that occured while making the applewin standalone.  Stopping here."
             exit 1
           fi
           update-alternatives --set gcc "/usr/bin/gcc-8"
           update-alternatives --set g++ "/usr/bin/g++-8"
           strip source/frontends/libretro/applewin_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp source/frontends/libretro/applewin_libretro.so ../../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../../cores$(getconf LONG_BIT)/applewin_libretro.so.commit

	  echo " "
	  echo "applewin_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"

	fi
