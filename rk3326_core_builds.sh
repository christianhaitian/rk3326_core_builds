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

  if [[ "$(getconf LONG_BIT)" == "64" ]]; then
    make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=goadvance -j$(nproc)
  else 
    make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=classic_armv8_a35 -j$(nproc)
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
        make WITH_DYNAREC=arm64 FORCE_GLES=1 platform=classic_armv8_a35 -j$(nproc)
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
if [[ "$var" == "pcsx_rearmed" || "$var" == "all" ]]; then
 if [[ "$(getconf LONG_BIT)" != "32" ]]; then
   echo " "
   echo "This environment is not 32 bit.  Can't build the pcsx_rearmed core here."
   echo " "
   exit 1
 fi
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
  unset export
fi

# Clean up the directory and remove other lr gits and created cores
if [ "$var" == "clean" ]; then
  find -maxdepth 1 ! -name patches ! -name .git -type d -not -path '.' -exec rm -rf {} +
  mkdir cores$(getconf LONG_BIT)
  echo " "
  echo "Directory has been cleaned!"
fi

if [ "$(ls -A $cur_wd/cores$(getconf LONG_BIT))" ]; then
  echo " "
  echo "The cores$(getconf LONG_BIT) folder currently contains the following:"
  ls -l $cur_wd/cores$(getconf LONG_BIT)
fi

