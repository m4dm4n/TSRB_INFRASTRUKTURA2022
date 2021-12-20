#!/bin/bash

fdisk -l | grep "Disk /dev/sd"

read -n 3 -p $'Select disk: \n' diskvar

function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

pause


#Convert MBR disk to GPT type

sgdisk --mbrtogpt /dev/$diskvar

# LINUX 1

sgdisk -n 1:1MiB:20GiB -t 0:8300 -c 0:"Linux1 SSD" /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# LINUX 2

sgdisk -n 2:0:+20GiB -t 0:8300 -c 0:"Linux2 SSD" /dev/$diskvar



sgdisk -p /dev/$diskvar
pause

# 1. GEN Windows10

sgdisk -n 3:0:+200GiB -t 0:0700 -c 0:"1GEN Virtualke" /dev/$diskvar



sgdisk -p /dev/$diskvar
pause

# 2. GEN Windows10

sgdisk -n 4:0:+200GiB -t 0:0700 -c 0:"2GEN Virtualke" /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# 3. GEN Windows10

sgdisk -n 5:0:+200GiB -t 0:0700 -c 0:"3GEN Virtualke" /dev/$diskvar



sgdisk -p /dev/$diskvar
pause

# 4. GEN Windows10

sgdisk -n 6:0:+200GiB -t 0:0700 -c 0:"4GEN Virtualke" /dev/$diskvar


sgdisk -p /dev/$diskvar
pause

# 5. GEN Windows10

sgdisk -n 7:0:+200GiB -t 0:0700 -c 0:"5GEN Virtualke" /dev/$diskvar



sgdisk -p /dev/$diskvar
pause

# RAZNO Windows10

sgdisk -n 8:0:+30GiB -t 0:0700 -c 0:"GENERAL Virtualke" /dev/$diskvar



sgdisk -p /dev/$diskvar
pause

# SEM1 Windows10

sgdisk -n 9:0:+100GiB -t 0:0700 -c 0:"SEM1 Virtualke" /dev/$diskvar



sgdisk -p /dev/$diskvar
pause

# SEM2 Windows10

sgdisk -n 10:0:+100GiB -t 0:0700 -c 0:"SEM2 Virtualke" /dev/$diskvar



sgdisk -p /dev/$diskvar
pause

# STORE Windows10

sgdisk -n 11:0:+400GiB -t 0:0700 -c 0:"SSD Backup" /dev/$diskvar

