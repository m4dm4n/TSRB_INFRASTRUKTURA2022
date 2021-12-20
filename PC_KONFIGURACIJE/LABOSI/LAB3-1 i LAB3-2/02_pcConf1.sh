#!/bin/bash

# Available different locations and configurations
# 01) PRAKSA_ELEKTROTEHNIKA_NASTAVNICKO (3)
# 02) PRAKSA_STROJARSTVO_NASTAVNICKO (1)
# 03) PRAKSA_STROJARSTVO_UCENICKO (6)
# 04) KABINETI (8)
# 05) LAB21_22 NASTAVNICKO (2)
# 06) LAB21_22 UCENICKO (24)

PS3="Racunalo ce biti nastavnicko, kabinetsko ili ucenicko: "

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
        read -n 2 -p $'Unesi broj Windows instalacija: \n' numberofWininstalls
        read -n 3 -p $'Unesi velicinu DATA particije u GB: \n' dataPartsize
        export numberofWininstalls
        export dataPartsize
        echo "Broj win instalacija: " $numberofWininstalls
        echo "Pozivam skriptu za particioniranje ucenickog racunala"
        ./pcConf1/02_pcConf1_UCENICKA.sh
        exit
		;;
    esac

done



