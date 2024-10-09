#!/bin/bash

# Suppress terminal interactive warnings
# see : https://www.debian-fr.org/t/debconf-utilisation-de-linterface-readline-en-remplacement/74484/3
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y linux-headers-$(uname -r) dkms


echo "CHECKING DIR FOR GUEST ADDITIONS FILE"
ls /home/$SU_USR

# Mount the disk image
cd /tmp
mkdir isomount
mount /home/$SU_USR/VBoxGuestAdditions.iso /tmp/isomount

# Install the drivers
# used to return error exit code even after successful install
# so using workaround for exit code after checking that install is OK
# see last two answers : https://stackoverflow.com/questions/25434139/vboxlinuxadditions-run-never-exits-with-0
/tmp/isomount/VBoxLinuxAdditions.run --nox11 || true

if ! test -f /usr/sbin/VBoxService
then
  echo "NTR log : Installation of guest additions were unsuccessful"
  exit 1
fi

# Cleanup
umount /tmp/isomount
rm -rf /tmp/isomount