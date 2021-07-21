#!/bin/bash

var="$1"
cur_wd="$PWD"

# Libretro mgba build
if [[ "$var" == "mgba" || "$var" == "all" ]]; then
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
  make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=goadvance -j$(nproc)

  if [[ $? != "0" ]]; then
    echo " "
    echo "There was an error while building the newest lr-flycast core.  Stopping here."
    exit 1
  fi

  strip flycast_libretro.so

  if [ ! -d "../cores64/" ]; then
    mkdir -v ../cores64
  fi

  cp flycast_libretro.so ../cores64/.

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
      make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=goadvance -j$(nproc)

      if [[ $? != "0" ]]; then
        echo " "
        echo "There was an error while building the newest lr-flycast core with the patched in rumble feature.  Stopping here."
        exit 1
      fi

      strip flycast_libretro.so
      mv flycast_libretro.so flycast_rumble_libretro.so
      cp flycast_rumble_libretro.so ../cores64/.
      echo " "
      echo "flycast_libretro.so and flycast_rumble_libretro.so have been created and have been placed in the rk3326_core_builds/cores64 subfolder"
    done
  fi

  echo " "
  echo "flycast_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
fi

# Clean up the directory and remove other lr gits and created cores
if [ "$var" == "clean" ]; then
  find -maxdepth 1 ! -name patches ! -name .git -type d -not -path '.' -exec rm -rf {} +
  mkdir cores64
  echo " "
  echo "Directory has been cleaned!"

# Unknown variable
# else
#  echo " "
#  echo "I don't understand what to do ¯\_(ツ)_/¯"
# fi
fi

if [ "$(ls -A $cur_wd/cores64)" ]; then
  echo " "
  echo "The cores folder currently contains the following:"
  ls -l $cur_wd/cores64
fi

