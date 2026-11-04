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

	# linapple standalone package
	if [[ "$var" == "linapplesa" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of linapple
	  if [ ! -d "linapple/" ]; then
		git clone --recursive https://github.com/christianhaitian/linapple.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the linapple standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/linapplesa-patch* linapple/.
	  else
		echo " "
		echo "A linapple standalone subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the linapple folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd linapple
	 
	 linapplesa_patches=$(find *.patch)
	 
	 if [[ ! -z "$linapplesa_patches" ]]; then
	  for patching in linapplesa-patch*
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

           make SDL2=1 clean
           make SDL2=1

           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the linapple standalone.  Stopping here."
             exit 1
           fi

           strip build/bin/linapple

           if [ ! -d "../linapplesa-$bitness/" ]; then
	     mkdir -v ../linapplesa-$bitness
	   fi

	   cp build/bin/linapple ../linapplesa-$bitness/.

	       echo " "
	       echo "The linapple standalone executable has been created and has been placed in the rk3326_core_builds/linapplesa-$bitness subfolder"

	fi
