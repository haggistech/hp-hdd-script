#!/bin/bash -       

#==========================================================================================================================
#
# Title          : HyperPie Hard Drive Script
# Description    : This script will detect an external Hard Drive plugged into you pi and mount it under /home/pi/Retropie/
# Author	 : Mik McLean
# Date           : 20171117
# Version        : 0.1    
# Usage		 : ./hp-hdd-script.sh
# Notes          : Install Vim and Emacs to use this script.
#
#==========================================================================================================================


sudo grep UUID /etc/fstab > /dev/null 2>&1
if [ $? -eq 0 ] ; then
echo "It seems you already have an external drive mapped. Please run the "Remove Drive Expansion" script."
sleep 10
exit
fi

#mkdir /home/pi/addonusb > /dev/null 2>&1
#mkdir /home/pi/.work > /dev/null 2>&1

findhdd=`df |grep media |awk '{print $1 }'|wc -l`

if [ $findhdd -eq 0 ] ; then
echo "Please Plug in an External Drive"
sleep 2
exit
fi


if [ $findhdd -eq 1 ] ; then
clear
df |grep 'media/'
echo
echo
echo "1 Partition Found, Continuing...."
extdrive=`df |grep media |awk '{print $1 }'`
usbdest=`df |grep media |awk '{print $6 }'`
echo
sleep 2
else
clear
echo "More than one partiton found on device..."
echo
df |grep 'media/'
echo
echo
printf "Please select a Partition to use:\n\n"; select d in $(df |grep 'media/' |awk '{print $1 }');  do test -n "$d" && break; echo ">>> Invalid Selection"; done; extdrive="$d"; usbdest=`df |grep "$d" |awk '{print $6 }'`
fi

echo $extdrive
echo $usbdest




sudo mv -v /home/pi/RetroPie/* $usbdest/
sleep 2

destfs=`df -T | grep $extdrive | awk '{print $2}'`

echo
echo "Destination file system detected as $destfs"
echo

usbpath=`df -T |grep $extdrive |awk '{print $1 }'|awk -F'/' '{print $3 }'`
usbuuid=`ls -l /dev/disk/by-uuid/|grep $usbpath|awk '{print $9 }'`


if [ "$destfs" = "ntfs" ] ; then
echo "Adding mount point to /etcfstab"
sudo sh -c "echo 'UUID=$usbuuid  /home/pi/RetroPie      $destfs    nofail,user,umask=0000  0       2' >> /etc/fstab"
sleep 10
fi

if [ "$destfs" = "vfat" ] ; then
echo "Adding mount point to /etcfstab"
sudo sh -c "echo 'UUID=$usbuuid  /home/pi/RetroPie      $destfs    rw,exec,uid=pi,gid=pi,umask=022 0       2' >> /etc/fstab"
sleep 5
fi

echo "Rebooting now...."
sleep 3
sudo reboot
echo
echo "Drive Mount successful"
echo