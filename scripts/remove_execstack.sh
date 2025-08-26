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
  # Ensure dependencies are installed and available
  neededlibs=( execstack libarchive-zip-perl rsync zip )
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
  builtcore_sozip=$(find $folder/*.zip)
  if [[ ! -z "$builtcore_sozip" ]]; then
    for corezip in $builtcore_sozip
    do
      unzip -o $corezip $(basename ${corezip%????})
	  rm -f $corezip
	  execstack -c $(basename ${corezip%????})
	  mv $(basename ${corezip%????}) ${folder}/
	  cd $folder
	  ../addcore $(basename ${corezip%????})
	  #zip $corezip "$(basename ${corezip%????})"
	  if [[ $? != "0" ]]; then
	    echo " "
	    echo "There was an error while processing $corezip.  Stopping here."
	    exit 1
	  fi
	  cd ..
	  #rm $(basename ${corezip%????})
    done
  else
    echo ""
    echo "There are no cores available to be processed."
    echo ""
    exit 1
  fi

