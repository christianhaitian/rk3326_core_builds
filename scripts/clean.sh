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

	# Clean up the directory and remove other lr gits and created cores
	if [ "$var" == "clean" ]; then
	  find -maxdepth 1 ! -name scripts ! -name patches ! -name .git ! -name docs -type d -not -path '.' -exec rm -rf {} +
	  mkdir cores$(getconf LONG_BIT)
	  echo " "
	  echo "Directory has been cleaned!"
	fi

	if [ -d "$cur_wd/cores$(getconf LONG_BIT)" ]; then
	  if [ "$(ls -A $cur_wd/cores$(getconf LONG_BIT))" ]; then
		echo " "
		echo "The cores$(getconf LONG_BIT) folder currently contains the following:"
		ls -l $cur_wd/cores$(getconf LONG_BIT)
	  fi
	fi
	if [ -d "$cur_wd/retroarch$(getconf LONG_BIT)" ]; then
	  if [ "$(ls -A $cur_wd/retroarch$(getconf LONG_BIT))" ]; then
		echo " "
		echo "The retroarch$(getconf LONG_BIT) folder currently contains the following:"
		ls -l $cur_wd/retroarch$(getconf LONG_BIT)
	  fi
	fi
	if [ -d "$cur_wd/es-fcamod" ]; then
	  if [ "$(ls -A $cur_wd/es-fcamod)" ]; then
		echo " "
		echo "The es-fcamod folder currently contains the following:"
		ls -l $cur_wd/es-fcamod
	  fi
	fi
