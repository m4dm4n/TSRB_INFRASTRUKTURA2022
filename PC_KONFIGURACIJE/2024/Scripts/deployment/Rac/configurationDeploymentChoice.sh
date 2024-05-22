#!/bin/bash

#########
## Set some error handling options
set -o errexit     # It will exit on first error in script
set -o pipefail    #It will exit on first error in some pipeline
#########

#########
# Check if the script is run as root
if [ "$EUID" -ne 0 ]
   then echo "Run the script with root permissions (sudo ./scriptname.sh)"
   exit 1
fi
#########

# Get the CPU model
cpu_model=$(lscpu | grep 'Model name:' | awk -F ':' '{print $2}' | xargs)

# Check the CPU model and call the next deployment script
if [[ $cpu_model == *"i5-12600"* ]]; then
    source ./PC02/pc02Deployment.sh

elif [[ $cpu_model == *"i7-12700K"* ]]; then
    source ./PC05/pc05Deployment.sh    

elif [[ $cpu_model == *"i7-12700"* ]]; then
    source ./PC03/pc03Deployment.sh

else
    echo "This is not a valid configuration"
    exit 1
fi