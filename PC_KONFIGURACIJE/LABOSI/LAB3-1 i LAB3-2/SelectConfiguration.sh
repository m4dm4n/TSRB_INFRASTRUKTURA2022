#!/bin/bash

# Define variables here
#-----------------------
PS3="Select the location of PC: "
nvmeSize=$(fdisk -l | grep nvme | cut -d " " -f3)
hddSize=$(fdisk -l | grep sdb | cut -d " " -f3)
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
echo "NVME size is: " $nvmeSize "GB"
echo "HDD size is: " $hddSize "GB"
echo -e "\n"


if [ $nvmeSize -lt "300" ]
then 
echo "This is PC_CONFIGURATION_1"
pcConf=1
elif [ $nvmeSize -gt "400" -a $nvmeSize -lt "1500" ]
then 
echo "This is PC_CONFIGURATION_2 or PC_CONFIGURATION_3"
pcConf=2
elif [ $nvmeSize -gt "1500" ]
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

1) echo "MIRKO";;

2) echo "Calling script2"
   ./pcConf2.sh
   ;;
4) echo "Calling script4";;

Error) echo "Something is wrong";;

esac