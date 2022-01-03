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

# Update retroarch_cores repo
if [[ "$var" == "update" ]]; then

  # Ensure dependencies are installed and available
  neededlibs=( libarchive-zip-perl rsync zip )
  updateapt="N"
  for libs in "${neededlibs[@]}"
  do
   dpkg -s "${libs}" &>/dev/null
   if [[ $? != "0" ]]; then
      if [[ "$updateapt" == "N" ]]; then
        apt-get -y update
        updateapt="Y"
      fi
      apt-get -y install --no-install-recommends "${libs}"
      if [[ $? != "0" ]]; then
        echo " "
        echo "Could not install needed library ${libs}.  Stopping here so this can be reviewed."
        exit 1
      fi
   fi
  done

  cd $cur_wd
  if [[ "$bitness" == "64" ]]; then
    folder="aarch64"
  else
    folder="arm7hf"
  fi
  if [ ! -d "retroarch-cores/" ]; then
    git clone $ra_cores_git
    cd retroarch-cores
  else
    cd retroarch-cores
    git pull
  fi
  if [ -d "../cores$bitness/" ]; then
    builtcore_so=$(find ../cores$bitness/*.so)
    if [[ ! -z "$builtcore_so" ]]; then
      for core in $builtcore_so
      do
	cp -f $core $folder/.
	if [[ $? != "0" ]]; then
	  echo " "
	  echo "There was an error while copying $core.  Stopping here."
	  exit 1
	fi
	rm $core
      done
    else
      echo ""
      echo "There are no cores available to be added to the retroarch-cores repo."
      echo ""
      exit 1
    fi
  fi
  cd $folder
  updaterepocore_so=$(find *.so)
  if [[ ! -z "$updaterepocore_so" ]]; then
    for addupdatedcore in $updaterepocore_so
    do
      ../addcore $addupdatedcore
      git add ${addupdatedcore}.zip
      file=$(basename $addupdatedcore)
      git commit -m "Updated $file core to commit $(cat ../../cores$bitness/${addupdatedcore}.commit)"
    done
    git add .
    git commit -m "Update index and index-extended for recent core updates"
  fi
fi
