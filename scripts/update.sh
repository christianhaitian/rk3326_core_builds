#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

   # Update retroarch_cores repo
	if [[ "$var" == "update" ]]; then
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
			git add . 
			file=$(basename $addupdatedcore)
			git commit -m "Updated $file core to commit $(cat ../../cores$bitness/${addupdatedcore}.commit)"
		done
	  fi
	fi
