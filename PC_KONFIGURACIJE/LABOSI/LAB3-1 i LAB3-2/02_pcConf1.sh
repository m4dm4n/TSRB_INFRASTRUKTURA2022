#!/bin/bash

# Available different locations and configurations
# 01) PRAKSA_ELEKTROTEHNIKA_NASTAVNICKO (3)
# 02) PRAKSA_STROJARSTVO_NASTAVNICKO (1)
# 03) PRAKSA_STROJARSTVO_UCENICKO (6)
# 04) KABINETI (8)
# 05) LAB21_22 NASTAVNICKO (2)
# 06) LAB21_22 UCENICKO (24)


##### Define some variables here

PS3="Racunalo ce biti nastavnicko, kabinetsko ili ucenicko: "

# Predefined partition sizes
linEfiPartinMB=300
linSwapinGB=16
linRootinGB=50
linHomeinGB=30

winEfiPartinMB=500
msrPartinMB=128
winRecoveryPartinMB=10240
winRecoveryPartinGB=$(( $winRecoveryPartinMB / 1024 ))

linuxHomeNeeded=false


# Calculate NVME free space
TotalFreeSectorsNVME=$(sgdisk -p /dev/nvme0n1 | grep 'Total free space' | cut -d " " -f 5)
TotalFreeinBNVME=$((TotalFreeSectorsNVME*512))
TotalFreeinMBNVME=$((TotalFreeinBNVME/1024/1024))
TotalFreeinGBNVME=$((TotalFreeinMBNVME/1024))



#### MAIN CODE STARTS HERE

clear

select namjena in nastavnicko kabinetsko ucenicko
do
    case $namjena in

        nastavnicko)
        echo "Pozivam skriptu za particioniranje nastavnickog racunala"
        ./pcConf1/02_pcConf1_NASTAVNICKA.sh
		exit
        ;;
        kabinetsko)
        echo "Pozivam skriptu za particioniranje kabinetskog racunala"
        ./pcConf1/02_pcConf1_KABINETI.sh
        exit
	;;
        ucenicko)
        read -e -n 2 -p $'Unesi broj Windows instalacija: \n' numberofWininstalls
        read -e -n 3 -p $'Unesi velicinu Windows sistemske particije u GB: \n' winSystemPartSize
        read -e -n 3 -p $'Unesi velicinu DATA particije u GB: \n' dataPartsize
        export numberofWininstalls
        export winSystemPartSize
        export dataPartsize
        if [ numberofWininstalls > 1 ]
           then
               linuxHomeNeeded=true
               export linuxHomeNeeded
               echo "Potrebno je stvoriti Linux Home Particije"
               requiredDiskSpace=$((linEfiPartinMB+(linSwapinGB*1024)+(linRootinGB*1024)+(linHomeinGB*1024)+((numberofWininstalls+1)*winEfiPartinMB)+((numberofWininstalls+1)*msrPartinMB)+((numberofWininstalls+1)*winSystemPartSize*1024)+((numberofWininstalls+1)*winRecoveryPartinMB)))
               if [ $requiredDiskSpace -gt $TotalFreeinMBNVME ]; then echo "Nema dovoljno prostora na disku za zahtjeve"; echo "Potrebno je "$((requiredDiskSpace/1024))"GB prostora, no slobodno je samo "$TotalFreeinGBNVME"GB"; exit 1; fi
        fi
        requiredDiskSpace=$(())
        echo "Broj win instalacija: " $numberofWininstalls
        echo "Pozivam skriptu za particioniranje ucenickog racunala"
        ./pcConf1/02_pcConf1_UCENICKA.sh
        exit
	;;
    esac

done



