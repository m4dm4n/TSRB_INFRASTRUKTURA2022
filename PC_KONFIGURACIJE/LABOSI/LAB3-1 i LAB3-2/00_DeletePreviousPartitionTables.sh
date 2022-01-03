#!/bin/bash

# DELETE BACKUP FOLDER
rm -r ~/BACKUP



# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -e -n 7 -p $'Select SSD: \n' ssdVar
echo -e "\n"
read -e -n 3 -p $'Select HDD: \n' hddVar
echo -e "\n"

sgdisk -p /dev/$ssdVar
sgdisk -p /dev/$hddVar


#### DELETING PARTITION TABLES

echo "Slijedeci korak je brisanje GPT tablica sa svih diskova, nastavak?"

select yn in "Yes" "No";do
     case $yn in
          Yes)
          sudo sgdisk -Z /dev/$ssdVar
          sudo sgdisk -Z /dev/$hddVar
          exit
          ;;
          No)
          exit
          ;;
     esac
done

