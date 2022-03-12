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
tarname="mednafen-1.29.0.tar.xz"

	# mednafen package
	if [[ "$var" == "mednafen" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
     wget -t 3 -T 60 --no-check-certificate https://mednafen.github.io/releases/files/$tarname
     tar -xf $tarname
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while unpacking the mednafen source tarball.  Did it download correctly? Is Internet active or did the download location change?  Stopping here."
		  exit 1
	 fi
     
     rm -f $tarname
	 cd mednafen

     ./configure
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while configuring the mednafen source.  Stopping here."
		  exit 1
	 fi

     make -j$(nproc)
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while building the mednafen executable.  Stopping here."
		  exit 1
	 fi

	  if [ ! -d "../mednafen64/" ]; then
		mkdir -v ../mednafen64
	  fi

      strip src/mednafen
      cp src/mednafen ../mednafen64/.

	  echo " "
	  echo "mednafen has been created and has been placed in the rk3326_core_builds/mednafen64 subfolder"
	fi
