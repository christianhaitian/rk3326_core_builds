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

	# Advanced Drastic Standalone build (somewhat)
	if [[ "$var" == "advanced_drastic" ]]  && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of advanced_drastic
	  if [ ! -d "advanced_drastic/" ]; then
		git clone --recursive https://github.com/trngaje/advanced_drastic.git

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the advanced_drastic standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/advanced_drastic-patch* advanced_drastic/.
	  else
		echo " "
		echo "A advanced_drastic subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the advanced_drastic folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd advanced_drastic

	 advanced_drastic_patches=$(find *.patch)

	 if [[ ! -z "$advanced_drastic_patches" ]]; then
	  for patching in advanced_drastic-patch*
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

	  git clone --recursive https://github.com/trngaje/drastic_layout.git
	  mv drastic_layout/bg resources/
	  mv drastic_v2522 drastic
	  mv libs/arkos/* libs/.
	  rm -rf devices drastic_layout .git* config/* launch.sh history.md launch_rocknix.sh drastic_* README.md scripts/ libs/*/

           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the advanced_drastic standalone.  Stopping here."
              exit 1
           fi

           if [ ! -d "../advanced_drastic-$bitness/" ]; then
	         mkdir -v ../advanced_drastic-$bitness
           fi

           cd ..
	   cp -rf advanced_drastic/ advanced_drastic-$bitness/.
	   rm -rf advanced_drastic/

	   echo " "
	   echo "The advanced_drastic executable has been created and has been placed in the rk3326_core_builds/advanced_drastic-$bitness subfolder"

	fi
