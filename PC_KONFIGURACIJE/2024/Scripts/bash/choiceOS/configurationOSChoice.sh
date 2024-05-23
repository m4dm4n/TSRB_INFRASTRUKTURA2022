#!/bin/bash

workDir="/home/student/Skripte"

#########
## Set some error handling options
set -o errexit     # It will exit on first error in script
set -o pipefail    #It will exit on first error in some pipeline
#########

# Get the CPU model
cpu_model=$(lscpu | grep 'Model name:' | awk -F ':' '{print $2}' | xargs)

# First check if the PC configuration is meant for FESTO labs
if [[ -f $workDir"/festoTag" ]]; then
    source $workDir/festoPC03OS.sh
    exit 0
fi

# Check the CPU model and call the next deployment script
if [[ $cpu_model == *"i5-12600"* ]]; then
    source $workDir/racPC02OS.sh

elif [[ $cpu_model == *"i7-12700K"* ]]; then
    source $workDir/racPC05OS.sh

elif [[ $cpu_model == *"i7-12700"* ]]; then
    source $workDir/racPC0304OS.sh

    
else
    echo "This is not a valid configuration"
    exit 1
fi