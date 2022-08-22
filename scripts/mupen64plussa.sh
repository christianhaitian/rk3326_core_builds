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

   cd $cur_wd
   source scripts/mupen64plus-core.sh
   cd $cur_wd
   source scripts/mupen64plus-rsp-hle.sh
   cd $cur_wd
   source scripts/mupen64plus-audio-sdl.sh
   cd $cur_wd
   source scripts/mupen64plus-input-sdl.sh
   cd $cur_wd
   source scripts/mupen64plus-ui-console.sh
   cd $cur_wd
   source scripts/mupen64plus-video-rice.sh
   cd $cur_wd
   source scripts/mupen64plus-video-glide64mk2.sh
   cd $cur_wd
   source scripts/mupen64plus-video-gliden64.sh
   
   cd $cur_wd
   gitcommit=$(git --git-dir mupen64plus-core/.git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
   tar --exclude='*.gz' -zchvf mupen64plussa-$bitness/mupen64plus-${gitcommit}.tar.gz -C mupen64plussa-$bitness .

echo " "
echo "Viola! Fini! All Done! Check the mupen64plussa-$bitness for the individual modules as well as the mupen64plus-$gitcommit.tar.gz package."
