#!/bin/bash

# Define Hashed passwords file
password_file="/home/student/Skripte/hashedPass.txt"

# Define invalid input Function

invalid_input() {
      echo "Nedopušten odabir, pokušajte ponovno"
}

echo "Odabirom opcije u skripti, računalo će izvršiti reboot, te će se
      učitati verzija Windowsa ovisno o namjeni.

      Odaberite broj 1 za Nastavu
      Odaberite broj 2 za Seminar
"

while true; do
    read -p "Odaberite broj (1,2): " i
    case $i in
        1)
            sudo sgdisk -l /home/$USER/GPTTables/festoGPT03/festoWin01_Partitions.gpt /dev/nvme0n1 >/dev/null 2>&1
            sudo sgdisk -l /home/$USER/GPTTables/festoGPT03/festoG1data_Partition.gpt /dev/sda >/dev/null 2>&1
            sudo reboot
            break
            ;;
        2)
            read -sp "Unesite lozinku: " password5
            hashed_input=$(echo -n "$password5" | sha256sum)
            while IFS= read -r line;do
                 stored_password5=$line
                 if [[ $hashed_input == $stored_password5 ]]; then
                 #echo "Password is correct"
                 #exit 0
                 sudo sgdisk -l /home/$USER/GPTTables/festoGPT03/festoWin02_Partitions.gpt /dev/nvme0n1 >/dev/null 2>&1
                 sudo sgdisk -l /home/$USER/GPTTables/festoGPT03/festoG2data_Partition.gpt /dev/sda >/dev/null 2>&1
                 sudo reboot
                 fi
            done < $password_file
            echo "Lozinka je netočna"
            invalid_input
            ;;
        *)
            invalid_input
            ;;
    esac
done
