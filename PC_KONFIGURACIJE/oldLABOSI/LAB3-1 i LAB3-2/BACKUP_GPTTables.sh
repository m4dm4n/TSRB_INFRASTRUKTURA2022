#!/bin/bash

# Define start variables

export saveDIR=~/BACKUP

# Define some functions

function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}



# BACKUP GPT TABLES
# The resulting file is a binary file consisting of the protective MBR, the main GPT 
# header, the backup GPT header, and one copy of the partition table, in that order. 

sudo fdisk -l | grep "Disk /dev/sd"


read -n 3 -p $'Select SSD: \n' ssdvar

read -n 3 -p $'Select HDD: \n' hddvar


mkdir -p ~/BACKUP/HDD
mkdir ~/BACKUP/HDD/Linux1
mkdir ~/BACKUP/HDD/Linux2
for i in {1..5};do mkdir ~/BACKUP/HDD/Gen$i\Win10;done
mkdir ~/BACKUP/HDD/RaznoWin10
mkdir ~/BACKUP/HDD/Sem1Win10
mkdir ~/BACKUP/HDD/Sem2Win10
mkdir ~/BACKUP/HDD/StoreWin10

mkdir ~/BACKUP/SSD
mkdir ~/BACKUP/SSD/Linux1
mkdir ~/BACKUP/SSD/Linux2
for i in {1..5};do mkdir ~/BACKUP/SSD/Gen$i\Win10;done
mkdir ~/BACKUP/SSD/RaznoWin10
mkdir ~/BACKUP/SSD/Sem1Win10
mkdir ~/BACKUP/SSD/Sem2Win10
mkdir ~/BACKUP/SSD/StoreWin10



sudo -E sgdisk --backup=$saveDIR/HDD/00_HDD_ALLPARTITIONS.gpt /dev/$hddvar
sudo -E sgdisk --backup=$saveDIR/SSD/00_SSD_ALLPARTITIONS.gpt /dev/$ssdvar