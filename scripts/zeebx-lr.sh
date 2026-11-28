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

# Zeebo (Qualcomm BREW 4.0.2 reimplemented), a Rust core. Upstream's recipe clones
# NextOs-Ports/zeebx-nextos (mali450-gles2), which is gone (404 since 2026-11); this one
# builds ZeebxTeam/zeebx-emu, the emulator's own repository, at a release tag.
# frontends/libretro builds without the desktop features (no window, sound or pad of the
# host): video, audio and input come from RetroArch.
# v0.6.0 (2026-11-19): the libretro frontend and the core translated from Portuguese to English.
# Our two patches ported to the new names, the logic unchanged. Action Hero 3D: 22.7-23.0 fps as
# with v0.5.1, its 2D opening drawn through patch 0001's bridge (2026-11-21).
tag="v0.6.0"
# Its locked dependencies want rustc 1.93 or newer (sevenz-rust2 0.23); Debian trixie has 1.85.
# The official toolchain from static.rust-lang.org, pinned and checked, unpacked inside the
# core builds directory (cleanup_filesystem.sh removes it), with CARGO_HOME beside it, so
# neither the toolchain nor the crate cache ends up in the image.
rust_ver="1.99.1"
rust_sha256="a48fb1e853be56ce9b8e2751f5464dbd5e16440cd81e237920f3a5e7e806333e"

	# Libretro zeebx build
	if [[ "$var" == "zeebx-lr" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "zeebx-emu/" ]; then
		git clone --recursive https://github.com/ZeebxTeam/zeebx-emu.git zeebx-emu
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the zeebx git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/zeebx-patch* zeebx-emu/. 2>/dev/null
	  fi

	 cd zeebx-emu/
	 git checkout $tag && git submodule update --init --recursive
	 if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while checking out zeebx at $tag.  Stopping here."
		exit 1
	 fi

	 zeebx_patches=$(find . -maxdepth 1 -name 'zeebx-patch*')

	 if [[ ! -z "$zeebx_patches" ]]; then
	  for patching in zeebx-patch*
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

	  rust_dir="$cur_wd/rust-$rust_ver"
	  if [ ! -x "$rust_dir/bin/cargo" ]; then
		rust_tar="rust-$rust_ver-aarch64-unknown-linux-gnu"
		curl -fL --retry 5 -o "$cur_wd/$rust_tar.tar.xz" "https://static.rust-lang.org/dist/$rust_tar.tar.xz" && 		echo "$rust_sha256  $cur_wd/$rust_tar.tar.xz" | sha256sum -c - && 		tar -xJf "$cur_wd/$rust_tar.tar.xz" -C "$cur_wd" && 		"$cur_wd/$rust_tar/install.sh" --prefix="$rust_dir" --components=rustc,cargo,rust-std-aarch64-unknown-linux-gnu --disable-ldconfig
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while installing rust $rust_ver for zeebx.  Stopping here."
		  exit 1
		fi
		rm -rf "$cur_wd/$rust_tar" "$cur_wd/$rust_tar.tar.xz"
	  fi
	  export PATH="$rust_dir/bin:$PATH"
	  export CARGO_HOME="$cur_wd/cargo-home"
	  export CMAKE_GENERATOR=Ninja
	  export CARGO_PROFILE_RELEASE_DEBUG=0
	  export RUSTFLAGS="-C target-cpu=cortex-a35"
	  cargo build --release --locked -p zeebx-libretro

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-zeebx core.  Stopping here."
		exit 1
	  fi

	  strip target/release/libzeebx_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp target/release/libzeebx_libretro.so ../cores64/zeebx_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/zeebx_libretro.so.commit

	  echo " "
	  echo "zeebx_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
