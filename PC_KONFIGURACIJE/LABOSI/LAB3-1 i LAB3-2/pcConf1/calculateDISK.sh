#!/bin/bash

#nvmeSizeinB=$(fdisk -l | grep nvme | cut -d " " -f5)
#nvmeSizeinMB=$(($nvmeSizeinB/1024/1024))
#nvmeSizeinGB=$(($nvmeSizeinB/1024/1024/1024))
#hddSizeinB=$(fdisk -l | grep sda | cut -d " " -f5)
#hddSizeinMB=$(($hddSizeinB/1024/1024))
#hddSizeinGB=$(($hddSizeinB/1024/1024/1024))


#echo "nvmeSizeinGB: " $nvmeSizeinGB
#echo "nvmeSizeinMB: " $nvmeSizeinMB
#echo "hddSizeinGB: " $hddSizeinGB
#echo "hddSizeinMB: " $hddSizeinMB


TotalFreeSectorsNVME=$(sgdisk -p /dev/nvme0n1 | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBNVME=$((TotalFreeSectorsNVME*512))
TotalFreeinMBNVME=$((TotalFreeinBNVME/1024/1024))
TotalFreeinGBNVME=$((TotalFreeinMBNVME/1024))

winBACKUPinMB=$(($TotalFreeinMBNVME-$winEfiPartinMB-$msrPartinMB-$winRecoveryPartinMB-2))
echo "WIN BACKUP SIZE " $winBACKUPinMB

