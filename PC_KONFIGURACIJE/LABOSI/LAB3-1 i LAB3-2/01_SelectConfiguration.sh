#!/bin/bash

# Define SSD and HDD
#---------------------------
sudo fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'
read -e -n 7 -p $'Odaberi SSD: \n' ssdVar
echo -e "\n"
read -e -n 3 -p $'Odaberi HDD: \n' hddVar
echo -e "\n"
export ssdVar
export hddVar
#---------------------------

# Define variables here
#-----------------------
PS3="Odaberi lokaciju računala: "
nvmeSize=$(fdisk -l | grep $ssdVar | cut -d " " -f5)
hddSize=$(fdisk -l | grep $hddVar | cut -d " " -f5)
nvmeSizeinGB=$(( nvmeSize / 1024 / 1024 / 1024 ))
hddSizeinGB=$(( hddSize / 1024 / 1024 / 1024 ))
#-----------------------

# Define functions here
#-----------------------
function pause(){
 read -s -n 1 -p "Pritisni bilo koju tipku za nastavak . . ."
 echo ""
}

#-----------------------

# Getting some info
#-----------------------
echo "Skupljam informacije o sustavu..."
echo -e "\\n"
echo "Prikazujem sve NVME i HDD uredjaje"
fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'
echo -e "\\n"
echo "Veličina NVME diska: " $nvmeSizeinGB "GB"
echo "Veličina HDD diska: " $hddSizeinGB "GB"
echo -e "\\n"


if [ $nvmeSizeinGB -lt "300" ]
then 
echo "Ovo je PC_CONFIGURATION_1"
pcConf=1
elif [ $nvmeSizeinGB -gt "400" -a $nvmeSizeinGB -lt "1500" ]
then 
echo "Ovo je PC_CONFIGURATION_2 ili PC_CONFIGURATION_3"
pcConf=2
elif [ $nvmeSizeinGB -gt "1500" ]
then 
echo "Ovo je PC_CONFIGURATION_4"
pcConf=4
else
echo "Ne prepoznajem konfiguraciju"
pcConf="Error"
fi
echo -e "\\n"


# Main script code
#-----------------------

case $pcConf in

1) echo "Pozivam skriptu 1"
   pause
   ./02_pcConf1.sh
   ;;
2) echo "Pozivam skriptu 2/3 za detaljniji odabir"
   pause
   ./03_pcConf23.sh
   ;;
4) echo "Pozivam skriptu 4"
   pause
   ./06_pcConf4.sh
   ;;
Error) echo "Nešto nije u redu";;

esac
