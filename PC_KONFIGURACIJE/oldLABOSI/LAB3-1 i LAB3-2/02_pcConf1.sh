#!/bin/bash
clear
echo "--------------------------------------------------"
echo "Ovo je skripta za 1. konfiguraciju (250GB NVME, 1TB HDD)"
echo "--------------------------------------------------"
# Available different locations and configurations
# 01) PRAKSA_ELEKTROTEHNIKA_NASTAVNICKO (3)
# 02) PRAKSA_STROJARSTVO_NASTAVNICKO (1)
# 03) PRAKSA_STROJARSTVO_UCENICKO (6)
# 04) KABINETI (8)
# 05) LAB21_22 NASTAVNICKO (2)
# 06) LAB21_22 UCENICKO (24)


##### Define some variables here

PS3="Računalo ce biti nastavničko, kabinetsko ili učeničko: "

# Predefined partition sizes
linEfiPartinMB=500
linSwapinGB=8
linRootinGB=50
linHomeinGB=10

winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( winRecoveryPartinMB / 1024 ))

linuxHomeNeeded=0


# Define functions here
#-----------------------
function pause(){
 read -s -n 1 -p "Pritisni bilo koju tipku za nastavak . . ."
 echo ""
}
#-----------------------


# Calculate NVME free space
TotalFreeSectorsNVME=$(sgdisk -p /dev/"$ssdVar" | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBNVME=$(( TotalFreeSectorsNVME * 512 ))
TotalFreeinMBNVME=$(( TotalFreeinBNVME / 1024 / 1024 ))
TotalFreeinGBNVME=$(( TotalFreeinMBNVME / 1024 ))
# Calculate HDD free space
TotalFreeSectorsHDD=$(sgdisk -p /dev/"$hddVar" | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBHDD=$(( TotalFreeSectorsHDD * 512 ))
TotalFreeinMBHDD=$(( TotalFreeinBHDD / 1024 / 1024 ))
TotalFreeinGBHDD=$(( TotalFreeinMBHDD / 1024 ))


#### MAIN CODE STARTS HERE

clear

select namjena in nastavnicko kabinetsko ucenicko
do
    case $namjena in

        nastavnicko)
        echo "Pozivam skriptu za particioniranje nastavnickog racunala"
        pause
        ./pcConf1/02_pcConf1_NASTAVNICKA.sh
		exit
        ;;
        kabinetsko)
        echo "Pozivam skriptu za particioniranje kabinetskog racunala"
        pause
        ./pcConf1/02_pcConf1_KABINETI.sh
        exit
	;;
        ucenicko)
        read -e -n 2 -p $'Unesi broj Windows instalacija: \n' numberofWininstalls
        read -e -n 3 -p $'Unesi velicinu Windows sistemske particije u GB: \n' winSystemPartSizeGB
        read -e -n 3 -p $'Unesi velicinu DATA particije u GB: \n' dataPartsizeGB
        export numberofWininstalls
        export winSystemPartSizeGB
        export dataPartsizeGB
        if [ "$numberofWininstalls" -gt 1 ]
           then
               linuxHomeNeeded=1
               export linuxHomeNeeded
               echo "Potrebno je stvoriti Linux Home Particije"
               requiredSSDSpace=$((linEfiPartinMB+(linSwapinGB*1024)+(linRootinGB*1024)+(linHomeinGB*1024)+((numberofWininstalls+1)*winEfiPartinMB)+((numberofWininstalls+1)*msrPartinMB)+((numberofWininstalls+1)*winSystemPartSizeGB*1024)+((numberofWininstalls+1)*winRecoveryPartinMB)))
               if [ $requiredSSDSpace -gt $TotalFreeinMBNVME ]; then echo "Nema dovoljno prostora na disku za zahtjeve"; echo "Potrebno je "$((requiredSSDSpace/1024))"GB prostora, no slobodno je samo "$TotalFreeinGBNVME"GB"; exit 1; fi
        fi
        requiredSTOREspaceGB=$(( numberofWininstalls * 50 ))
        export requiredSTOREspaceGB
        TotalFreeSectorsHDD=$(sgdisk -p /dev/"$hddVar" | grep 'Total free space' | cut -d " " -f 5)
        TotalFreeinGBHDD=$(( TotalFreeSectorsHDD * 512 / 1024 / 1024 / 1024 ))
        requiredHDDSpaceGB=$(( numberofWininstalls * dataPartsizeGB + requiredSTOREspaceGB ))
        if [ $requiredHDDSpaceGB -gt $TotalFreeinGBHDD ]; then echo "Nema dovoljno prostora na disku za zahtjeve"; echo "Potrebno je "$requiredHDDSpaceGB"GB prostora, no slobodno je samo "$TotalFreeinGBHDD"GB"; exit 1; fi
        echo "Broj win instalacija: " "$numberofWininstalls"
        echo "Potreban prostor za BACKUP particiju: " $requiredSTOREspaceGB"GB"
        echo "Potreban prostor na SSD: " $((requiredSSDSpace/1024))"GB"
        echo "Potreban prostor na HDD: " $requiredHDDSpaceGB"GB"
        echo "Pozivam skriptu za particioniranje ucenickog racunala"
        pause
        ./pcConf1/02_pcConf1_UCENICKA.sh
        exit
	;;
    esac

done



