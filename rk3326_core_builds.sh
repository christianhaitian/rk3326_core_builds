#!/bin/bash

var="$1"
cur_wd="$PWD"
valid_id='^[0-9]+$'

# Emulationstation scraping adds
if [[ "$var" == "es_add_scrape" ]] && [[ "$(getconf LONG_BIT)" == "64" ]]; then

 echo "What branch of emulationstation-fcamod are we working with?"
 echo "1 for master, 2 for fullscreen, 3 for 351v, 4 for all"
 read branchnum
 if [ "$branchnum" -lt 1 ] || [ "$branchnum" -gt 4 ]; then
   echo "$branchnum is not a valid option.  Exiting."
   exit 1
 fi
 if ! [[ $branchnum =~ $valid_id ]]; then
   echo "$branchnum is not a number.  Exiting."
   exit 1
 fi
 echo "What platform name to add? (ex. platform set in es_systems.cfg file)"
 read string
 echo "What Platform ID to add?"
 read platform_id
 echo "What is the screenscraper ID number to add? (Can be found by going to screenscraper.fr and selecting a platform and see what platforme is equal to in the url)"
 read ss_id
 if ! [[ $ss_id =~ $valid_id ]]; then
   echo "$ss_id is not a number.  Exiting."
   exit 1
 fi

 case "$branchnum" in
     "1")
        cd $cur_wd
        branch="master"
        if [ ! -d "emulationstation-fcamod-$branch/" ]; then
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
          if [[ $? != "0" ]]; then
            echo " "
            echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
            exit 1
          fi
        fi 
        cd emulationstation-fcamod-$branch
        sed -i '/TI_99 },/c\\t\t{ \"ti99\", \t\t\t\t\tTI_99 },\n\t\t{ \"'$string'\", \t\t\t'$platform_id' },' es-app/src/PlatformId.cpp
        sed -i '/TI_99,/c\\t\tTI_99,\n\t\t'$platform_id',' es-app/src/PlatformId.h
        sed -i '/{ TI_99, 205 },/c\\t{ TI_99, 205 },\n\t{ '$platform_id', '$ss_id' },' es-app/src/scrapers/ScreenScraper.cpp
        exit 0
        ;;
     "2")
        cd $cur_wd
        branch="fullscreen"
        if [ ! -d "emulationstation-fcamod-$branch/" ]; then
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
          if [[ $? != "0" ]]; then
            echo " "
            echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
            exit 1
          fi
        fi 
        cd emulationstation-fcamod-$branch
        sed -i '/TI_99 },/c\\t\t{ \"ti99\", \t\t\t\t\tTI_99 },\n\t\t{ \"'$string'\", \t\t\t'$platform_id' },' es-app/src/PlatformId.cpp
        sed -i '/TI_99,/c\\t\tTI_99,\n\t\t'$platform_id',' es-app/src/PlatformId.h
        sed -i '/{ TI_99, 205 },/c\\t{ TI_99, 205 },\n\t{ '$platform_id', '$ss_id' },' es-app/src/scrapers/ScreenScraper.cpp
        exit 0
     ;;
     "3")
        cd $cur_wd
        branch="351v"
        if [ ! -d "emulationstation-fcamod-$branch/" ]; then
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
          if [[ $? != "0" ]]; then
            echo " "
            echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
            exit 1
          fi
        fi 
        cd emulationstation-fcamod-$branch
        sed -i '/TI_99 },/c\\t\t{ \"ti99\", \t\t\t\t\tTI_99 },\n\t\t{ \"'$string'\", \t\t\t'$platform_id' },' es-app/src/PlatformId.cpp
        sed -i '/TI_99,/c\\t\tTI_99,\n\t\t'$platform_id',' es-app/src/PlatformId.h
        sed -i '/{ TI_99, 205 },/c\\t{ TI_99, 205 },\n\t{ '$platform_id', '$ss_id' },' es-app/src/scrapers/ScreenScraper.cpp
        exit 0
     ;;
     "4")
        cd $cur_wd
        branch="master"
        if [ ! -d "emulationstation-fcamod-$branch/" ]; then
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
          if [[ $? != "0" ]]; then
            echo " "
            echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
            exit 1
          fi
        fi 
        cd emulationstation-fcamod-$branch
        sed -i '/TI_99 },/c\\t\t{ \"ti99\", \t\t\t\t\tTI_99 },\n\t\t{ \"'$string'\", \t\t\t'$platform_id' },' es-app/src/PlatformId.cpp
        sed -i '/TI_99,/c\\t\tTI_99,\n\t\t'$platform_id',' es-app/src/PlatformId.h
        sed -i '/{ TI_99, 205 },/c\\t{ TI_99, 205 },\n\t{ '$platform_id', '$ss_id' },' es-app/src/scrapers/ScreenScraper.cpp

        cd $cur_wd
        branch="351v"
        if [ ! -d "emulationstation-fcamod-$branch/" ]; then
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
          if [[ $? != "0" ]]; then
            echo " "
            echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
            exit 1
          fi
        fi 
        cd emulationstation-fcamod-$branch
        sed -i '/TI_99 },/c\\t\t{ \"ti99\", \t\t\t\t\tTI_99 },\n\t\t{ \"'$string'\", \t\t\t'$platform_id' },' es-app/src/PlatformId.cpp
        sed -i '/TI_99,/c\\t\tTI_99,\n\t\t'$platform_id',' es-app/src/PlatformId.h
        sed -i '/{ TI_99, 205 },/c\\t{ TI_99, 205 },\n\t{ '$platform_id', '$ss_id' },' es-app/src/scrapers/ScreenScraper.cpp

        cd $cur_wd
        branch="fullscreen"
        if [ ! -d "emulationstation-fcamod-$branch/" ]; then
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
          if [[ $? != "0" ]]; then
            echo " "
            echo "There was an error while cloning the $branch branch of the emulationstation-fcamod git.  Is Internet active or did the git location change?  Stopping here."
            exit 1
          fi
        fi 
        cd emulationstation-fcamod-$branch
        sed -i '/TI_99 },/c\\t\t{ \"ti99\", \t\t\t\t\tTI_99 },\n\t\t{ \"'$string'\", \t\t\t'$platform_id' },' es-app/src/PlatformId.cpp
        sed -i '/TI_99,/c\\t\tTI_99,\n\t\t'$platform_id',' es-app/src/PlatformId.h
        sed -i '/{ TI_99, 205 },/c\\t{ TI_99, 205 },\n\t{ '$platform_id', '$ss_id' },' es-app/src/scrapers/ScreenScraper.cpp
        exit 0
     ;;
     *)
        echo "I don't understand $branchnum.  Try again."
        exit 0
 esac
fi

# Build Emulationstation-FCAMOD
if [[ "$var" == "es_build" ]] && [[ "$(getconf LONG_BIT)" == "64" ]]; then

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
   echo "We're going to use $devid since you entered nothing above."
 fi
 echo "What is the Dev password for screenscraper to use?"
 read devpass
 if [[ -z "$devpass" ]]; then
   devpass=$(printenv DEV_PASS)
   echo "We're going to use $devpass since you entered nothing above."
 fi
 echo "What is the apikey for TheGamesDB to use?"
 read apikey
 if [[ -z "$apikey" ]]; then
   apikey=$(printenv TGDB_APIKEY)
   echo "We're going to use $apikey since you entered nothing above."
 fi
 echo "What is the screenscraper software name to use?"
 read softname
 if [[ -z "$softname" ]]; then
   echo "We'll use either $SOFTNAME or $VSOFTNAME if this is a 351v build since you entered nothing above."
 fi

 case "$branch_build" in
     "1")
        cd $cur_wd
        branch="master"
        if [ ! -d "emulationstation-fcamod-$branch/" ]; then
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
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

        make -j$(nproc)
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
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
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

        make -j$(nproc)
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
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
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

        make -j$(nproc)
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
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
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

        make -j$(nproc)
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
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
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

        make -j$(nproc)
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
          git clone --recursive https://github.com/christianhaitian/emulationstation-fcamod.git -b $branch emulationstation-fcamod-$branch
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
           echo "No particular reason to do this, it's just what was done for some reason by the crazy dev. ¯\_(ツ)_/¯"
         fi


        cmake -DSCREENSCRAPER_DEV_LOGIN="devid=$devid&devpassword=$devpass" -DGAMESDB_APIKEY="$apikey" -DSCREENSCRAPER_SOFTNAME="$softname" .
        if [[ $? != "0" ]]; then
          echo " "
          echo "There was an error while cmaking the $branch of emulationstation-fcamod.  Stopping here."
          exit 1
        fi

        make -j$(nproc)
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

# Libretro dosbox_pure
if [[ "$var" == "dosbox_pure" || "$var" == "all" ]] && [[ "$(getconf LONG_BIT)" == "64" ]]; then
 cd $cur_wd
  if [ ! -d "dosbox_pure/" ]; then
    git clone https://github.com/libretro/dosbox-pure.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
    fi
    cp patches/dosbox_pure-patch* dosbox-pure/.
  fi

 cd dosbox-pure/
 
 dosbox-pure_patches=$(find *.patch)
 
 if [[ ! -z "$dosbox-pure_patches" ]]; then
  for patching in dosbox_pure-patch*
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
 
  make platform=goadvance -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest lr-fbneo core.  Stopping here."
    exit 1
  fi

  strip dosbox_pure_libretro.so

  if [ ! -d "../cores64/" ]; then
    mkdir -v ../cores64
  fi

  cp dosbox_pure_libretro.so ../cores64/.

  echo " "
  echo "dosbox_pure_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
fi

# Libretro fbneo build
if [[ "$var" == "fbneo" || "$var" == "all" ]] && [[ "$(getconf LONG_BIT)" == "64" ]]; then
 cd $cur_wd
  if [ ! -d "fbneo/" ]; then
    git clone https://github.com/libretro/fbneo.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
     fi
  fi

 cd fbneo/
 
  # make -j$(nproc) -C ./src/burner/libretro generate-files
  make -j$(nproc) -C ./src/burner/libretro profile=performance

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest lr-fbneo core.  Stopping here."
    exit 1
  fi

  strip src/burner/libretro/fbneo_libretro.so

  if [ ! -d "../cores64/" ]; then
    mkdir -v ../cores64
  fi

  cp src/burner/libretro/fbneo_libretro.so ../cores64/.

  echo " "
  echo "fbneo_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
fi

# Libretro mgba build
if [[ "$var" == "mgba" || "$var" == "all" ]] && [[ "$(getconf LONG_BIT)" == "64" ]]; then
 gba_rumblepatch="no"
 cd $cur_wd
  if [ ! -d "mgba/" ]; then
    git clone https://github.com/libretro/mgba.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
     fi
    cp patches/mgba-patch* mgba/.
  fi

 cd mgba/
 
 mgba_patches=$(find *.patch)
 
 if [[ ! -z "$mgba_patches" ]]; then
  for patching in mgba-patch*
  do
     if [[ $patching == *"rumble"* ]]; then
       echo "Skipping the $patching for now and making a note to apply that later"
       sleep 3
       gba_rumblepatch="yes"
     else  
       patch -Np1 < "$patching"
       if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while applying $patching.  Stopping here."
        exit 1
       fi
       rm "$patching" 
     fi
  done
 fi
  cmake .
  make clean
  make -f Makefile.libretro platform=goadvance -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest lr-mgba core.  Stopping here."
    exit 1
  fi

  strip mgba_libretro.so

  if [ ! -d "../cores64/" ]; then
    mkdir -v ../cores64
  fi

  cp mgba_libretro.so ../cores64/.

  if [[ $gba_rumblepatch == "yes" ]]; then
    for patching in mgba-patch*
    do
      patch -Np1 < "$patching"
      if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while patching in the rumble feature from $patching.  Stopping here."
        exit 1
      fi
      rm "$patching"
      make -f Makefile.libretro platform=goadvance -j$(nproc)

      if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while building the newest lr-mgba core with the patched in rumble feature.  Stopping here."
        exit 1
      fi

      strip mgba_libretro.so
      mv mgba_libretro.so mgba_rumble_libretro.so
      cp mgba_rumble_libretro.so ../cores64/.
      echo " "
      echo "mgba_libretro.so and mgba_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores64 subfolder"
    done
  fi

  echo " "
  echo "mgba_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
fi

# Libretro Flycast build
if [[ "$var" == "flycast" || "$var" == "all" ]]; then
 flycast_rumblepatch="no"
 cd $cur_wd
  if [ ! -d "flycast/" ]; then
    git clone https://github.com/libretro/flycast.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the flycast libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
    fi
    cp patches/flycast-patch* flycast/.
  fi

 cd flycast/
 
 flycast_patches=$(find *.patch)
 
 if [[ ! -z "$flycast_patches" ]]; then
  for patching in flycast-patch*
  do
     if [[ $patching == *"rumble"* ]]; then
       echo " "
       echo "Skipping the $patching for now and making a note to apply that later"
       sleep 3
       flycast_rumblepatch="yes"
     else  
       patch -Np1 < "$patching"
       if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while applying $patching.  Stopping here."
        exit 1
       fi
       rm "$patching" 
     fi
  done
 fi
  make clean

  if [[ "$(getconf LONG_BIT)" == "64" ]]; then
    make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=goadvance -j$(nproc)
  else 
    make FORCE_GLES=1 platform=classic_armv8_a35 -j$(nproc)
  fi

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest lr-flycast core.  Stopping here."
    exit 1
  fi

  strip flycast_libretro.so

  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
    mkdir -v ../cores$(getconf LONG_BIT)
  fi

  cp flycast_libretro.so ../cores$(getconf LONG_BIT)/.

  if [[ $flycast_rumblepatch == "yes" ]]; then
    for patching in flycast-patch*
    do
      patch -Np1 < "$patching"
      if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while patching in the rumble feature from $patching.  Stopping here."
        exit 1
      fi
      rm "$patching"

      if [[ "$(getconf LONG_BIT)" == "64" ]]; then
        make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=goadvance -j$(nproc)
      else 
        make FORCE_GLES=1 platform=classic_armv8_a35 -j$(nproc)
      fi

      if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while building the newest lr-flycast core with the patched in rumble feature.  Stopping here."
        exit 1
      fi

      strip flycast_libretro.so
      mv flycast_libretro.so flycast_rumble_libretro.so

      if [[ "$(getconf LONG_BIT)" == "64" ]]; then
        cp flycast_rumble_libretro.so ../cores$(getconf LONG_BIT)/.
      else
        cp flycast_rumble_libretro.so ../cores$(getconf LONG_BIT)/flycast32_rumble_libretro.so
      fi
      
      echo " "
      if [[ "$(getconf LONG_BIT)" == "64" ]]; then
        echo "flycast_libretro.so and flycast_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
      else
        echo "flycast_libretro.so and flycast32_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
      fi
    done
  fi

  echo " "
  echo "flycast_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
fi

# Libretro Pcsx_rearmed build
if [[ "$var" == "pcsx_rearmed" || "$var" == "all" ]] && [[ "$(getconf LONG_BIT)" == "32" ]]; then
# if [[ "$(getconf LONG_BIT)" != "32" ]]; then
#   echo " "
#   echo "This environment is not 32 bit.  Can't build the pcsx_rearmed core here."
#   echo " "
#   exit 1
# fi
 pcsx_rearmed_rumblepatch="no"
 cd $cur_wd
  if [ ! -d "pcsx_rearmed/" ]; then
    git clone https://github.com/libretro/pcsx_rearmed.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the pcsx_rearmed libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
    fi
    cp patches/pcsx_rearmed-patch* pcsx_rearmed/.
  fi

 cd pcsx_rearmed/
 
 pcsx_rearmed_patches=$(find *.patch)
 
 if [[ ! -z "$pcsx_rearmed_patches" ]]; then
  for patching in pcsx_rearmed-patch*
  do
     if [[ $patching == *"rumble"* ]]; then
       echo " "
       echo "Skipping the $patching for now and making a note to apply that later"
       sleep 3
       pcsx_rearmed_rumblepatch="yes"
     else  
       patch -Np1 < "$patching"
       if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while applying $patching.  Stopping here."
        exit 1
       fi
       rm "$patching" 
     fi
  done
 fi
  make clean
  make -f Makefile.libretro HAVE_NEON=1 ARCH=arm BUILTIN_GPU=neon DYNAREC=ari64 platform=rpi3 -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest lr-pcsx_rearmed core.  Stopping here."
    exit 1
  fi

  strip pcsx_rearmed_libretro.so

  if [ ! -d "../cores32/" ]; then
    mkdir -v ../cores32
  fi

  cp pcsx_rearmed_libretro.so ../cores32/.

  if [[ $pcsx_rearmed_rumblepatch == "yes" ]]; then
    for patching in pcsx_rearmed-patch*
    do
      patch -Np1 < "$patching"
      if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while patching in the rumble feature from $patching.  Stopping here."
        exit 1
      fi
      rm "$patching"
      make -f Makefile.libretro HAVE_NEON=1 ARCH=arm BUILTIN_GPU=neon DYNAREC=ari64 platform=rpi3 -j$(nproc)

      if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while building the newest lr-pcsx_rearmed core with the patched in rumble feature.  Stopping here."
        exit 1
      fi

      strip pcsx_rearmed_libretro.so
      mv pcsx_rearmed_libretro.so pcsx_rearmed_rumble_libretro.so
      cp pcsx_rearmed_rumble_libretro.so ../cores32/.
      echo " "
      echo "pcsx_rearmed_libretro.so and pcsx_rearmed_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores32 subfolder"
    done
  fi

  echo " "
  echo "pcsx_rearmed_libretro.so has been created and has been placed in the rk3326_core_builds/cores32 subfolder"
fi

# Libretro Parallel-n64 build
if [[ "$var" == "parallel-n64" || "$var" == "all" ]]; then
 cd $cur_wd
  if [ ! -d "parallel-n64/" ]; then
    git clone https://github.com/libretro/parallel-n64.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the parallel-n64 libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
    fi
    cp patches/parallel-n64-patch* parallel-n64/.
  fi

 cd parallel-n64/
 
 parallel-n64_patches=$(find *.patch)
 
 if [[ ! -z "$parallel-n64_patches" ]]; then
  for patching in parallel-n64-patch*
  do
     if [[ $patching == *"target64"* ]] && [[ "$(getconf LONG_BIT)" == "32" ]]; then
       echo "Skipping the $patching as it breaks 32 bit building for this core"
       sleep 3
     else
       patch -Np1 < "$patching"
       if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while applying $patching.  Stopping here."
        exit 1
       fi
       rm "$patching" 
     fi
  done
 fi
  make clean
  if [[ "$(getconf LONG_BIT)" == "32" ]]; then
    make platform=Odroidgoa -lto -j$(nproc)
  else
    make platform=emuelec64-armv8 -lto -j$(nproc)
  fi

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest lr-parallel-n64 core.  Stopping here."
    exit 1
  fi

  strip parallel_n64_libretro.so

  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
    mkdir -v ../cores$(getconf LONG_BIT)
  fi

  cp parallel_n64_libretro.so ../cores$(getconf LONG_BIT)/.

  echo " "
  echo "parallel_n64_libretro.so has been created and has been placed in the rk3326_core_builds/cores$(getconf LONG_BIT) subfolder"
fi

# Libretro Retroarch build
if [[ "$var" == "retroarch" ]]; then
 cd $cur_wd
  if [ ! -d "retroarch/" ]; then
    git clone https://github.com/libretro/retroarch.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the retroarch libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
    fi
    cp patches/retroarch-patch* retroarch/.
  fi

 cd retroarch/
 
 retroarch_patches=$(find *.patch)
 
 if [[ ! -z "$retroarch_patches" ]]; then
  for patching in retroarch-patch*
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
  ./configure --disable-opengl --disable-opengl1 --disable-qt --disable-wayland --disable-x11 --enable-alsa --enable-egl --enable-kms --enable-odroidgo2 --enable-opengles --enable-opengles3 --enable-udev --disable-vulkan --disable-vulkan_display --enable-networking --enable-ozone --disable-caca --enable-opengles3_1 --enable-opengles3_2 --enable-wifi
  make -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest retroarch.  Stopping here."
    exit 1
  fi

  strip retroarch

  if [ ! -d "../retroarch$(getconf LONG_BIT)/" ]; then
    mkdir -v ../retroarch$(getconf LONG_BIT)
  fi

  cp retroarch ../retroarch$(getconf LONG_BIT)/.

  if [[ "$(getconf LONG_BIT)" == "32" ]]; then
    mv ../retroarch$(getconf LONG_BIT)/retroarch ../retroarch$(getconf LONG_BIT)/retroarch32
  fi

  echo " "
  if [[ "$(getconf LONG_BIT)" == "32" ]]; then
    echo "retroarch32 has been created and has been placed in the rk3326_core_builds/retroarch$(getconf LONG_BIT) subfolder"
  else
    echo "retroarch has been created and has been placed in the rk3326_core_builds/retroarch$(getconf LONG_BIT) subfolder"
  fi
fi

# PPSSPP Standalone build
if [[ "$var" == "ppsspp" ]] && [[ "$(getconf LONG_BIT)" == "64" ]]; then
 cd $cur_wd

  # Now we'll start the clone and build of PPSSPP
  if [ ! -d "ppsspp/" ]; then
    git clone https://github.com/hrydgard/ppsspp.git --recursive
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the retroarch libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
    fi
    cp patches/ppsspp-patch* ppsspp/.
  else
    echo " "
    echo "A ppsspp subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the ppsspp folder and rerun this script."
    echo " "
    exit 1
  fi

 # Ensure dependencies are installed and available
 apt-get update
 apt-get -y install libx11-dev libsm-dev libxext-dev git cmake mercurial libudev-dev libdrm-dev zlib1g-dev pkg-config libasound2-dev libfreetype6-dev libx11-xcb1 libxcb-dri2-0
 if [[ $? != "0" ]]; then
   echo " "
   echo "There was an error while installing the necessary dependencies.  Is Internet active?  Stopping here."
   exit 1
 fi


 cd ppsspp/ffmpeg
 ./linux_arm64.sh
 cd ..
 
 ppsspp_patches=$(find *.patch)
 
 if [[ ! -z "$ppsspp_patches" ]]; then
  for patching in ppsspp-patch*
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

  mkdir build
  cd build
  cmake -DUSING_EGL=OFF -DUSING_GLES2=ON -DUSE_FFMPEG=YES -DUSE_SYSTEM_FFMPEG=NO ../.
  make -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest retroarch.  Stopping here."
    exit 1
  fi

  strip PPSSPPSDL

  if [ ! -d "../../ppsspp$(getconf LONG_BIT)/" ]; then
    mkdir -v ../../ppsspp$(getconf LONG_BIT)
  fi

  cp PPSSPPSDL ../../ppsspp$(getconf LONG_BIT)/.
  tar -zchvf ../../ppsspp$(getconf LONG_BIT)/ppssppsdl_pkg_$(git rev-parse HEAD | cut -c -7).tar.gz assets/ PPSSPPSDL

  echo " "
  echo "PPSSPPSDL executable and ppssppsdl_pkg_$(git rev-parse HEAD | cut -c -7).tar.gz package has been created and has been placed in the rk3326_core_builds/ppsspp$(getconf LONG_BIT) subfolder"

fi

# Scummvm Standalone Build
if [[ "$var" == "scummvm" ]]; then
 cd $cur_wd

  # Now we'll start the clone and build process of scummvm
  if [ ! -d "scummvm/" ]; then
    git clone https://github.com/scummvm/scummvm.git
    if [[ $? != "0" ]]; then
      echo " "
      echo "There was an error while cloning the retroarch libretro git.  Is Internet active or did the git location change?  Stopping here."
      exit 1
    fi
    cp patches/scummvm-patch* scummvm/.
  else
    echo " "
    echo "A scummvm subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the scummvm folder and rerun this script."
    echo " "
    exit 1
  fi

 cd scummvm/

 # Ensure dependencies are installed and available
 apt-get update
 apt-get -y install --no-install-recommends libsdl2-dev liba52-0.7.4-dev libjpeg62-turbo-dev libmpeg2-4-dev libogg-dev libvorbis-dev libflac-dev libmad0-dev libpng-dev libtheora-dev libfaad-dev libfluidsynth-dev libfreetype6-dev libcurl4-openssl-dev libsdl2-net-dev libspeechd-dev zlib1g-dev libfribidi-dev libglew-dev
 if [[ $? != "0" ]]; then
   echo " "
   echo "There was an error while installing the necessary dependencies.  Is Internet active?  Stopping here."
   exit 1
 fi 

  ./configure --backend=sdl --enable-optimizations --opengl-mode=gles2 --enable-vkeybd
  make clean
  make -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest scummvm.  Stopping here."
    exit 1
  fi

  strip scummvm
  
  mkdir extra
  mkdir themes
  cp backends/vkeybd/packs/*.zip extra/.
  cp dists/pred.dic extra.
  cp dists/engine-data/*.dat extra/.
  cp gui/themes/*.zip themes/.
  cp gui/themes/translations.dat themes/. 
  echo "19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,
190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,leftstick:b10,guide:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,
190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,
190000004b4800000011000000010000,GO-Super Gamepad,platform:Linux,x:b2,a:b1,b:b0,y:b3,back:b12,guide:b16,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b14,rightstick:b17,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,
03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,guide:b10,leftstick:b8,lefttrigger:b13,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux," > extra/gamecontrollerdb.txt

  if [ ! -d "../scummvm$(getconf LONG_BIT)/" ]; then
    mkdir -v ../scummvm$(getconf LONG_BIT)
  fi

  cp scummvm ../scummvm$(getconf LONG_BIT)/.
  tar -zchvf ../scummvm$(getconf LONG_BIT)/scummvm_pkg_$(git rev-parse HEAD | cut -c -7).tar.gz extra/ themes/ scummvm AUTHORS COPYING COPYING.* NEWS.md README.md

  echo " "
  echo "scummvm has been created and has been placed in the rk3326_core_builds/scummvm$(getconf LONG_BIT) subfolder"
fi


# Clean up the directory and remove other lr gits and created cores
if [ "$var" == "clean" ]; then
  find -maxdepth 1 ! -name patches ! -name .git ! -name docs -type d -not -path '.' -exec rm -rf {} +
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
