#!/bin/bash
# Auto launched during the first boot of ArkOS after initial flash then deleted upon completion

sudo umount /roms
sudo ln -s /dev/mmcblk0 /dev/hda
sudo ln -s /dev/mmcblk0p3 /dev/hda3
[ ! -f /boot/doneit ] && { sudo echo ", +" | sudo sfdisk -N 3 --force /dev/mmcblk0; sudo touch "/boot/doneit"; msgbox "EASYROMS partition expansion and conversion to exfat in process.  Please be patient as the system will reboot 2 to 3 times to complete this.  Hit A to continue."; reboot; }
sudo ntfsfix -d /dev/hda3
sudo ntfsresize -ff -x /dev/hda3
sudo ntfsfix -d /dev/hda3
sudo mkfs.exfat -s 8K -n EASYROMS /dev/hda3
sync
sleep 2
sudo fsck.exfat -a /dev/hda3
sync
sleep 2
sudo mount -t exfat -w /dev/mmcblk0p3 /roms
sleep 2
sudo tar -xvf /roms.tar -C /
sync
reqSpace=1000000
availSpace=$(df "/roms" | awk 'NR==2 { print $4 }')
if (( availSpace < reqSpace )); then
  sudo rm -rf -v /tempthemes/es-theme-epic-cody-RG351P-M/
fi
sudo rm -rf -v /roms/themes/es-theme-nes-box/
# Setup swapfile
printf "\n\n\e[32mSetting up swapfile.  Please wait...\n"
printf "\033[0m"
sudo dd if=/dev/zero of=/swapfile bs=1024 count=262144
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
sudo rm -f /roms.tar
sudo rm -f /boot/fstab.exfat
exitcode=$?
# Disable and delete swapfile
sudo swapoff /swapfile
sudo rm -f -v /swapfile
if [ $exitcode -eq 0 ]; then msgbox "Completed expansion of EASYROMS partition and conversion to exfat. System will reboot and load Emulationstation now after you hit the A button."
systemctl disable firstboot.service
sudo rm -v /boot/firstboot.sh
sudo rm -v -- "$0"
reboot
else
msgbox "EASYROMS partition expansion and conversion to exfat failed for an unknown reason.  Please expand the partition using an alternative tool such as Minitool Partition Wizard.  System will reboot and load Emulationstation now after you hit the A button."
systemctl disable firstboot.service
sudo rm -v /boot/firstboot.sh
sudo rm -v -- "$0"
reboot
fi
