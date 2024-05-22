#!/bin/bash
clear
echo "--------------------------------------------------"
echo "Ovo je skripta za 2/3. konfiguraciju (1TB NVME, 2TB HDD)"
echo "--------------------------------------------------"
# Available different locations and configurations
# 01) GRUPA 1
# TC_MULTIMEDIJA_NASTAVNICKO (2)
# TC_MULTIMEDIJA_UCENICKO (24)
# PRAKSA_ELEKTROTEHNIKA_UCENICKO
# LAB33_34_NASTAVNICKO (2)
# LAB33_34_UCENICKO (16)
# NOVA_ZGRADA_OSTALO (6)
# NOVA_ZGRADA_UCENICKO (12)

# OR

# 02) GRUPA 2
# Available different locations and configurations
# LAB23_24_NASTAVNICKO (2)
# LAB23_24_UCENICKO (26)

 
echo "GRUPA 1"
echo -------------------------------------------------
echo "TC_MULTIMEDIJA_NASTAVNICKO (2)"
echo "TC_MULTIMEDIJA_UCENICKO (24)"
echo "PRAKSA_ELEKTROTEHNIKA_UCENICKO"
echo "LAB33_34_NASTAVNICKO (2)"
echo "LAB33_34_UCENICKO (16)"
echo "NOVA_ZGRADA_OSTALO (6)"
echo "NOVA_ZGRADA_UCENICKO (12)"
echo -------------------------------------------------
echo -e "\n"
echo "GRUPA 2"
echo -------------------------------------------------
echo "LAB23_24_NASTAVNICKO (2)"
echo "LAB23_24_UCENICKO (26)"
echo -------------------------------------------------
echo -e "\n"
echo -e "\n"
echo -e "\n"
PS3="Racunalo ce biti u Grupi 1 ili 2: "

select namjena in grupa1 grupa2
do
    case $namjena in

        grupa1)
        echo "Pozivam skriptu za grupu 1"
        ./04_pcConf2.sh
        ;;
        grupa2)
        echo "Pozivam skriptu za grupu 2"
        ./05_pcConf3.sh
        ;;
    esac

exit 0
done
