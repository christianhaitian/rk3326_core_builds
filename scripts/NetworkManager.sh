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
version="1.52.0"
dsc="1ubuntu1.dsc"
tar="1ubuntu1.debian.tar.xz"
location="http://archive.ubuntu.com/ubuntu/pool/main/n/network-manager/"

if [ -d "NetworkManager-${version}/" ]; then
  echo " "
  echo "NetworkManager-${version} directory exists.  Can't build until this is deleted or moved."
  echo " "
  exit 1
fi

#Make sure we have dependencies installed
apt-get -y build-dep network-manager
#Make sure we have necessary tools installed
apt-get -y install build-essential dpkg-dev debhelper devscripts

#Get necessary packages and prepare the build directory
wget ${location}network-manager_${version}-${dsc}
wget ${location}network-manager_${version}.orig.tar.bz2
tar -xjf network-manager_${version}.orig.tar.bz2
cd NetworkManager-${version}/
wget ${location}network-manager_${version}-${tar}
tar -xf network-manager_${version}-${tar}

#Patch debian/rules to disable unnecessary tests after build and systemd script checks
cp $cur_wd/patches/networkmanager-patch* .
networkmanager_patches=$(find *.patch)
if [[ ! -z "$networkmanager_patches" ]]; then
  for patching in networkmanager-patch*
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

#Now let's build Network Manager
fakeroot debian/rules binary

if [[ $? != "0" ]]; then
  echo " "
  echo "Uh-oh!  Something went wrong.  Check above for the error"
  exit 1
  mv ../*.deb ../netman
  cd ..
  rm -rf network-manager_${version}-${dsc} network-manager_${version}.orig.tar.bz2
fi

if [ ! -d "../netman/" ]; then
  mkdir -v ../netman
fi

mv ../*.deb ../netman
cd ..
rm -rf network-manager_${version}-${dsc} network-manager_${version}.orig.tar.bz2
