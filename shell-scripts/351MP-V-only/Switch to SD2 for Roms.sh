#!/bin/bash

if [ ! -d "/roms2/" ]; then
    sudo mkdir /roms2
fi

blkchk=`lsblk -no FSTYPE /dev/mmcblk1p1`
blkstatus=$?

if test $blkstatus -eq 0
then
    blklocation="/dev/mmcblk1p1"
    blklocationforsed="dev\/mmcblk1p1"
else
    blklocation="/dev/mmcblk1"
    blklocationforsed="dev\/mmcblk1"
fi

filesystem=`lsblk -no FSTYPE $blklocation`
if [ "$filesystem" = "ntfs" ]; then
	filesystem="ntfs-3g"
fi

sudo umount /opt/system/Tools

if [ "$filesystem" = "ext4" ]; then
   sudo mount -t $filesystem $blklocation /roms2
else
   sudo mount -t $filesystem $blklocation /roms2 -o umask=0000,iocharset=utf8
fi

status=$?

if test $status -eq 0
then

  # Setup swapfile
  printf "\n\n\e[32mSetting up swapfile.  Please wait...\n"
  printf "\033[0m"
  sudo dd if=/dev/zero of=/swapfile bs=1024 count=262144
  sudo mkswap /swapfile
  sudo swapon /swapfile

  if [ ! -d "/roms2/videos/" ]; then
      sudo mkdir /roms2/videos
  fi
  sudo mount /roms2/tools /opt/system/Tools
  sed -i '/<path>\/roms\//s//<path>\/roms2\//' /etc/emulationstation/es_systems.cfg
  if [ "$filesystem" = "ext4" ]; then
     sudo sed -i '$a\/'"$blklocationforsed"' \/roms2 '"$filesystem"' defaults 0 1' /etc/fstab
  else
     sudo sed -i '$a\/'"$blklocationforsed"' \/roms2 '"$filesystem"' umask=0000,iocharset=utf8,noatime 0 0' /etc/fstab
  fi
  sudo sed -i '/roms\/tools/s//roms2\/tools/' /etc/fstab
  sudo sed -i '/roms\/pico-8/s//roms2\/pico-8/g' /usr/local/bin/pico8.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/scummvm.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/ti99.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/dreamcast.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/doom.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/saturn.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/atomiswave.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/naomi.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/singe.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/easyrpg.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/ecwolf.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/drastic.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/ppsspp.sh
  sudo sed -i '/roms\//s//roms2\//g' /opt/system/PS1\ -\ Generate\ m3u\ files.sh
  sudo sed -i '/roms\//s//roms2\//g' /opt/system/PS1\ -\ Delete\ m3u\ files.sh
  sed -i '/roms\//s//roms2\//' /home/ark/.CommanderGenius/cgenius.cfg
  sed -i '/roms/s//roms2/g'  /home/ark/.config/retroarch/retroarch.cfg
  sed -i '/roms/s//roms2/g'  /home/ark/.config/retroarch32/retroarch.cfg
  sed -i '/roms/s//roms2/g'  /home/ark/.atari800.cfg
  sed -i '/roms/s//roms2/g'  /home/ark/.config/retroarch/config/Atari800/retroarch_5200.cfg
  sed -i '/roms/s//roms2/g'  /home/ark/.config/retroarch/config/Atari800/retroarch_A800.cfg
  sed -i '/roms/s//roms2/g'  /home/ark/.config/retroarch/config/Atari800/retroarch_XEGS.cfg
  sed -i '/roms/s//roms2/g'  /home/ark/.config/mupen64plus/mupen64plus.cfg
  sed -i '/roms\/bios/s//roms2\/bios/g' /opt/amiberry/conf/amiberry.conf
  sed -i '/.\/351Files 2/s//.\/351Files-sd2 2/g' /opt/system/351Files.sh
  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/scummvm.sh
  sudo cp /usr/local/bin/Switch\ to\ main\ SD\ for\ Roms.sh /opt/system/Advanced/.
  sudo rm /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
  sudo tar -xvkf /roms.tar -C /roms2/
  sudo mv -v -f -n /roms2/roms/* /roms2/
  unlink /opt/hypseus/roms
  ln -sfv /roms2/daphne/roms/ /opt/hypseus/roms
  unlink /opt/hypseus-singe/singe
  if [ ! -d "/roms2/alg/" ]; then
      sudo mkdir /roms2/alg
  fi
  sudo cp -f -v -r /roms/alg/Scan_for_new_games.alg /roms2/alg/Scan_for_new_games.alg
  sudo sed -i '/roms\//s//roms2\//g' /roms2/easyrpg/Scan_for_new_games.alg
  ln -sfv /roms2/alg/ /opt/hypseus-singe/singe
  unlink /home/ark/.emulationstation/music
  ln -sfv /roms2/bgmusic/ /home/ark/.emulationstation/music
  sudo sed -i '/roms\/scummvm/s//roms2\/scummvm/g' /roms2/scummvm/Scan_for_new_games.scummvm
  sudo touch /roms2/scummvm/Scan_for_new_games.scummvm
  sudo sed -i '/roms\/scummvm/s//roms2\/scummvm/g' /roms2/bios/scummvm.ini
  sudo sed -i '/roms\//s//roms2\//g' /roms2/alg/Scan_for_new_games.alg
  sudo cp -f -v -r /roms/easyrpg/Scan_for_new_games.easyrpg /roms2/easyrpg/Scan_for_new_games.easyrpg
  sudo sed -i '/roms\//s//roms2\//g' /roms2/easyrpg/Scan_for_new_games.easyrpg
  sudo cp -f -v -r /roms/wolf/Scan_for_new_games.wolf /roms2/wolf/Scan_for_new_games.wolf
  sudo sed -i '/roms\//s//roms2\//g' /roms2/wolf/Scan_for_new_games.wolf
  sudo cp -f -r -v /roms/ports/* /roms2/ports/
  unlink /opt/drastic/backup
  ln -sf /roms2/nds/backup/ /opt/drastic/backup
  unlink /opt/drastic/cheats
  ln -sf /roms2/nds/cheats/ /opt/drastic/cheats
  unlink /opt/drastic/savestates
  ln -sf /roms2/nds/savestates/ /opt/drastic/savestates
  unlink /opt/drastic/slot2
  ln -sf /roms2/nds/slot2/ /opt/drastic/slot2
  unlink /home/ark/.config/ppsspp
  ln -sf /roms2/psp/ppsspp/ /home/ark/.config/ppsspp
  sudo rm -rf /roms2/roms/
  sudo cp -f /etc/samba/smb.conf.sd2 /etc/samba/smb.conf
  if [ "$filesystem" = "ext4" ]; then
     sudo chown -R ark:ark /roms2/
  fi
  sudo pkill filebrowser
  filebrowser -d /home/ark/.config/filebrowser.db users update ark --scope "/roms2"
  printf "\n\n\e[32m$filesystem sdcard in slot2 is mounted to /roms2...\n"
  printf "\033[0m"
  sleep 3
  printf "\033c" >> /dev/tty1
  sudo swapoff /swapfile
  sudo rm -f -v /swapfile
  sudo systemctl restart emulationstation
else
  printf "\n\n\e[91mCould not find a Fat, Fat32, Exfat, EXT4, or NTFS based sdcard to mount from slot2...\n"
  printf "\033[0m"
  sleep 5
  printf "\033c" >> /dev/tty1
fi
