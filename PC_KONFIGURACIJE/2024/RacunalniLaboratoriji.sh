#!/bin/bash


# Define DATA and SYSTEM drive
dataDrive=sda
sysDrive=nvme0n1


#Clear all GPT structures
sgdisk --zap-all /dev/$dataDrive >/dev/null 2>&1
sgdisk --zap-all /dev/$sysDrive >/dev/null 2>&1

# Create GPT structure
sgdisk  --mbrtogpt /dev/$dataDrive >/dev/null 2>&1
sgdisk  --mbrtogpt /dev/$sysDrive >/dev/null 2>&1



#Create Linux partitions
sgdisk -n 1:1MiB:500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+8GiB -t 0:8200 -c 0:swap /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+30GiB -t 0:8304 -c 0:root /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+50GiB -t 0:8302 -c 0:home /dev/$sysDrive >/dev/null 2>&1

#Create Win01 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows01"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10000MiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win02 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows02"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win03 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows03"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win04 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows04"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win05 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"Windows05"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1

#Create Win06 partitions
sgdisk -n 0:0:+500MiB -t 0:ef00 -c 0:"EFI System Partition" /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+128MiB -t 0:0c01 -c 0:"MS Reserved"  /dev/"$sysDrive" >/dev/null 2>&1
sgdisk -n 0:0:+100GiB -t 0:0700 -c 0:"WindowsSEM"  /dev/$sysDrive >/dev/null 2>&1
sgdisk -n 0:0:+10GiB -t 0:2700 -c 0:"MS Recovery"  /dev/"$sysDrive" >/dev/null 2>&1



#Modify Partitions UUID
#Linux
sgdisk --partition-guid=1:54535242-4D42-4D53-5A47-4C494E303031 /dev/nvme0n1
sgdisk --partition-guid=2:54535242-4D42-4D53-5A47-4C494E303032 /dev/nvme0n1
sgdisk --partition-guid=3:54535242-4D42-4D53-5A47-4C494E303033 /dev/nvme0n1
sgdisk --partition-guid=4:54535242-4D42-4D53-5A47-4C494E303034 /dev/nvme0n1

#Win01
sgdisk --partition-guid=5:54535242-4D42-4D53-5A47-57494E303031 /dev/nvme0n1
sgdisk --partition-guid=6:54535242-4D42-4D53-5A47-57494E303032 /dev/nvme0n1
sgdisk --partition-guid=7:54535242-4D42-4D53-5A47-57494E303033 /dev/nvme0n1
sgdisk --partition-guid=8:54535242-4D42-4D53-5A47-57494E303034 /dev/nvme0n1

#Win02
sgdisk --partition-guid=9:54535242-4D42-4D53-5A47-57494E303035 /dev/nvme0n1
sgdisk --partition-guid=10:54535242-4D42-4D53-5A47-57494E303036 /dev/nvme0n1
sgdisk --partition-guid=11:54535242-4D42-4D53-5A47-57494E303037 /dev/nvme0n1
sgdisk --partition-guid=12:54535242-4D42-4D53-5A47-57494E303038 /dev/nvme0n1

#Win03
sgdisk --partition-guid=13:54535242-4D42-4D53-5A47-57494E303039 /dev/nvme0n1
sgdisk --partition-guid=14:54535242-4D42-4D53-5A47-57494E303130 /dev/nvme0n1
sgdisk --partition-guid=15:54535242-4D42-4D53-5A47-57494E303131 /dev/nvme0n1
sgdisk --partition-guid=16:54535242-4D42-4D53-5A47-57494E303132 /dev/nvme0n1

#Win04
sgdisk --partition-guid=17:54535242-4D42-4D53-5A47-57494E303133 /dev/nvme0n1
sgdisk --partition-guid=18:54535242-4D42-4D53-5A47-57494E303134 /dev/nvme0n1
sgdisk --partition-guid=19:54535242-4D42-4D53-5A47-57494E303135 /dev/nvme0n1
sgdisk --partition-guid=20:54535242-4D42-4D53-5A47-57494E303136 /dev/nvme0n1

#Win05
sgdisk --partition-guid=21:54535242-4D42-4D53-5A47-57494E303137 /dev/nvme0n1
sgdisk --partition-guid=22:54535242-4D42-4D53-5A47-57494E303138 /dev/nvme0n1
sgdisk --partition-guid=23:54535242-4D42-4D53-5A47-57494E303139 /dev/nvme0n1
sgdisk --partition-guid=24:54535242-4D42-4D53-5A47-57494E303230 /dev/nvme0n1

#Win06
sgdisk --partition-guid=25:54535242-4D42-4D53-5A47-57494E303231 /dev/nvme0n1
sgdisk --partition-guid=26:54535242-4D42-4D53-5A47-57494E303232 /dev/nvme0n1
sgdisk --partition-guid=27:54535242-4D42-4D53-5A47-57494E303233 /dev/nvme0n1
sgdisk --partition-guid=28:54535242-4D42-4D53-5A47-57494E303234 /dev/nvme0n1



#Creating Filesystems
#Linux SWAP
mkswap /dev/nvme0n1p2
#Linux EXT4
for i in {3,4}; do mkfs.ext4 /dev/nvme0n1p$i; done
#WinXY FAT32
for i in {1,5,9,13,17,21,25}; do mkfs.vfat -F 32 /dev/nvme0n1p$i; done
#WinXY NTFS
for i in {7,8,11,12,15,16,19,20,23,24,27,28}; do mkfs.ntfs -Q /dev/nvme0n1p$i; done
