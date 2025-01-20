#!/bin/bash
if [ ! -d "/mnt/usbdrive/" ]; then
    sudo mkdir /mnt/usbdrive
fi

filesystem=`lsblk -no FSTYPE /dev/sda1`
if [ "$filesystem" = "ntfs" ]; then
	filesystem="ntfs-3g"
fi

altCharSet=""
if [[ "$filesystem" =~ ^(vfat|fat16|fat32|ntfs|ntfs_3g)$ ]]; then
	altCharSet=",iocharset=iso8859-1"
fi

sudo mount -t $filesystem /dev/sda1 /mnt/usbdrive -o uid=1002,gid=1002$altCharSet
status=$?

if test $status -eq 0
then
  printf "\n\n\e[32m$filesystem USB drive is mounted to /mnt/usbdrive...\n"
  printf "\033[0m"
  sleep 3
else
  printf "\n\n\e[91mCould not find a Fat, Fat32, Exfat, or NTFS based USB drive to mount...\n"
  printf "\033[0m"
  sleep 3
fi
