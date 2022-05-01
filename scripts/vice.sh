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

	# Libretro vice build
	if [[ "$var" == "vice" || "$var" == "all" ]]; then
	 cd $cur_wd
	  if [ ! -d "vice-libretro/" ]; then
		git clone https://github.com/libretro/vice-libretro.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/vice-patch* vice-libretro/.
	  fi

	 cd vice-libretro/
	 
	 vice_patches=$(find *.patch)
	 
	 if [[ ! -z "$vice_patches" ]]; then
	  for patching in vice-patch*
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

     if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
      mkdir -v ../cores$(getconf LONG_BIT)
     fi

     gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)

     for EMUTYPE in x128 x64sc xscpu64 xplus4 xvic xcbm5x0 xcbm2 xpet x64
     do
       make clean
       if [[ "$bitness" == "32" ]]; then
         make EMUTYPE=${EMUTYPE} platform=classic_armv8_a35 -j$(nproc)       
       else
         make EMUTYPE=${EMUTYPE} -j$(nproc)
       fi
	   if [[ $? != "0" ]]; then
		 echo " "
		 echo "There was an error while building the newest lr-vice core of type ${EMUTYPE}.  Stopping here."
		 exit 1
	   fi
       strip vice_${EMUTYPE}_libretro.so
       mv vice_${EMUTYPE}_libretro.so ../cores$(getconf LONG_BIT)
       echo $gitcommit > ../cores$(getconf LONG_BIT)/vice_${EMUTYPE}_libretro.so.commit
     done

	 if [[ $? != "0" ]]; then
       echo " "
       echo "There was an error while building the newest lr-vice core.  Stopping here."
       exit 1
	 fi


	  echo " "
	  echo "128 x64sc xscpu64 xplus4 xvic xcbm5x0 xcbm2 xpet and x64 vice_libretro cores have been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
