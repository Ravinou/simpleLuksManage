#!/bin/bash

#By Raven - 12/08/2022

###### Parameters
mountPoint=/datas-enc
lvName=/dev/VG1/datasLuksLV
luksName=datasLuks
service=apache2
######

#Check if the partition is already mount or not.
#Case 1 : partition is already mount, ask for unmount or cancel.
if grep -qs /dev/mapper/$luksName /proc/mounts; then
	if (whiptail --title "Unmounting the encrypted partition" --yesno "Would you like to unmount the partition and close the encrypted container ?" 8 78); then
		umount $mountPoint
		{
		    for ((i = 0 ; i <= 100 ; i+=5)); do
		        sleep 0.1
  		        echo $i
		    done
		} | whiptail --gauge "In progress, please wait..." 6 50 0

		cryptsetup luksClose $luksName
		{
		    for ((i = 0 ; i <= 100 ; i+=5)); do
		        sleep 0.1
  		        echo $i
		    done
		} | whiptail --gauge "Closing the encrypted LUKS volume..." 6 50 0
    		echo "Partition is unmount"
	else
    		echo "Program completed"
	fi
#Case 2 : partition is not mount, ask password, mount, restart the service and display it's status. 	
else
	PASSWORD=$(whiptail --title "Decrypt partition" --passwordbox "Encryption passphrase" 10 60 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    		echo "$PASSWORD" | cryptsetup luksOpen $lvName $luksName
	    	mount /dev/mapper/$luksName $mountPoint
		/etc/init.d/$service restart
		/etc/init.d/$service status
	else
    		echo "You have canceled"
	fi
fi