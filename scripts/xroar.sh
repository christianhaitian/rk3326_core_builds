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
tarname="xroar-1.5.2.tar.gz"
dirname="${tarname%.*.*}"

	# xroar package
	if [[ "$var" == "xroar" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
     wget -t 3 -T 60 --no-check-certificate https://www.6809.org.uk/xroar/dl/$tarname
     tar -xf $tarname
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while unpacking the xroar source tarball.  Did it download correctly? Is Internet active or did the download location change?  Stopping here."
		  exit 1
	 fi
     
     rm -f $tarname
	 cd $dirname

     ./configure --enable-dragon --enable-coco3 --enable-mc10 --without-gtk2 \
       --without-gtkgl --without-cocoa --without-oss --without-pulse \
       --without-coreaudio --without-x

     if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while configuring the xroar source.  Stopping here."
		  exit 1
	 fi

     make -j$(nproc)
     if [[ $? != "0" ]]; then
       echo " "
		  echo "There was an error while building the xroar executable.  Stopping here."
		  exit 1
	 fi

	  if [ ! -d "../xroar64/" ]; then
		mkdir -v ../xroar64
	  fi

      strip src/xroar
      cp src/xroar ../xroar64/.

	  echo " "
	  echo "xroar has been created and has been placed in the rk3326_core_builds/xroar64 subfolder"
	fi
