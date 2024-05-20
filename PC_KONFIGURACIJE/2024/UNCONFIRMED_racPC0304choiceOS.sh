#!/bin/bash

# Define Hashed passwords file
password_file="/home/student/Skripte/hashedPass.txt"

# Define invalid input Function

invalid_input() {
      echo "Nedopušten odabir, pokušajte ponovno"
}

echo "Odabirom opcije u skripti, računalo će izvršiti reboot, te će se
      učitati verzija Windowsa ovisno o generaciji razreda u kojem se nalazite.

      Odaberite broj 1 za 1. razred
      Odaberite broj 2 za 2. razred
      Odaberite broj 3 za 3. razred
      Odaberite broj 4 za 4. razred
"

while true; do
    read -p "Odaberite broj za razinu razreda u kojoj se nalazite (1,2,3,4): " i
    case $i in
        1)
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/Win01_Partitions.gpt /dev/nvme0n1
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/G1data_Partition.gpt /dev/sda
            sudo reboot
            break
            ;;
        2)
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/Win02_Partitions.gpt /dev/nvme0n1
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/G2data_Partition.gpt /dev/sda
            sudo reboot
            break
            ;;
        3)
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/Win03_Partitions.gpt /dev/nvme0n1
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/G3data_Partition.gpt /dev/sda
            sudo reboot
            break
            ;;
        4)
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/Win04_Partitions.gpt /dev/nvme0n1
            sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/G4data_Partition.gpt /dev/sda
            sudo reboot
            break
            ;;
        5)
            read -sp "Unesite lozinku: " password5
            hashed_input=$(echo -n "$password5" | sha256sum)
            while IFS= read -r line;do
                 stored_password5=$line
                 if [[ $hashed_input == $stored_password5 ]]; then
                 #echo "Password is correct"
                 #exit 0
                 sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/Win05_Partitions.gpt /dev/nvme0n1
                 sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/G5data_Partition.gpt /dev/sda
                 sudo reboot
                 fi
            done < $password_file
            echo "Password is incorrect."
            invalid_input
            ;;
        6)
            read -sp "Unesite lozinku: " password6
            hashed_input=$(echo -n "$password6" | sha256sum)
            while IFS= read -r line;do
                 stored_password6=$line
                 if [[ $hashed_input == $stored_password6 ]]; then
                 #echo "Password is correct"
                 #exit 0
                 sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/Win06_Partitions.gpt /dev/nvme0n1
                 sudo sgdisk -l /home/$USER/GPT_Tablice/PC0304/G5data_Partition.gpt /dev/sda
                 sudo reboot
                 fi
            done < $password_file
            echo "Password is incorrect."
            invalid_input
            ;;
        *)
            invalid_input
            ;;
    esac
done
