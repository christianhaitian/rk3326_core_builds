## To create debian based chroots in a Linux environment.  These instructions are based on a Ubuntu 16 or newer install or VM.


install Prereqs:

`sudo apt update`
`sudo apt install -y build-essential debootstrap binfmt-support qemu-user-static`

Then install armhf and arm64 chroots:

`sudo qemu-debootstrap --arch armhf buster /mnt/data/armhf http://deb.debian.org/debian/`

`sudo qemu-debootstrap --arch arm64 buster /mnt/data/arm64 http://deb.debian.org/debian/`

To get into chroots:

For 32 bit Arm environment: \
`sudo chroot /mnt/data/armhf/`
or create a Arm32 shortcut on the desktop gui and click on Arm32 shortcut on desktop

For 64 bit Arm environment
`sudo chroot /mnt/data/arm64/`
or create a Arm64 shortcut on the desktop gui and click on Arm64 shortcut on desktop

Helpful tools to install in both environments for RK3326 app builds

`apt -y install build-essential git wget libdrm-dev python3 python3-pip python3-setuptools python3-wheel ninja-build libopenal-dev premake4 autoconf libevdev-dev ffmpeg libsnappy-dev libboost-tools-dev magics++ libboost-thread-dev libboost-all-dev pkg-config zlib1g-dev libpng-dev libsdl2-dev clang cmake cmake-data libarchive13 libcurl4 libfreetype6-dev libjsoncpp1 librhash0 libuv1 mercurial mercurial-common libgbm-dev libsdl2-ttf-2.0-0 libsdl2-ttf-dev`

`ln -s /usr/include/libdrm/ /usr/include/drm`

`pip3 install meson`

`git clone https://github.com/mesonbuild/meson.git`
`ln -s /meson/meson.py /usr/bin/meson`

libgo2 development headers:

`git clone https://github.com/OtherCrashOverride/libgo2.git`
`cd libgo2`
`mkdir -p /usr/include/go2`
`cp src/*.h /usr/include/go2/`
