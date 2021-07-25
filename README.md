# Script to automate the build of various Libretro cores, Retroark, and PPSSPP for use with RK3326 devices (including Chi, OGA, OGS, RG351P/M/V, and the RK2020)

### Assumptions:
This script was designed to work with 32bit and 64bit chroot Linux environments for the RK3326 chipset. \
See [this document](https://github.com/christianhaitian/rk3326_core_builds/blob/main/docs/chroot.md) for instructions on how to create them yourself. \
You can also download a prebuilt one I created by following the information [here](https://forum.odroid.com/viewtopic.php?p=306185#p306185)

This script is designed to only build cores, retroarch and PPSSPP that are compatible with the aarch64 or armhf environment it's run from.  So to build cores for the 32bit armhf environment, it should be run from an arm32 environment such as a 32bit chroot.

## How to use: (In a aarch64 chroot or armhf chroot or building from Ubuntu based distro on a RK3326 device)

```
git clone https://github.com/christianhaitian/rk3326_core_builds.git
cd rk3326_core_builds
```

### To build just retroarch:
`./rk3326_core_builds retroarch

### To build all cores defined in the script:
`./rk3326_core_builds all`

### To build just flycast:
`./rk3326_core_builds flycast`

### To build just mgba:
`./rk3326_core_builds mgba`

### To build just pcsx_rearmed (32bit only):
`./rk3326_core_builds pcsx_rearmed`

### To build just parallel-n64:
`./rk3326_core_builds parallel-n64`

### To clean the folder of all builds and gits
`./rk3326_core_builds clean`
