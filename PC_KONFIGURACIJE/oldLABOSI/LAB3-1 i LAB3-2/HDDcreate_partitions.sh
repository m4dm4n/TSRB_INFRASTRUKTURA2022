#!/bin/bash

sudo fdisk -l | grep "Disk /dev/sd"

read -n 3 -p $'Select disk: \n' diskvar

function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}


pause


#Convert MBR disk to GPT type

sgdisk --mbrtogpt /dev/$diskvar

# LINUX 1

sgdisk -n 1:1MiB:300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 2:0:+16GiB -t 0:8200 -c 0:swap /dev/$diskvar

sgdisk -n 3:0:+50GiB -t 0:8304 -c 0:root /dev/$diskvar

sgdisk -n 4:0:+30GiB -t 0:8302 -c 0:home /dev/$diskvar

sgdisk -p /dev/$diskvar
pause

# LINUX 2

sgdisk -n 5:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 6:0:+16GiB -t 0:8200 -c 0:swap /dev/$diskvar

sgdisk -n 7:0:+50GiB -t 0:8304 -c 0:root /dev/$diskvar

sgdisk -n 8:0:+30GiB -t 0:8302 -c 0:home /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# 1. GEN Windows10

sgdisk -n 9:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 10:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 11:0:+100GiB -t 0:0700 -c 0:"1 Generacija"  /dev/$diskvar

sgdisk -n 12:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 13:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# 2. GEN Windows10

sgdisk -n 14:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 15:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 16:0:+100GiB -t 0:0700 -c 0:"2 Generacija"  /dev/$diskvar

sgdisk -n 17:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 18:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# 3. GEN Windows10

sgdisk -n 19:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 20:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 21:0:+100GiB -t 0:0700 -c 0:"3 Generacija"  /dev/$diskvar

sgdisk -n 22:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 23:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# 4. GEN Windows10

sgdisk -n 24:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 25:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 26:0:+100GiB -t 0:0700 -c 0:"4 Generacija"  /dev/$diskvar

sgdisk -n 27:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 28:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# 5. GEN Windows10

sgdisk -n 29:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 30:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 31:0:+100GiB -t 0:0700 -c 0:"5 Generacija"  /dev/$diskvar

sgdisk -n 32:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 33:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# RAZNO Windows10

sgdisk -n 34:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 35:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 36:0:+100GiB -t 0:0700 -c 0:"Win10"  /dev/$diskvar

sgdisk -n 37:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 38:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# SEM1 Windows10

sgdisk -n 39:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 40:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 41:0:+100GiB -t 0:0700 -c 0:"SEM1"  /dev/$diskvar

sgdisk -n 42:0:+100GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 43:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# SEM2 Windows10

sgdisk -n 44:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 45:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 46:0:+100GiB -t 0:0700 -c 0:"SEM2"  /dev/$diskvar

sgdisk -n 47:0:+100GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 48:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# STORE Windows10

sgdisk -n 49:0:+300MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$diskvar

sgdisk -n 50:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$diskvar

sgdisk -n 51:0:+50GiB -t 0:0700 -c 0:"STORE"  /dev/$diskvar

sgdisk -n 52:0:+1500GiB -t 0:0700 -c 0:"DATA"  /dev/$diskvar

sgdisk -n 53:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/$diskvar


# PUT HIDDEN ATTRIBUTE ON MS RECOVERY PARTITIONS 

for i in {13,18,23,28,33,38,43,48,53} 
do
sudo sgdisk --attributes=$i:set:0:2 /dev/$diskvar
done
