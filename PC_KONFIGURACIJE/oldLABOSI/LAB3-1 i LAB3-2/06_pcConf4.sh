#!/bin/bash

# Define some functions here
#---------------------------

# Pause function
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

clear
echo "--------------------------------------------------"
echo "Ovo je skripta za 4. konfiguraciju (2TB NVME, 4TB HDD)"
echo "--------------------------------------------------"

echo "--------------------------------------------------"
echo "OPREZ HDD je za OS i SSD je za DATA/VIRTUALNE STROJEVE"
echo "--------------------------------------------------"
pause 
# Available different locations and configurations
# LAB31_32_NASTAVNICKO (2)
# LAB31_32_UCENICKO (24)

# Define some variables here
#---------------------------
PS3="Select TeacherPC, StudentPC or EXIT the menu (1-3): "
nvmeSize=$(fdisk -l | grep nvme | cut -d " " -f5)
hddSize=$(fdisk -l | grep sda | cut -d " " -f5)
nvmeSizeinGB=$(( nvmeSize / 1024 / 1024 / 1024 ))
nvmeSizeinMB=$(( nvmeSize / 1024 / 1024 ))
hddSizeinGB=$(( hddSize / 1024 / 1024 / 1024 ))
hddSizeinMB=$(( hddSize / 1024 / 1024 ))

linEfiPartinMB=500
linSwapinGB=8
linRootinGB=50
linHomeinGB=10

winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( winRecoveryPartinMB / 1024 ))

#---------------------------

# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -n 7 -p $'Select SSD: \n' ssdVar
echo -e "\n"
read -n 3 -p $'Select HDD: \n' hddVar
echo -e "\n"

#---------------------------




# Create Partitions for TeacherPC
function TeacherPCpartitioning(){

# Calculate Windows System partition size
echo -e "\n"
winSystemPartinMB=$(($nvmeSizeinMB-$winEfiPartinMB-$msrPartinMB-$winRecoveryPartinMB-2))
echo "Windows System Partition size is: " $winSystemPartinMB "MB"
winDataPartinMB=$(( $hddSizeinMB-2 ))
echo "Windows Data Partition size is: " $winDataPartinMB "MB"
echo -e "\n"

# Convert all drives to GPT format
sgdisk --mbrtogpt /dev/$ssdVar
sgdisk --mbrtogpt /dev/$hddVar 

# Create partitions for Windows installer
echo "Create partitions on NVME drive"
echo -e "\n"
sgdisk -n 1:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$ssdVar
sgdisk -n 2:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$ssdVar
sgdisk -n 3:0:+"$winSystemPartinMB"MiB -t 0:0700 -c 0:"Windows11"  /dev/$ssdVar
sgdisk -n 4:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$ssdVar

# Create partitions for Windows DATA
echo "Create partitions on HDD drive"
echo -e "\n"
sgdisk -n 1:0:+"$winDataPartinMB"MiB -t 0:0700 -c 0:"DATA" /dev/$hddVar

sgdisk -p /dev/$ssdVar
sgdisk -p /dev/$hddVar
pause

exit
}


# Create Partitions for StudentPC
function StudentPCpartitioning()
{
# Convert all drives to GPT format
sgdisk --mbrtogpt /dev/$ssdVar
sgdisk --mbrtogpt /dev/$hddVar 

echo "Create partitions on HDD drive (system drive)"
echo -e "\n"


echo "Creating 2 Linux install partitions"
# LINUX 1
sgdisk -n 1:1MiB:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 2:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$hddVar
sgdisk -n 3:0:+"$linRootinMB"GiB -t 0:8304 -c 0:root /dev/$hddVar
sgdisk -n 4:0:+"$linHomeinMB"GiB -t 0:8302 -c 0:home /dev/$hddVar
# LINUX 2
sgdisk -n 5:0:"$linEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 6:0:+"$linSwapinGB"GiB -t 0:8200 -c 0:swap /dev/$hddVar
sgdisk -n 7:0:+"$linRootinMB"GiB -t 0:8304 -c 0:root /dev/$hddVar
sgdisk -n 8:0:+"$linHomeinMB"GiB -t 0:8302 -c 0:home /dev/$hddVar

echo "Creating Windows install partitions"
# 1. GEN Windows10
sgdisk -n 9:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 10:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 11:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 12:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 13:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# 2. GEN Windows10
sgdisk -n 14:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 15:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 16:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 17:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 18:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# 3. GEN Windows10
sgdisk -n 19:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 20:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 21:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 22:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 23:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# 4. GEN Windows10
sgdisk -n 24:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 25:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 26:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 27:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 28:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# 5. GEN Windows10
sgdisk -n 29:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 30:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 31:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 32:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 33:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# RAZNO Windows10
sgdisk -n 34:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 35:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 36:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 37:0:+50GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 38:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# SEM 1 Windows10
sgdisk -n 39:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 40:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 41:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 42:0:+100GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 43:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# SEM 2 Windows10
sgdisk -n 44:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 45:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 46:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 47:0:+100GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 48:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar
# STORE Windows10
sgdisk -n 49:0:+"$winEfiPartinMB"MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$hddVar
sgdisk -n 50:0:+"$msrPartinMB"MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/$hddVar
sgdisk -n 51:0:+100GiB -t 0:0700 -c 0:"Windows11"  /dev/$hddVar
sgdisk -n 52:0:+1500GiB -t 0:0700 -c 0:"DATA"  /dev/$hddVar
sgdisk -n 53:0:+"$winRecoveryPartinMB"MiB -t 0:2700 -c 0:"MS Recovery"  /dev/$hddVar

exit
}

#---------------------------

select i in TeacherPC StudentPC exit
do
	case $i in
		TeacherPC) TeacherPCpartitioning;;
		StudentPC) echo "This is StudentPC";;
		exit) exit;;
	esac
done

echo -e "\n"





#---------------------------

# Create Partitions for StudentPC
#---------------------------