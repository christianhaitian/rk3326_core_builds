# Script to automate the build of various Libretro cores for use with RK3326 devices (including Chi, OGA, OGS, RG351P/M/V, and the RK2020)

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

### To build just pcsx_rearmed:
`./rk3326_core_builds pcsx_rearmed`

### To build just parallel-n64:
`./rk3326_core_builds parallel-n64`


### To clean the folder of all builds and gits
`./rk3326_core_builds clean`

