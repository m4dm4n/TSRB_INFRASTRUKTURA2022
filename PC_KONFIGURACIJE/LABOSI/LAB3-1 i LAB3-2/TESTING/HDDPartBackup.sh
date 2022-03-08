#!/bin/bash

echo 1
saveDIR="$HOME/BACKUP"
numberofWininstalls=4
hddVar="sda"

echo 2
mkdir -p $saveDIR/HDD/Windows10_1 
mkdir -p $saveDIR/HDD/Windows10_2 
mkdir -p $saveDIR/HDD/Windows10_3 
mkdir -p $saveDIR/HDD/Windows10_4


echo 3
# Define some functions here
#---------------------------
function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}

#---------------------------


echo 4
# CREATING NEW PARTITIONS
for (( i=1; i<=4; i++))
do
sgdisk -n $i:0:+100MiB -t 0:0700 -c 0:"Particija $i" /dev/"$hddVar" >/dev/null 2>&1
done


echo 5
# Saving HDD DATA partitions 
totalHDDpartitions=$(grep -c "$hddVar"[0-9] /proc/partitions)
echo "Spremam HDD DATA GPT strukture"
sgdisk --backup=$saveDIR/HDD/00_HDD_CLEANED_PARTITIONS_1.gpt /dev/"$hddVar"
for (( i=1; i<=$numberofWininstalls; i++ ))
    do
      sgdisk --load-backup=$saveDIR/HDD/00_HDD_CLEANED_PARTITIONS_"$i".gpt /dev/"$hddVar" 
      for (( j=2; j<=totalHDDpartitions; j++ ))
        do
          sgdisk -d "$j" /dev/"$hddVar" 
        done
        echo "ispis nakon brisanja particija"
        sgdisk -p /dev/"$hddVar"
        pause 
    sgdisk --backup=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt /dev/"$hddVar" 
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 count=1 > $saveDIR/HDD/Windows10_"$i"/01_HDD_Windows10_"$i"_protectiveMBR.gpt
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 skip=1 count=1 > $saveDIR/HDD/Windows10_"$i"/02_HDD_Windows10_"$i"_primaryHEADER.gpt
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 skip=2 count=1 > $saveDIR/HDD/Windows10_"$i"/04_HDD_Windows10_"$i"_backupHEADER.gpt
    dd if=$saveDIR/HDD/Windows10_"$i"/00_HDD_Windows10_"$i".gpt bs=512 skip=3 > $saveDIR/HDD/Windows10_"$i"/03_HDD_Windows10_"$i"_GPTPartitions.gpt

    sgdisk --load-backup=$saveDIR/HDD/00_HDD_CLEANED_PARTITIONS_"$i".gpt /dev/"$hddVar" 

    sgdisk -r 1:$((i+1)) /dev/"$hddVar" 
    echo "ispis nakon zamjene mjesta"
    sgdisk -p /dev/"$hddVar"
    pause 
    
    #sgdisk --sort /dev/"$hddVar"
    #echo "ispis nakon sortiranja particija"
    #sgdisk -p /dev/"$hddVar"
    #pause 
    
    var=$(( i + 1 ))
    sgdisk --backup=$saveDIR/HDD/00_HDD_CLEANED_PARTITIONS_$var.gpt /dev/"$hddVar" 
done
echo "Gotovo"
pause