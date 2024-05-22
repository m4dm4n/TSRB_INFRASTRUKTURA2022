#!/bin/bash


### 01 CLEARING OLD DATA
clear 
echo "STEP 01"
echo "Removing old GPT backup files"
rm TEST*

if [ -b /dev/nvme0n1p1 ]; then
echo "Partitions found, zapping"
sgdisk -Z /dev/nvme0n1
fi


### DEFINE PAUSE FUNCTION
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}






### 02 CREATING PARTITIONS
clear
echo "STEP 02"
echo "Creating Partitions"
for (( i=1; i<=20; i++ ))
do
sgdisk -n 0:0:+100MiB -t 0:0700 -c 0:"Part$i" /dev/nvme0n1 >/dev/null 2>&1
done
sgdisk -b TEST_ALL_PARTS.gpt /dev/nvme0n1 >/dev/null 2>&1

totalPart=$(grep -c nvme0n1p[0-9] /proc/partitions)
echo "Ukupno ima "$totalPart" particija"
sgdisk -p /dev/nvme0n1
pause







### 03 SAVE LINUX
echo "STEP 03"
echo "Saving Linux Partitions"
for (( i=5; i<=$totalPart; i++ ))
     do
	 sgdisk -d $i /dev/nvme0n1 >/dev/null 2>&1
	 done
sgdisk -b TEST_LINUX.gpt /dev/nvme0n1 >/dev/null 2>&1

# RESTORE ORIGINAL PARTITIONS
sgdisk -l TEST_ALL_PARTS.gpt /dev/nvme0n1 >/dev/null 2>&1
pause







### 04 SAVE LAST 4 PARTITIONS (STORE WINDOWS)
echo "STEP 04"
echo "Saving Last 4 Partitions"
for (( i=1; i<=$(($totalPart-4)); i++ ))
     do
	 sgdisk -d $i /dev/nvme0n1 >/dev/null 2>&1
	 done
sgdisk -b TEST_LAST4.gpt /dev/nvme0n1 >/dev/null 2>&1
pause








### 05 PRINT BACKUPS
clear
echo "STEP 05"
echo "Print LINUX GPT STRUCTURE"
sgdisk -l TEST_LINUX.gpt /dev/nvme0n1 >/dev/null 2>&1
sgdisk --sort /dev/nvme0n1 >/dev/null 2>&1
sgdisk -p /dev/nvme0n1
pause

echo "Print BACKUP OS GPT STRUCTURE"
sgdisk -l TEST_LAST4.gpt /dev/nvme0n1 >/dev/null 2>&1
sgdisk --sort /dev/nvme0n1 >/dev/null 2>&1
sgdisk -p /dev/nvme0n1
pause









### 06 PREPARING FOR REST OF Partitions

#REMOVE LINUX AND BACKUP PARTITIONS
clear
echo "STEP 06"
echo "REMOVE LINUX AND BACKUP PARTITIONS"
sgdisk -l TEST_ALL_PARTS.gpt /dev/nvme0n1 >/dev/null 2>&1

for (( i=1; i<=4; i++ ))
     do
         sgdisk -d $i /dev/nvme0n1 >/dev/null 2>&1
         done
for (( i=$totalPart; i>$(($totalPart-4)); i-- ))
     do
         sgdisk -d $i /dev/nvme0n1 >/dev/null 2>&1
         done
sgdisk --sort /dev/nvme0n1 >/dev/null 2>&1
sgdisk -p /dev/nvme0n1

totalPart=$(grep -c nvme0n1p[0-9] /proc/partitions)

echo "Ukupno ima "$totalPart" Particija"

numberofSteps=$(($totalPart/4))

pause









### 07 BACKUP PARTITION PACKAGES
clear
echo "STEP 07"
echo "CREATE PARTITION BACKUP PACKAGES"
sgdisk -b TEST_1_BACKUP.gpt /dev/nvme0n1 >/dev/null 2>&1

for (( i=1; i<=$numberofSteps; i++ ))
    do
      sgdisk -l TEST_"$i"_BACKUP.gpt /dev/nvme0n1 >/dev/null 2>&1
      for (( j=5; j<=$totalPart; j++ ))
        do
          sgdisk -d $j /dev/nvme0n1 >/dev/null 2>&1
        done
    sgdisk -b TEST_"$i"_PAKET.gpt /dev/nvme0n1 >/dev/null 2>&1

    sgdisk -l TEST_"$i"_BACKUP.gpt /dev/nvme0n1 >/dev/null 2>&1

     for (( k=1; k<=4; k++ ))
       do
         sgdisk -r $k:$(($k+4)) /dev/nvme0n1 >/dev/null 2>&1
       done

    for (( n=5; n<=8; n++))
       do
         sgdisk -d $n /dev/nvme0n1 >/dev/null 2>&1
       done
    sgdisk --sort /dev/nvme0n1 >/dev/null 2>&1
    var=$(( $i + 1 ))
    sgdisk -b TEST_"$var"_BACKUP.gpt /dev/nvme0n1 >/dev/null 2>&1

    totalPart=$(grep -c nvme0n1p[0-9] /proc/partitions)
    done






### 08 PRINT BACKED UP PARTITION TABLES
clear
echo "STEP 08"
echo "PRINTING BACKUP GPT TABLE PACKAGES"
sgdisk -l TEST_1_PAKET.gpt /dev/nvme0n1 >/dev/null 2>&1; sudo sgdisk -p /dev/nvme0n1
sgdisk -l TEST_2_PAKET.gpt /dev/nvme0n1 >/dev/null 2>&1; sudo sgdisk -p /dev/nvme0n1
sgdisk -l TEST_3_PAKET.gpt /dev/nvme0n1 >/dev/null 2>&1; sudo sgdisk -p /dev/nvme0n1
