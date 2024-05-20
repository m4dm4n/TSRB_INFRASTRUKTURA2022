#!/bin/bash
clear

##########
# Set some options
set -o errexit # It will exit on first error in script
set -o pipefail # It will exit on first error in some pipeline
##########

##########
# Check if the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Run the script with root permissions ( ./script_name.sh)"
  exit 1
fi
#########


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define DATA and SYSTEM drive
dataDrive=sda


#Clear all GPT structures
echo -n "Zapping previous GPT structures..."
sgdisk --zap-all /dev/$dataDrive >/dev/null 2>&1

echo -e "${GREEN}      Done${NC}"

# Create GPT structure
echo -n "Creating new GPT structures..."
sgdisk  --mbrtogpt /dev/$dataDrive >/dev/null 2>&1

echo -e "${GREEN}      Done${NC}"

###########################################
###### CREATING DATA PARTITIONS #########
###########################################
echo -n "Creating Data Partitions..."
sgdisk -n 1:1MiB:300GiB -t 0:0700 -c 0:"G1Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+300GiB -t 0:0700 -c 0:"G2Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+300GiB -t 0:0700 -c 0:"G3Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+300GiB -t 0:0700 -c 0:"G4Data" /dev/$dataDrive >/dev/null 2>&1
sgdisk -n 0:0:+600GiB -t 0:0700 -c 0:"G5Data" /dev/$dataDrive >/dev/null 2>&1

echo -e "${GREEN}      Done${NC}"

############################################
#########Modify Partitions UUID#############
############################################
echo -n "Modifying Partitions UUIDs..."
#DATA PARTITIONS
sgdisk --partition-guid=1:54535242-4D42-4D53-5A47-484444303031 /dev/$dataDrive
sgdisk --partition-guid=2:54535242-4D42-4D53-5A47-484444303032 /dev/$dataDrive
sgdisk --partition-guid=3:54535242-4D42-4D53-5A47-484444303033 /dev/$dataDrive
sgdisk --partition-guid=4:54535242-4D42-4D53-5A47-484444303034 /dev/$dataDrive
sgdisk --partition-guid=5:54535242-4D42-4D53-5A47-484444303035 /dev/$dataDrive

echo -e "${GREEN}      Done${NC}"

###########################################
#####Creating HDD Filesystems##############
###########################################
echo -n "Creating Filesystems..."
#dataXY NTFS
for i in {1..5}; do mkfs.ntfs -Q /dev/sda$i; done

echo -e "${GREEN}      Done${NC}"

###########################################
######Creating Data GPT Backups##########
###########################################
echo -n "Backupping System Partition Structures..."
mkdir /tmp/GPT0304_Backup
workDir="/tmp/GPT0304_Backup"

sgdisk --backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {2..5}; do sgdisk --delete=$i /dev/$dataDrive; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G1data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

sgdisk --delete=1 /dev/$dataDrive
for i in {3..5}; do sgdisk --delete=$i /dev/$dataDrive; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G2data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {1..2}; do sgdisk --delete=$i /dev/$dataDrive; done
for i in {4..5}; do sgdisk --delete=$i /dev/$dataDrive; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G3data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {1..3}; do sgdisk --delete=$i /dev/$dataDrive; done
sgdisk --delete=5 /dev/$dataDrive
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G4data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

for i in {1..4}; do sgdisk --delete=$i /dev/$dataDrive; done
sgdisk --sort /dev/$dataDrive
sgdisk --backup="$workDir"/G5data_Partition.gpt /dev/$dataDrive
sgdisk --load-backup="$workDir"/All_Data_Partitions.gpt /dev/$dataDrive

echo -e "${GREEN}      Done${NC}"