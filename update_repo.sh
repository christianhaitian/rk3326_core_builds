#!/bin/bash

var="$1"
cur_wd="$PWD"
ra_cores_git="https://github.com/christianhaitian/retroarch-cores.git"
bitness="$(getconf LONG_BIT)"

if [[ "$bitness" == "64" ]]; then
  folder="aarch64"
else
  folder="arm7hf"
fi

if [[ "$var" == "Update" ]]; then
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
    echo "There are no cores available to be added to the retroarch-cores repo."
    exit 1
   fi
  fi
  updaterepocore_so=$(find $folder/*.so)
  if [[ ! -z "$updaterepocore_so" ]]; then
    cd $folder
    for addupdatedcore in $updaterepocore_so
    do
        ../addcore $addupdatedcore
        git add . 
        file=$(basename $addupdatedcore)
        git commit -m "Updated $file core"
    done
  fi
fi
