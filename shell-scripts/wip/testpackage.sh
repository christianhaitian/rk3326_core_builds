#!/bin/bash

if test -z "$*"
then
  echo " Nothing to add to a test package."
else
  for f in "$@"; do
      if [[ ! -e "$f" ]]; then
         echo Missing file: $f
         exit 1
      fi
  done
  sudo rm /roms/backup/arkosbackup.*
  sudo tar -zchvf /roms/backup/arkosbackup.tar.gz "$@"
  echo " ${@} has been backed up into /roms/backup/arkosbackup.tar.gz"
fi
