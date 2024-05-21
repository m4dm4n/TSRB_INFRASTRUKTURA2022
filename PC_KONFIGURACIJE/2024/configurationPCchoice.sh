#!/bin/bash

# Get the CPU model
cpu_model=$(lscpu | grep 'Model name:' | awk -F ':' '{print $2}' | xargs)

# Check the CPU model and output the corresponding message
if [[ $cpu_model == *"i5-12600"* ]]; then
    echo "This is i5 configuration"
elif [[ $cpu_model == *"i7-12700"* ]]; then
    echo "This is i7 configuration"
else
    echo "Unknown CPU configuration"
fi