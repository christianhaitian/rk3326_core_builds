#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"
version="2.10"

# Wpa_supplicant package
if [[ "$var" == "wpa_supplicant" ]] && [[ "$bitness" == "64" ]]; then
  cd $cur_wd
  wget -t 3 -T 60 --no-check-certificate https://w1.fi/releases/wpa_supplicant-${version}.tar.gz

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while unpacking the source to wpa_supplicant.  Did it download correctly? Is Internet active or did the download location change?  Stopping here."
    exit 1
  fi

  tar -zxvf wpa_supplicant-${version}.tar.gz
  cp patches/wpa_supplicant-patch* wpa_supplicant-${version}/.
  cd wpa_supplicant-${version}

  wpa_supplicant_patches=$(find *.patch)
	 
  if [[ ! -z "$wpa_supplicant_patches" ]]; then
    for patching in wpa_supplicant-patch*
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

  cd wpa_supplicant
  cp defconfig .config
  make -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error building wpa_supplicant from source.  Stopping here."
    exit 1
  fi

  if [ ! -d "../../wpa_supplicant/" ]; then
    mkdir -v ../../wpa_supplicant
  fi

  strip wpa_cli wpa_passphrase wpa_supplicant
  cp -fv wpa_cli ../../wpa_supplicant/.
  cp -fv wpa_passphrase ../../wpa_supplicant/.
  cp -fv wpa_supplicant ../../wpa_supplicant/.

  echo " "
  echo "wpa_supplicant been built and placed in the rk3566_core_builds/wpa_supplicant subfolder"
fi
