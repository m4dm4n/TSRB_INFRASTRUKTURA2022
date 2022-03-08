#!/bin/bash

# DELETE BACKUP FOLDER
rm -r ~/BACKUP



# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'

read -e -n 7 -p $'Odaberi SSD: \n' ssdVar
echo -e "\n"
read -e -n 3 -p $'Odaberi HDD: \n' hddVar
echo -e "\n"

sgdisk -p /dev/$ssdVar
sgdisk -p /dev/$hddVar


#### DELETING PARTITION TABLES

echo "Slijedeci korak je brisanje GPT tablica sa svih diskova, nastavak?"

select yn in "Da" "Ne";do
     case $yn in
          Da)
          sudo sgdisk -Z /dev/$ssdVar
          sudo sgdisk -Z /dev/$hddVar
          exit
          ;;
          Ne)
          exit
          ;;
     esac
done


#### CALLING SELECT_CONF SCRIPT

echo "Slijedeci korak je poziv skripte za automatski odabir konfiguracije, nastavak?"

select yn in "Da" "Ne";do
     case $yn in
          Da)
          01_SelectConfiguration.sh
          exit
          ;;
          Ne)
          exit
          ;;
     esac
done
