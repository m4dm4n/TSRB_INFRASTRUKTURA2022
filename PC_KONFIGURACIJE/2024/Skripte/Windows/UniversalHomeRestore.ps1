#############################################################################################
## Name : UniversalHomeRestore.ps1
## Author: Marko Stojanović
## Date: 22.05.2024.
## Version: 1.0
## Description: This script is used to restore home partition on TSRB PC configurations, it automaticaly 
## detects PC configuration type and restores home partition from backup file
#############################################################################################

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
if ( ( $windowsPartitionSize / 1GB ) -gt 300 ) {
    #Write-Output "This is Festo PC configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc02LinuxPartitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\festoAll_Data_Partitions.gpt"
}
elseif ( ( $hddDiskSize / 1GB ) -gt 3500 ) {
    #Write-Output "This is PC05 configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc05LinuxPartitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\pc05All_Data_Partitions.gpt"
}
elseif ( ( $hddDiskSize / 1GB ) -gt 1000 -and ( $hddDiskSize / 1GB ) -lt 3500 )
{
    #Write-Output "This is PC03 or PC04 configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc02LinuxPartitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\pc0304All_Data_Partitions.gpt"
}
elseif ( ( $hddDiskSize / 1GB ) -gt 500 -and ( $hddDiskSize / 1GB ) -lt 1000 )
{
    #Write-Output "This is PC02 configuration"
    $ssdBackupFilePath = "C:\Skripte\Home\pc02LinuxPartitions.gpt"
    $hddBackupFilePath = "C:\Skripte\Home\pc02All_Data_Partitions.gpt"
}
else {
    Write-Output "This is not any valid PC configuration. Press any key to exit script"
    Read-Host
    exit
}
#############################################################################################

#############################################################################################

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

#### SSD GPT RESTORE ####
# Read the protective MBR and GPT backup from the backup file into byte arrays
$ssdBackupBytes = New-Object byte[] ($MbrLength + $GptHeaderLength + $GptBackupHeaderLength + $GptTableLength)
$ssdBackupStream = New-Object System.IO.FileStream($ssdBackupFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
$ssdBackupStream.Read($ssdBackupBytes, 0, $MbrLength + $GptHeaderLength + $GptBackupHeaderLength + $GptTableLength)
$ssdBackupStream.Close()

$ssdMbrBytes = New-Object byte[] $MbrLength
[System.Buffer]::BlockCopy($ssdBackupBytes, 0, $MbrBytes, 0, $MbrLength)

$ssdGptHeaderBytes = New-Object byte[] $GptHeaderLength
[System.Buffer]::BlockCopy($ssdBackupBytes, $MbrLength, $GptHeaderBytes, 0, $GptHeaderLength)

$ssdGptBackupHeaderBytes = New-Object byte[] $GptBackupHeaderLength
[System.Buffer]::BlockCopy($ssdBackupBytes, $MbrLength + $GptHeaderLength, $GptBackupHeaderBytes, 0, $GptBackupHeaderLength)

$ssdGptTableBytes = New-Object byte[] $GptTableLength
[System.Buffer]::BlockCopy($ssdBackupBytes, $MbrLength + $GptHeaderLength + $GptBackupHeaderLength, $GptTableBytes, 0, $GptTableLength)

# Write the protective MBR and primary GPT backup to the disk
$DiskStream = New-Object System.IO.FileStream("\\.\PhysicalDrive$ssdDiskNumber", [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write)
$DiskStream.Position = $MbrOffset
$DiskStream.Write($MbrBytes, 0, $MbrLength)
$DiskStream.Position = $GptHeaderOffset
$DiskStream.Write($GptHeaderBytes, 0, $GptHeaderLength)
$DiskStream.Position = $GptTableOffset
$DiskStream.Write($GptTableBytes, 0, $GptTableLength)
$DiskStream.Close()

# Write the backup GPT header and partition table to the disk
$DiskStream = New-Object System.IO.FileStream("\\.\PhysicalDrive$DiskNumber", [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write)
$DiskStream.Position = $GptBackupTableOffset
$DiskStream.Write($GptTableBytes, 0, $GptTableLength)
$DiskStream.Position = $GptBackupHeaderOffset
$DiskStream.Write($GptBackupHeaderBytes, 0, $GptBackupHeaderLength)
$DiskStream.Close()