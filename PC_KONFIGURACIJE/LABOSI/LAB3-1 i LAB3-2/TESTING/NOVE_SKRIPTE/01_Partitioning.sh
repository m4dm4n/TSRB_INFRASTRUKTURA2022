#!/bin/bash
clear

##########
# Set some options
set -o errexit # It will exit on first error in script
set -o pipefail # It will exit on first error in some pipeline
##########

##########
# Provjera je li skripta pokrenuta sa root ovlastima
if [ "$EUID" -ne 0 ]
  then echo "Pokrenuti skriptu sa root ovlastima (sudo ./naziv_skripte.sh)"
  exit 1
fi
#########

#########
# Postavljanje početnih varijabli
unset sysDrive
unset dataDrive
unset numberOfWinInstalls
unset winSystemPartSizeGB
unset dataPartSizeGB
linuxHomeNeeded=0
#########

#########
# Predefinirane veličine particija
# Linux particije
linEfiPartinMB=500
linSwapinGB=8
linRootinGB=50
linHomeinGB=10
# Windows particije
winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( winRecoveryPartinMB / 1024 ))

#########
# Definiranje pause funkcije
function pause(){
 read -s -n 1 -p "Pritisni bilo koju tipku za nastavak . . ."
 echo ""
}
#########

################################################################################
# Help izbornik                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "Skripta za particioniranje diskova"
   echo
   echo
   echo "Primjer korištenja:"
   echo "scriptname -s nvme0n1 -d sda -n 5 -w 50 -f 60"
   echo
   echo "Ispis dostupnih diskova"
   fdisk -l | grep -E '(Disk /dev/sd|Disk /dev/nvme)' | cut -d, -f1
   echo
   echo
   echo "Sintaksa: nazivSkripte [-h|s|d|n|w|f]"
   echo "opcije:"
   echo "-h     Ispiši način korištenja"
   echo "-s     odaberi System Disk"
   echo "-d     odaberi Data Disk."
   echo "-n     odaberi broj Windows instalacija. "
   echo "-w     odaberi veličinu Windows instalacije u GB."
   echo "-f     odaberi veličinu Data particija u GB"
   echo
   exit 0
}

################################################################################
################################################################################
# Loading and checking variables                                                                #
################################################################################
################################################################################

while getopts "hs:d:n:w:f:" optionName; do
case "$optionName" in
h) Help;;
s) sysDrive="$OPTARG";;
d) dataDrive="$OPTARG";;
n) numberOfWinInstalls="$OPTARG";;
w) winSystemPartSizeGB="$OPTARG";;
f) dataPartSizeGB="$OPTARG";;
[?]) Help;;
esac
done

if [ "$1" == "" ]; then
  Help
  exit 0
fi

if [ -z $sysDrive ] || [ -z $dataDrive ] || [ -z $numberOfWinInstalls ] || [ -z $winSystemPartSizeGB ] || [ -z $dataPartSizeGB ]; then
   echo "Sve opcije moraju imati unesene vrijednosti"
   echo
   Help
   exit 1
fi

: ${sysDrive:?Opcija -s je obvezna} \
  ${dataDrive:?Opcija -d je obvezna} \
  ${numberOfWinInstalls:?Opcija -n je obvezna} \
  ${winSystemPartSizeGB:?Opcija -w je obvezna} \
  ${dataPartSizeGB:?Opcija -f je obvezna}


# Calculate System Drive free space
TotalFreeSectorsSysDrive=$(sgdisk -p /dev/"$sysDrive" | grep 'Total free space' | cut -d " " -f 5)
TotalFreeInBytesSysDrive=$(( TotalFreeSectorsSysDrive * 512 ))
TotalFreeInMBytesSysDrive=$(( TotalFreeInBytesSysDrive / 1024 / 1024 ))
TotalFreeInGBytesSysDrive=$(( TotalFreeInMBytesSysDrive / 1024 ))
# Calculate Data Drive free space
TotalFreeSectorsDataDrive=$(sgdisk -p /dev/"$dataDrive" | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBDataDrive=$(( TotalFreeSectorsDataDrive * 512 ))
TotalFreeinMBDataDrive=$(( TotalFreeinBDataDrive / 1024 / 1024 ))
TotalFreeinGBDataDrive=$(( TotalFreeinMBDataDrive / 1024 ))




#### MAIN CODE STARTS HERE
# Export Variables
export sysDrive
export dataDrive
export numberOfWinInstalls
export winSystemPartSizeGB
export dataPartSizeGB

if [ $numberOfWinInstalls -eq 1 ]; then
echo "Pozivam skriptu pripreme diskova za 1 instalaciju"
#./02_SingleInstall.sh
elif [ $numberOfWinInstalls -gt 1 ]; then
echo "Potrebno je stvoriti Linux Home Particije"
linuxHomeNeeded=1
export linuxHomeNeeded
echo "Provjera slobodnog prostora za sistemski disk..."
requiredSSDSpace=$((linEfiPartinMB+(linSwapinGB*1024)+(linRootinGB*1024)+(linHomeinGB*1024)+((numberOfWinInstalls+1)*winEfiPartinMB)\
                +((numberOfWinInstalls+1)*msrPartinMB)+((numberOfWinInstalls+1)*winSystemPartSizeGB*1024)+((numberOfWinInstalls+1)*winRecoveryPartinMB)))
     if [ $requiredSSDSpace -gt $TotalFreeinMBNVME ]; then echo "Nema dovoljno prostora na disku za zahtjeve"; \
     echo "Potrebno je "$((requiredSSDSpace/1024))"GB prostora, no slobodno je samo "$TotalFreeinGBNVME"GB"; exit 1; fi
echo "Provjera slobodnog prostora za data disk..."
requiredSTOREspaceGB=$(( numberofWininstalls * 50 ))
TotalFreeSectorsHDD=$(sgdisk -p /dev/"$dataDrive" | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinGBHDD=$(( TotalFreeSectorsHDD * 512 / 1024 / 1024 / 1024 ))
requiredHDDSpaceGB=$(( numberofWininstalls * dataPartsizeGB + requiredSTOREspaceGB ))
if [ $requiredHDDSpaceGB -gt $TotalFreeinGBHDD ]; then echo "Nema dovoljno prostora na disku za zahtjeve"; echo "Potrebno je "$requiredHDDSpaceGB"GB prostora, no slobodno je samo "$TotalFreeinGBHDD"GB"; exit 1; fi
export requiredSTOREspaceGB
echo "Pozivam skriptu pripreme diskova za više instalacija"
#./02_MultiInstall.sh
else
echo "Nešto je pošlo po krivu"
exit 1
fi