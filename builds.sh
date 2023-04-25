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
valid_id='^[0-9]+$'
es_git="https://github.com/christianhaitian/EmulationStation-fcamod.git"
nxengevo_git="https://github.com/nxengine/nxengine-evo.git"
ra_cores_git="https://github.com/christianhaitian/retroarch-cores.git"
bitness="$(getconf LONG_BIT)"
g31only=( )

for var in $@
do
  if [[ "$var" != "all" ]] && [[ "$var" != "ALL" ]]; then
      cd $cur_wd
      bittest=$(head -20 scripts/"$var".sh | grep -i '"$bitness" == ' | tr -dc '0-9')
      bitresult=${bittest: -2}
      if [[ ! -z $bitresult ]] && [[ $bitresult != $bitness ]]; then
        echo "$var cannot be built in this current ${bitness}bit environment."
        exit 1
      fi
    if [[ ${bitness} == "32" ]]; then
      archtest="arm-linux-gnueabihf"
    else
      archtest="aarch64-linux-gnu"
    fi
    if test -z "$(ls -l /usr/lib/${archtest}/libMali.so | grep g52-g2p0-gbm | tr -d '\0')"
    then
      printf "\nUpdating libMali to properly link to ibmali-bifrost-g52-g2p0-gbm.so in the dev environment, please wait...\n"
      if [[ ${bitness} == "32" ]] && [[ ! " ${g31only[*]} " =~ " ${var} " ]]; then
        cp mali/armhf/libmali-bifrost-g52-g2p0-gbm.so /usr/lib/arm-linux-gnueabihf/.
        cp mali/armhf/libmali-bifrost-g52-g2p0-gbm.so /usr/local/lib/arm-linux-gnueabihf/.
        cd /usr/lib/arm-linux-gnueabihf/
        whichmali="libmali-bifrost-g52-g2p0-gbm.so"
        arch="arm-linux-gnueabihf"
      elif [[ ! " ${g31only[*]} " =~ " ${var} " ]]; then
        cp mali/aarch64/libmali-bifrost-g52-g2p0-gbm.so /usr/lib/aarch64-linux-gnu/.
        cp mali/aarch64/libmali-bifrost-g52-g2p0-gbm.so /usr/local/lib/aarch64-linux-gnu/.
        cd /usr/lib/aarch64-linux-gnu/
        whichmali="libmali-bifrost-g52-g2p0-gbm.so"
        arch="aarch64-linux-gnu"
      elif [[ ${bitness} == "32" ]]; then
        cp mali/armhf/libmali-bifrost-g31-rxp0-gbm.so /usr/lib/arm-linux-gnueabihf/.
        cp mali/armhf/libmali-bifrost-g31-rxp0-gbm.so /usr/local/lib/arm-linux-gnueabihf/.
        cd /usr/lib/arm-linux-gnueabihf/
        whichmali="libmali-bifrost-g31-rxp0-gbm.so"
        arch="arm-linux-gnueabihf"
      else
        cp mali/aarch64/libmali-bifrost-g31-rxp0-gbm.so /usr/lib/aarch64-linux-gnu/.
        cp mali/aarch64/libmali-bifrost-g31-rxp0-gbm.so /usr/local/lib/aarch64-linux-gnu/.
        cd /usr/lib/aarch64-linux-gnu/
        whichmali="libmali-bifrost-g31-rxp0-gbm.so"
        arch="aarch64-linux-gnu"
      fi
      rm libMali.so
      rm libEGL.so*
      rm libGLES*
      rm libgbm.so*
      rm libmali.so*
      rm libMali*
      rm libOpenCL*
      rm libwayland-egl*
      ln -sf ${whichmali} libMali.so
      ln -sf libMali.so libEGL.so
      ln -sf libMali.so libEGL.so.1
      ln -sf libMali.so libGLES_CM.so
      ln -sf libMali.so libGLES_CM.so.1
      ln -sf libMali.so libGLESv1_CM.so
      ln -sf libMali.so libGLESv1_CM.so.1
      ln -sf libMali.so libGLESv1_CM.so.1.1.0
      ln -sf libMali.so libGLESv2.so
      ln -sf libMali.so libGLESv2.so.2
      ln -sf libMali.so libGLESv2.so.2.0.0
      ln -sf libMali.so libGLESv2.so.2.1.0
      ln -sf libMali.so libGLESv3.so
      ln -sf libMali.so libGLESv3.so.3
      ln -sf libMali.so libgbm.so
      ln -sf libMali.so libgbm.so.1
      ln -sf libMali.so libgbm.so.1.0.0
      ln -sf libMali.so libmali.so
      ln -sf libMali.so libmali.so.1
      ln -sf libMali.so libMaliOpenCL.so
      ln -sf libMali.so libOpenCL.so
      ln -sf libMali.so libwayland-egl.so
      ln -sf libMali.so libwayland-egl.so.1
      ln -sf libMali.so libwayland-egl.so.1.0.0
      if [ ! -d "/usr/local/lib/${arch}/" ]; then
        mkdir /usr/local/lib/${arch}/
      fi
      cd /usr/local/lib/${arch}/
      rm libMali.so
      rm libEGL.so*
      rm libGLES*
      rm libgbm.so*
      rm libmali.so*
      rm libMali*
      rm libOpenCL*
      rm libwayland-egl*
      ln -sf ${whichmali} libMali.so
      ln -sf libMali.so libEGL.so
      ln -sf libMali.so libEGL.so.1
      ln -sf libMali.so libGLES_CM.so
      ln -sf libMali.so libGLES_CM.so.1
      ln -sf libMali.so libGLESv1_CM.so
      ln -sf libMali.so libGLESv1_CM.so.1
      ln -sf libMali.so libGLESv1_CM.so.1.1.0
      ln -sf libMali.so libGLESv2.so
      ln -sf libMali.so libGLESv2.so.2
      ln -sf libMali.so libGLESv2.so.2.0.0
      ln -sf libMali.so libGLESv2.so.2.1.0
      ln -sf libMali.so libGLESv3.so
      ln -sf libMali.so libGLESv3.so.3
      ln -sf libMali.so libgbm.so
      ln -sf libMali.so libgbm.so.1
      ln -sf libMali.so libgbm.so.1.0.0
      ln -sf libMali.so libmali.so
      ln -sf libMali.so libmali.so.1
      ln -sf libMali.so libMaliOpenCL.so
      ln -sf libMali.so libOpenCL.so
      ln -sf libMali.so libwayland-egl.so
      ln -sf libMali.so libwayland-egl.so.1
      ln -sf libMali.so libwayland-egl.so.1.0.0
      ldconfig > /dev/null 2>&1
    fi
      cd "${cur_wd}"
      source scripts/"$var".sh
  else
       cur_var="$var"
       var=all
       for build_this in scripts/*.sh
       do
           bittest=$(head -20 $build_this | grep -i '"$bitness" == ' | tr -dc '0-9')
           bitresult=${bittest: -2}
           if [[ $build_this == *"mame"* ]] || [[ $build_this == *"mess"* ]]; then
             echo "Skipping $build_this for now.  We'll build this last if ALL was requested."
           elif [[ -z "$(grep '"$var" == "all"' $build_this)" ]]; then
             echo "Skipping $build_this as it's not a libretro core"
           elif [[ ! -z $bitresult ]] && [[ $bitresult != $bitness ]]; then
             echo "Skipping $build_this as it's not to be built in this current ${bitness}bit environment"
           else
                cd $cur_wd
                source $build_this
                if [[ $? != "0" ]]; then
                     echo " "
                     echo "There was an error while processing $build_this.  Stopping here."
                     exit 1
                fi
           fi
       done
       var="$cur_var"
       if [[ "$var" == "ALL" ]]; then
         var=all
         cd $cur_wd
         source scripts/mess.sh
         cd $cur_wd
         source scripts/mame.sh
         cd $cur_wd
         source scripts/mame2003-plus.sh
       fi
  fi
done
