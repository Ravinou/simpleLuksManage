#!/bin/bash

#By Raven - 12/08/2022

#Objective of this script: send an alert email as soon as possible + 1 email every "x" hour if the mount of the encrypted volume is not effective.

#Installation :
#1- Put this script in /usr/local/bin/checkMontageLuks for example.
#2- Modify the luksMapper and mail variables for your needs.
#3- Create the file /usr/local/bin/semaphore.tmp
#4- Create a cron job with the following two lines, to be adapted to your needs :
# */5 * * * * root /usr/local/bin/checkMontageLuks.sh
# * 6,20 * * * root echo "1" > /usr/local/bin/semaphore.tmp


#HOW IT WORKS :
#If our variable sema = 1 it means that the assembly is done.
#
# My algorithm :
#if the mount is active AND sema = 1
#   then do nothing
#else if the mount is active AND sema = 0
#   then we change sema to 1
#else if the mount is inactive AND sema = 1
#   then we set sema to 1 + send an email.
#else if the mount is inactive AND sema = 0
#   then do nothing
#
# We set the sema to 1 with a cron task every "x" hour to limit the mail flow to 2 mails per day in case of unmount. 
# You can vary this cron task to choose the number of alert emails per day.

##### PARAMETERS TO ADAPT
luksMapper=/dev/mapper/datasLuks
sema=/usr/local/bin/semaphore.tmp
mail=
serverName=
#####

if grep -qs $luksMapper /proc/mounts && grep -qs 0 $sema ; then
	echo "1" > /usr/local/bin/semaphore.tmp	
#    echo "test"
elif ! grep -qs $luksMapper /proc/mounts && grep -qs 1 $sema ; then
	echo "0" > /usr/local/bin/semaphore.tmp
	echo "Manual action required. Volume $luksMapper not mounted !" | mail -s "$serverName : Encrypted volume not mounted !" $mail
#    echo "envoi mail"
fi