#!/bin/bash



# Define some variables here
#---------------------------

nvmeSizeinB=$(fdisk -l | grep nvme | cut -d " " -f5)
nvmeSizeinMB=$(($nvmeSizeinB/1024/1024))
nvmeSizeinGB=$(($nvmeSizeinB/1024/1024/1024))
hddSizeinB=$(fdisk -l | grep sda | cut -d " " -f5)
hddSizeinMB=$(($hddSizeinB/1024/1024))
hddSizeinGB=$(($hddSizeinB/1024/1024/1024))


linEfiPartinMB=500
linSwapinGB=16
linRootinGB=50
linHomeinGB=30

winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( $winRecoveryPartinMB / 1024 ))

#---------------------------

# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -e -n 7 -p $'Select SSD: \n' ssdVar
echo -e "\n"
read -e -n 3 -p $'Select HDD: \n' hddVar
echo -e "\n"

#---------------------------

# Define some functions here
#---------------------------
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

#---------------------------


#### PARTITIONING

# Create GPT structure on drives
sgdisk  --mbrtogpt /dev/$ssdVar >/dev/null 2>&1
sgdisk  --mbrtogpt /dev/$hddVar >/dev/null 2>&1 


#### CREATE PARTITIONS ON HDD
# LINUX 1
sgdisk -n 1:1MiB:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 2:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$hddVar >/dev/null 2>&1
sgdisk -n 3:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/$hddVar >/dev/null 2>&1
sgdisk -n 4:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/$hddVar >/dev/null 2>&1

# LINUX 2
sgdisk -n 5:0:+"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 6:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$hddVar >/dev/null 2>&1
sgdisk -n 7:0:+"$linRootinGB"GiB -t 0:8304 -c 0:root /dev/$hddVar >/dev/null 2>&1
sgdisk -n 8:0:+"$linHomeinGB"GiB -t 0:8302 -c 0:home /dev/$hddVar >/dev/null 2>&1

# 1. GEN Windows10
sgdisk -n 9:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 10:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 11:0:+100GiB -t 0:0700 -c 0:"1 Generacija"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 12:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 13:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# 2. GEN Windows10
sgdisk -n 14:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 15:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 16:0:+100GiB -t 0:0700 -c 0:"2 Generacija"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 17:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 18:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# 3. GEN Windows10
sgdisk -n 19:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 20:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 21:0:+100GiB -t 0:0700 -c 0:"3 Generacija"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 22:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 23:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# 4. GEN Windows10
sgdisk -n 24:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 25:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 26:0:+100GiB -t 0:0700 -c 0:"4 Generacija"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 27:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 28:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# 5. GEN Windows10
sgdisk -n 29:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 30:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 31:0:+100GiB -t 0:0700 -c 0:"5 Generacija"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 32:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 33:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# RAZNO Windows10
sgdisk -n 34:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 35:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 36:0:+100GiB -t 0:0700 -c 0:"Win10"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 37:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 38:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# SEM1 Windows10
sgdisk -n 39:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 40:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 41:0:+100GiB -t 0:0700 -c 0:"SEM1"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 42:0:+100GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 43:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# SEM2 Windows10
sgdisk -n 44:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 45:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 46:0:+100GiB -t 0:0700 -c 0:"SEM2"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 47:0:+100GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 48:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1

# STORE Windows10
sgdisk -n 49:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar >/dev/null 2>&1
sgdisk -n 50:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 51:0:+50GiB -t 0:0700 -c 0:"STORE"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 52:0:+1500GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar >/dev/null 2>&1
sgdisk -n 53:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar >/dev/null 2>&1


#### CREATE PARTITIONS ON SSD
# LINUX 1
sgdisk -n 1:1MiB:20GiB -t 0:8300 -c 0:"Linux1 SSD" /dev/$ssdVar >/dev/null 2>&1

# LINUX 2
sgdisk -n 2:0:+20GiB -t 0:8300 -c 0:"Linux2 SSD" /dev/$ssdVar >/dev/null 2>&1

# 1. GEN Windows10
sgdisk -n 3:0:+200GiB -t 0:0700 -c 0:"1GEN Virtualke" /dev/$ssdVar >/dev/null 2>&1

# 2. GEN Windows10
sgdisk -n 4:0:+200GiB -t 0:0700 -c 0:"2GEN Virtualke" /dev/$ssdVar >/dev/null 2>&1

# 3. GEN Windows10
sgdisk -n 5:0:+200GiB -t 0:0700 -c 0:"3GEN Virtualke" /dev/$ssdVar >/dev/null 2>&1

# 4. GEN Windows10
sgdisk -n 6:0:+200GiB -t 0:0700 -c 0:"4GEN Virtualke" /dev/$ssdVar >/dev/null 2>&1

# 5. GEN Windows10
sgdisk -n 7:0:+200GiB -t 0:0700 -c 0:"5GEN Virtualke" /dev/$ssdVar >/dev/null 2>&1

# RAZNO Windows10
sgdisk -n 8:0:+30GiB -t 0:0700 -c 0:"GENERAL Virtualke" /dev/$ssdVar >/dev/null 2>&1

# SEM1 Windows10
sgdisk -n 9:0:+100GiB -t 0:0700 -c 0:"SEM1 Virtualke" /dev/$ssdVar >/dev/null 2>&1

# SEM2 Windows10
sgdisk -n 10:0:+100GiB -t 0:0700 -c 0:"SEM2 Virtualke" /dev/$ssdVar >/dev/null 2>&1

# STORE Windows10
sgdisk -n 11:0:+400GiB -t 0:0700 -c 0:"SSD Backup" /dev/$ssdVar >/dev/null 2>&1