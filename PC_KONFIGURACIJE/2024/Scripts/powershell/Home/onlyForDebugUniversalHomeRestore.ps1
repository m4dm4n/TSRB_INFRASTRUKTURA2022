#############################################################################################
## Name : onlyForDebugUniversalHomeRestore.ps1
## Author: Marko Stojanović
## Date: 22.05.2024.
## Version: 1.0
## Description: This script is used to debug Universal Home Restore script. It only reads and
## variable values
#############################################################################################

<#
#############################################################################################
## Check if script is running as Administrator
# Get the ID and security principal of the current user account
$myWindowID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowID)

# Get the security principal for the administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "As Administrator"
if ($myWindowPrincipal.IsInRole($adminRole))
{
    #We are running as Administrator, so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $MyInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    clear-host
}
else
{
$newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
$newProcess.Arguments = $MyInvocation.MyCommand.Definition;
$newProcess.Verb = "runas";
[System.Diagnostics.Process]::Start($newProcess);
exit
}
#############################################################################################
#>


#############################################################################################
## Check if any disk is visible to this script
$physicalDisk = Get-PhysicalDisk
if ($null -eq $physicalDisk) {
    Write-Output "No physical disk found. Exiting script."
    exit
}

## Check if there are any partitions on the disk
$partition = Get-Partition
if ($null -eq $partition) {
    Write-Output "No partitions found. Exiting script."
    exit
}

## Check if there are any errors while getting physical disk
try {
    $physicalDisk = Get-PhysicalDisk
} catch {
    Write-Output "Error getting physical disk: $_"
    exit
}

## Check if there are any errors while getting partitions
try {
    $partition = Get-Partition
} catch {
    Write-Output "Error getting partitions: $_"
    exit
}
#############################################################################################

#############################################################################################
## Check if all GPT backup files are available, readable and original content is not changed
$directory = "C:\Skripte\Home"
$files = @(
    "pc02Linux_Partitions.gpt",
    "pc02All_Data_Partitions.gpt",
    "pc0304All_Data_Partitions.gpt",
    "pc05Linux_Partitions.gpt",
    "pc05All_Data_Partitions.gpt",
    "festoAll_Data_Partitions.gpt",
    "pc02Linux_Partitions.md5",
    "pc02All_Data_Partitions.md5",
    "pc0304All_Data_Partitions.md5",
    "pc05Linux_Partitions.md5",
    "pc05All_Data_Partitions.md5",
    "festoAll_Data_Partitions.md5"
)

# Check if all files exist
foreach ($file in $files) {
    if (-not (Test-Path $directory\$file)) {
        Write-Output "$directory\$file does not exist."
#        exit
    } else {
        Write-Host -NoNewline "."
    }
}   
Write-Output "All GPT files exist at the location."

# Check if all files have the same content
$files = Get-ChildItem -Path $directory -Filter "*.gpt" | ForEach-Object { $_.BaseName }

foreach ($file in $files) {
    $hashFromFile = Get-Content "$directory\$file.md5"
    $computedHash = (Get-FileHash "$directory\$file.gpt" -Algorithm MD5).Hash

    if ($hashFromFile -ne $computedHash) {
        Write-Output "Hash mismatch for $file.gpt"
#        exit
    } else {
        Write-Host -NoNewline "."
    }
}
Write-Output "GPT Files integrity is OK."
#############################################################################################


#############################################################################################	
## Variables definition, gathering info about PC configuration type

# Count total storage devices, if more than 2, something extra is plugged in, dangerous operation
$deviceIDCount = (Get-PhysicalDisk | Measure-Object -Property DeviceID).Count

if ( $deviceIDCount -gt 2 ) {
    Write-Output "There are more than 2 storage device connected to this computer. Please disconnect surplus device and restart this script!! Press any key to exit script"
    Read-Host
    exit
    }

# Define SSD and HDD device numbers
$ssdDiskNumber = Get-PhysicalDisk | Where-Object {$_.BusType -eq 'NVMe'} | Select-Object -ExpandProperty DeviceID
$hddDiskNumber = Get-PhysicalDisk | Where-Object {$_.BusType -eq 'SATA'} | Select-Object -ExpandProperty DeviceID

# Define SSD and HDD disk sizes
$ssdDiskSize = ( Get-PhysicalDisk | Where-Object { $_.BusType -eq 'NVMe'} | Select-Object -ExpandProperty Size )
$hddDiskSize = ( Get-PhysicalDisk | Where-Object { $_.BusType -eq 'SATA'} | Select-Object -ExpandProperty Size )

# Define Windows partition size
$windowsPartitionSize = ( Get-Partition -DriveLetter C | Select-Object -ExpandProperty Size )



# Check which PC configuration is this and set backup file paths
if ( ( $windowsPartitionSize / 1GB ) -ge 300 ) {
    Write-Output "This is Festo PC configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc02Linux_Partitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\festoAll_Data_Partitions.gpt"
}
elseif ( ( $hddDiskSize / 1GB ) -ge 3500 ) {
    Write-Output "This is PC05 configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc05Linux_Partitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\pc05All_Data_Partitions.gpt"
}
elseif ( ( $hddDiskSize / 1GB ) -ge 1000 -and ( $hddDiskSize / 1GB ) -lt 3500 )
{
    Write-Output "This is PC03 or PC04 configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc02Linux_Partitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\pc0304All_Data_Partitions.gpt"
}
elseif ( ( $hddDiskSize / 1GB ) -ge 500 -and ( $hddDiskSize / 1GB ) -lt 1000 )
{
    Write-Output "This is PC02 configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc02Linux_Partitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\pc02All_Data_Partitions.gpt"
}
else {
    Write-Output "This is not any valid PC configuration. Press any key to exit script"
    Read-Host
    exit
}
#############################################################################################


#############################################################################################
## GPT RESTORE VARIABLE DEFINITIONS
# Calculate the sector offset and length of the protective MBR
$MbrOffset = 0
$MbrLength = 1 * 512

# Calculate the sector offset and length of the primary GPT header
$GptHeaderOffset = 1 * 512
$GptHeaderLength = 1 * 512

# Calculate the sector offset and length of the primary GPT table
$GptTableOffset = 2 * 512
$GptTableLength = 32 * 512

# Calculate the sector offset and length of the backup GPT table
$ssdGptBackupTableOffset = (($ssdDiskSize / 512) - 33) * 512
$hddGptBackupTableOffset = (($hddDiskSize / 512) - 33) * 512
$GptBackupTableLength = 32 * 512

# Calculate the sector offset and length of the backup GPT header
$ssdGptBackupHeaderOffset = (($ssdDiskSize / 512) - 1)* 512
$hddGptBackupHeaderOffset = (($hddDiskSize / 512) - 1)* 512
$GptBackupHeaderLength = 1 * 512
#############################################################################################

Write-Output "Working folder: $directory"

Write-Output "Number of storage devices identified in the system: $deviceIDCount"

Write-Output "SSD disk number: $ssdDiskNumber"

Write-Output "HDD disk number: $hddDiskNumber"

Write-Output "SSD disk size: $ssdDiskSize"

Write-Output "HDD disk size: $hddDiskSize"

Write-Output "Windows partition size: $windowsPartitionSize"

Write-Output "SSD Backup file path: $ssdBackupFilePath"

Write-Output "HDD Backup file path: $hddBackupFilePath" 

Write-Output "SSD GPT Backup Header offset location: $ssdGptBackupHeaderOffset"

Write-Output "HDD GPT Backup Header offset location: $hddGptBackupHeaderOffset"

Write-Output "SSD GPT Backup Table offset location: $ssdGptBackupTableOffset"

Write-Output "HDD GPT Backup Table offset location: $hddGptBackupTableOffset"

Write-Output "Press any key to exit script"
Read-Host

