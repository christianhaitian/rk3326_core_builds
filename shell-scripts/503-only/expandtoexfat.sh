#!/bin/bash
sudo umount /roms
sudo ln -s /dev/mmcblk1p5 /dev/hda3
sudo chmod 666 /dev/tty1
export TERM=linux
height="15"
width="55"
if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ] || [ -f "/boot/rk3566.dtb" ]; then
  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  height="20"
  width="60"
fi
[ ! -f /boot/doneit ] && { sudo echo ", +" | sudo sfdisk -N 5 --force /dev/mmcblk1; sudo touch "/boot/doneit"; dialog --infobox "EASYROMS partition expansion and conversion to exfat in process.  Please press the reset button now to reboot the device so this process can continue." $height $width 2>&1 > /dev/tty1 | sleep 10; sudo reboot; }
sudo mkfs.exfat -s 16K -n EASYROMS /dev/hda3
exitcode=$?
sync
sleep 2
sudo fsck.exfat -a /dev/hda3
sync
sleep 2
sudo mount -t exfat -w /dev/mmcblk1p5 /roms
sleep 2
sudo tar -xvf /roms.tar -C /
sync
reqSpace=1000000
availSpace=$(df "/roms" | awk 'NR==2 { print $4 }')
if (( availSpace < reqSpace )); then
  sudo rm -rf -v /tempthemes/es-theme-epic-cody*/
fi
sudo rm -rf -v /roms/themes/es-theme-nes-box/
# Setup swapfile
printf "\n\n\e[32mSetting up swapfile.  Please wait...\n"
printf "\033[0m"
sudo dd if=/dev/zero of=/swapfile bs=1024 count=262144
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo mv -f -v /tempthemes/* /roms/themes
sync
sleep 1
sudo rm -rf -v /tempthemes
sleep 2
sudo umount /roms
sudo cp /boot/fstab.exfat /etc/fstab
sync
sudo rm -f /boot/doneit
if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3566.dtb" ]; then
  sudo rm -f /roms.tar
fi
sudo rm -f /boot/fstab.exfat
# Disable and delete swapfile
sudo swapoff /swapfile
sudo rm -f -v /swapfile
if [ $exitcode -eq 0 ]; then
  systemctl disable firstboot.service
  sudo rm -v /boot/firstboot.sh
  sudo rm -v -- "$0"
  dialog --infobox "Completed expansion of EASYROMS partition and conversion to exfat. Please press the reset button now to reboot the system." $height $width 2>&1 > /dev/tty1 | sleep 10
  sudo reboot
else
  dialog --infobox "EASYROMS partition expansion and conversion to exfat failed for an unknown reason.  Please expand the partition using an alternative tool such as Minitool Partition Wizard.  System will reboot and load Emulationstation now." $height $width 2>&1 > /dev/tty1 | sleep 10
  systemctl disable firstboot.service
  sudo rm -v /boot/firstboot.sh
  sudo rm -v -- "$0"
  sudo reboot
fi
