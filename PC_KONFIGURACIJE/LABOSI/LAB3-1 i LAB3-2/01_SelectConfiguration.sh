#!/bin/bash

# Define variables here
#-----------------------
PS3="Select the location of PC: "
nvmeSize=$(fdisk -l | grep nvme | cut -d " " -f5)
hddSize=$(fdisk -l | grep sda | cut -d " " -f5)
nvmeSizeinGB=$(( nvmeSize / 1024 / 1024 / 1024 ))
hddSizeinGB=$(( hddSize / 1024 / 1024 / 1024 ))
#-----------------------


# Define functions here
#-----------------------
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

#-----------------------

# Getting some info
#-----------------------
echo "Gathering some informations"
echo -e "\n"
echo "Listing all NVME and HDD storage devices"
fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)'
echo -e "\n"
echo "NVME size is: " $nvmeSizeinGB "GB"
echo "HDD size is: " $hddSizeinGB "GB"
echo -e "\n"


if [ $nvmeSizeinGB -lt "300" ]
then 
echo "This is PC_CONFIGURATION_1"
pcConf=1
elif [ $nvmeSizeinGB -gt "400" -a $nvmeSizeinGB -lt "1500" ]
then 
echo "This is PC_CONFIGURATION_2 or PC_CONFIGURATION_3"
pcConf=2
elif [ $nvmeSizeinGB -gt "1500" ]
then 
echo "This is PC_CONFIGURATION_4"
pcConf=4
else
echo "Can't recognize PCconfiguration"
pcConf="Error"
fi
echo -e "\n"


# Main script code
#-----------------------

case $pcConf in

1) echo "Calling script1"
   ./02_pcConf1.sh
   ;;
2) echo "Calling script23 for further info"
   ./03_pcConf23.sh
   ;;
4) echo "Calling script4"
   ./06_pcConf4.sh
   ;;
Error) echo "Something is wrong";;

esac
