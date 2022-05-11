#!/bin/bash

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "Skripta za particioniranje diskova"
   echo "Primjer korištenja:"
   echo "scriptname -sysdrive nvme0n1 -datadrive sda -wininstalls 5 -winsize 50 -datasize 60"
   echo
   echo "Syntax: scriptTemplate [-h|sd|dd|wn|ws|ds]"
   echo "options:"
   echo "h     Ispiši način korištenja"
   echo "sd     odaberi System Disk"
   echo "dd     odaberi Data Disk."
   echo "wn     odaberi broj Windows instalacija. "
   echo "ws     odaberi veličinu Windows instalacije u GB."
   echo "ds     odaberi veličinu Data particija u GB"
   echo
   exit 0
}

ErrorHelp()
{
   echo "Krivo odabrani argumenti"
      # Display Help
   echo "Skripta za particioniranje diskova"
   echo "Primjer korištenja:"
   echo "scriptname -sysdrive nvme0n1 -datadrive sda -wininstalls 5 -winsize 50 -datasize 60"
   echo
   echo "Syntax: scriptTemplate [-h|sd|dd|wn|ws|ds]"
   echo "options:"
   echo "h     Ispiši način korištenja"
   echo "sd     odaberi System Disk"
   echo "dd     odaberi Data Disk."
   echo "wn     odaberi broj Windows instalacija. "
   echo "ws     odaberi veličinu Windows instalacije u GB."
   echo "ds     odaberi veličinu Data particija u GB"
   echo
   exit 1
}

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

ssdVar=""
hddVar=""
numberofWininstalls=""
winSystemPartSizeGB=""
dataPartsizeGB=""

while getopts "hs:h:n:w:d:" optionName; do
case "$optionName" in
h) Help;;
s) ssdVar="$OPTARG";;
h) hddVar="$OPTARG";;
n) numberofWininstalls="$OPTARG";;
w) winSystemPartSizeGB="$OPTARG";;
d) dataPartsizeGB="$OPTARG";;
[?]) ErrorHelp;;
esac
done


echo "SSD" $ssdVar
echo "HDD" $hddVar
echo "Broj" $numberofWininstalls
echo "Sys Velicina" $winSystemPartSizeGB
echo "Data Velicina" $dataPartSizeGB
#if [ "$1" == "" ]; then
#  Help
#  exit 0
#fi

#if [ "$#" -lt 5 ]; then
#   echo "potrebno je unijeti 5 argumenata, uneseno $#"
#   exit 1
#fi



#echo Parameter $1
#echo Parameter $2
#echo Parameter $3
