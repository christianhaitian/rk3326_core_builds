#!/bin/bash
cur_wd="$PWD"
valid_id='^[0-9]+$'
es_git="https://github.com/christianhaitian/EmulationStation-fcamod.git"
bitness="$(getconf LONG_BIT)"

	# Build Emulationstation-FCAMOD
	if [[ "$var" == "es_build" ]] && [[ "$bitness" == "64" ]]; then

	 echo "What branch of emulationstation-fcamod are you wanting to build?"
	 echo "1 for master, 2 for fullscreen, 3 for 351v, 4 for all"
	 read branch_build
	 if [ "$branch_build" -lt 1 ] || [ "$branch_build" -gt 4 ]; then
	   echo "$branch_build is not a valid option.  Exiting."
	   exit 1
	 fi
	 if ! [[ $branch_build =~ $valid_id ]]; then
	   echo "$branch_build is not a number.  Exiting."
	   exit 1
	 fi
	 echo "What is the Dev ID for screenscraper to use?"
	 read devid
	 if [[ -z "$devid" ]]; then
	   devid=$(printenv DEV_ID)
	   [ ! -z $devid ] && echo "We're going to use $devid since you entered nothing above."
	 fi
	 echo "What is the Dev password for screenscraper to use?"
	 read devpass
	 if [[ -z "$devpass" ]]; then
	   devpass=$(printenv DEV_PASS)
	   [ ! -z $devpass ] && echo "We're going to use $devpass since you entered nothing above."
	 fi
	 echo "What is the apikey for TheGamesDB to use?"
	 read apikey
	 if [[ -z "$apikey" ]]; then
	   apikey=$(printenv TGDB_APIKEY)
	   [ ! -z $apikey ] && echo "We're going to use $apikey since you entered nothing above."
	 fi
	 echo "What is the screenscraper software name to use?"
	 read softname
	 if [[ -z "$softname" ]]; then
	   [ ! -z $SOFTNAME ] && [ ! -z $VSOFTNAME ] && echo "We'll use either $SOFTNAME or $VSOFTNAME if this is a 351v build since you entered nothing above."
	 fi

	 # Ensure dependencies are installed and available
     neededlibs=( libboost-system-dev libboost-filesystem-dev libboost-locale-dev libfreeimage-dev libfreetype6-dev libeigen3-dev libcurl4-openssl-dev libboost-date-time-dev libasound2-dev cmake libsdl2-dev rapidjson-dev libvlc-dev libvlccore-dev vlc-bin libsdl2-mixer-dev )
     updateapt="N"
     for libs in "${neededlibs[@]}"
     do
          dpkg -s "${libs}" &>/dev/null
          if [[ $? != "0" ]]; then
           if [[ "$ updateapt" == "N" ]]; then
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

     if [ ! -d "/usr/share/doc/libmali-rk-dev" ] && [[ $es_git == *"christianhaitian"* ]]; then
       wget $(echo $es_git | sed 's/\.git//')/raw/master/libmali-rk-dev_1.7-1%2Bdeb10_arm64.deb
       if [[ $? != "0" ]]; then
         echo " "
         echo "Could not download needed library libmali-rk-dev_1.7-1+deb10_arm64.deb.  Stopping here so this can be reviewed."
         exit 1
       fi
       wget $(echo $es_git | sed 's/\.git//')/raw/master/libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2%2Bdeb10_arm64.deb
       if [[ $? != "0" ]]; then
         echo " "
         echo "Could not download needed library libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2+deb10_arm64.deb.  Stopping here so this can be reviewed."
         exit 1
       fi
       dpkg -i --force-all libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2+deb10_arm64.deb
       dpkg -i libmali-rk-dev_1.7-1+deb10_arm64.deb
       rm libmali-rk-dev_1.7-1+deb10_arm64.deb
       rm libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2+deb10_arm64.deb
     fi

	 case "$branch_build" in
		 "1")
			cd $cur_wd
			branch="master"
			if [ ! -d "emulationstation-fcamod-$branch/" ]; then
			  git clone --recursive $es_git -b $branch emulationstation-fcamod-$branch
			  if [[ $? != "0" ]]; then
				echo " "
				echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
				exit 1
			  fi
			fi 

			cd emulationstation-fcamod-$branch 

			if [[ "$es_git" == "https://github.com/JuanMiguelBG/EmulationStation-fcamod-ogs.git" ]]; then
			  cp ../patches/es-fcamod-patch-build.patch .
			  patch -Np1 < es-fcamod-patch-build.patch
			  if [[ $? != "0" ]]; then
				echo " "
				echo "There was an error while applying es-fcamod-patch-build.patch.  Stopping here."
				exit 1
			  fi
			  rm es-fcamod-patch-build.patch
			fi

			 if [[ -z "$softname" ]]; then
			   softname=$(printenv SOFTNAME)
			   echo "The software name has been set to $softname since one was not provided at start."
			 fi
			cmake -DSCREENSCRAPER_DEV_LOGIN="devid=$devid&devpassword=$devpass" -DGAMESDB_APIKEY="$apikey" -DSCREENSCRAPER_SOFTNAME="$softname" .

			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while cmaking the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			make -j$(($(nproc) - 1))
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while building the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			strip emulationstation

			if [ ! -d "../es-fcamod/" ]; then
			  mkdir -v ../es-fcamod
			fi

			cp emulationstation ../es-fcamod/emulationstation.$branch
			echo " "
			echo "The $branch branch version of emulationstation-fcamod has been created and has been placed in the rk3326_core_builds/es-fcamod subfolder."
			exit 0
		 ;;
		 "2")
			cd $cur_wd
			branch="fullscreen"
			if [ ! -d "emulationstation-fcamod-$branch/" ]; then
			  git clone --recursive $es_git -b $branch emulationstation-fcamod-$branch
			  if [[ $? != "0" ]]; then
				echo " "
				echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
				exit 1
			  fi
			fi 

			cd emulationstation-fcamod-$branch 

			 if [[ -z "$softname" ]]; then
			   softname=$(printenv SOFTNAME)
			   echo "The software name has been set to $softname since one was not provided at start."
			 fi

			cmake -DSCREENSCRAPER_DEV_LOGIN="devid=$devid&devpassword=$devpass" -DGAMESDB_APIKEY="$apikey" -DSCREENSCRAPER_SOFTNAME="$softname" .
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while cmaking the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			make -j$(($(nproc) - 1))
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while building the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			strip emulationstation

			if [ ! -d "../es-fcamod/" ]; then
			  mkdir -v ../es-fcamod
			fi

			cp emulationstation ../es-fcamod/emulationstation.$branch
			echo " "
			echo "The $branch branch version of emulationstation-fcamod has been created and has been placed in the rk3326_core_builds/es-fcamod subfolder."
			exit 0
			;;
		 "3")
			cd $cur_wd
			branch="351v"
			if [ ! -d "emulationstation-fcamod-$branch/" ]; then
			  git clone --recursive $es_git -b $branch emulationstation-fcamod-$branch
			  if [[ $? != "0" ]]; then
				echo " "
				echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
				exit 1
			  fi
			fi 

			cd emulationstation-fcamod-$branch 

			 if [[ -z "$softname" ]]; then
			   softname=$(printenv SOFTNAME)
			   echo "The software name has been set to $softname since one was not provided at start."
			 fi

			cmake -DSCREENSCRAPER_DEV_LOGIN="devid=$devid&devpassword=$devpass" -DGAMESDB_APIKEY="$apikey" -DSCREENSCRAPER_SOFTNAME="$softname" .
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while cmaking the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			make -j$(($(nproc) - 1))
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while building the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			strip emulationstation

			if [ ! -d "../es-fcamod/" ]; then
			  mkdir -v ../es-fcamod
			fi

			cp emulationstation ../es-fcamod/emulationstation.$branch
			echo " "
			echo "The $branch branch version of emulationstation-fcamod has been created and has been placed in the rk3326_core_builds/es-fcamod subfolder."
			exit 0
			;;
		 "4")
			cd $cur_wd
			branch="master"
			if [ ! -d "emulationstation-fcamod-$branch/" ]; then
			  git clone --recursive $es_git -b $branch emulationstation-fcamod-$branch
			  if [[ $? != "0" ]]; then
				echo " "
				echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
				exit 1
			  fi
			fi 

			cd emulationstation-fcamod-$branch 

			 if [[ -z "$softname" ]]; then
			   softname=$(printenv SOFTNAME)
			   echo "The software name has been set to $softname since one was not provided at start."
			 fi

			cmake -DSCREENSCRAPER_DEV_LOGIN="devid=$devid&devpassword=$devpass" -DGAMESDB_APIKEY="$apikey" -DSCREENSCRAPER_SOFTNAME="$softname" .
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while cmaking the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			make -j$(($(nproc) - 1))
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while building the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			strip emulationstation

			if [ ! -d "../es-fcamod/" ]; then
			  mkdir -v ../es-fcamod
			fi

			cp emulationstation ../es-fcamod/emulationstation.$branch
			echo " "
			echo "The $branch branch version of emulationstation-fcamod has been created and has been placed in the rk3326_core_builds/es-fcamod subfolder."

			cd $cur_wd
			branch="fullscreen"
			if [ ! -d "emulationstation-fcamod-$branch/" ]; then
			  git clone --recursive $es_git -b $branch emulationstation-fcamod-$branch
			  if [[ $? != "0" ]]; then
				echo " "
				echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
				exit 1
			  fi
			fi 

			cd emulationstation-fcamod-$branch 

			cmake -DSCREENSCRAPER_DEV_LOGIN="devid=$devid&devpassword=$devpass" -DGAMESDB_APIKEY="$apikey" -DSCREENSCRAPER_SOFTNAME="$softname" .
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while cmaking the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			make -j$(($(nproc) - 1))
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while building the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			strip emulationstation

			if [ ! -d "../es-fcamod/" ]; then
			  mkdir -v ../es-fcamod
			fi

			cp emulationstation ../es-fcamod/emulationstation.$branch
			echo " "
			echo "The $branch branch version of emulationstation-fcamod has been created and has been placed in the rk3326_core_builds/es-fcamod subfolder."

			cd $cur_wd
			branch="351v"
			if [ ! -d "emulationstation-fcamod-$branch/" ]; then
			  git clone --recursive $es_git -b $branch emulationstation-fcamod-$branch
			  if [[ $? != "0" ]]; then
				echo " "
				echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
				exit 1
			  fi
			fi 

			cd emulationstation-fcamod-$branch 

			 if [[ "$softname" == "ArkOSEmulationStation" ]]; then
			   softname=$(printenv VSOFTNAME)
			   echo "The software name has been set to $softname for the 351v build for ArkOS since one was not provided at start."
			   echo "No particular reason to do this, it's just what was done for some reason by the crazy dev. ¯\_(?)_/¯"
			 fi


			cmake -DSCREENSCRAPER_DEV_LOGIN="devid=$devid&devpassword=$devpass" -DGAMESDB_APIKEY="$apikey" -DSCREENSCRAPER_SOFTNAME="$softname" .
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while cmaking the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			make -j$(($(nproc) - 1))
			if [[ $? != "0" ]]; then
			  echo " "
			  echo "There was an error while building the $branch of emulationstation-fcamod.  Stopping here."
			  exit 1
			fi

			strip emulationstation

			if [ ! -d "../es-fcamod/" ]; then
			  mkdir -v ../es-fcamod
			fi

			cp emulationstation ../es-fcamod/emulationstation.$branch
			echo " "
			echo "The $branch branch version of emulationstation-fcamod has been created and has been placed in the rk3326_core_builds/es-fcamod subfolder."
			exit 0
			;;
		 *)
			echo "I don't understand $branch_build.  Try again."
			exit 0
	 esac
	fi

