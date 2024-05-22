$deviceIDCount = (Get-PhysicalDisk | Measure-Object -Property DeviceID).Count


if ( $deviceIDCount -gt 2 ) {
    Write-Output "There are more than 2 storage device connected to this computer. Please disconnect surplus device and restart this script!! Press any key to exit script"
    Read-Host
    exit
    }

$ssdDiskNumber = Get-PhysicalDisk | Where-Object {$_.BusType -eq 'NVMe'} | Select-Object -ExpandProperty DeviceID
$hddDiskNumber = Get-PhysicalDisk | Where-Object {$_.BusType -eq 'SATA'} | Select-Object -ExpandProperty DeviceID

$ssdDiskSize = ( Get-PhysicalDisk | Where-Object { $_.BusType -eq 'NVMe'} | Select-Object -ExpandProperty Size ) / 1GB

$windowsPartitionSize = ( Get-Partition -DriveLetter C | Select-Object -ExpandProperty Size ) / 1GB


#Write-Output $deviceIDCount
#Write-Output $ssdDiskNumber
#Write-Output $hddDiskNumber
Write-Output $ssdDiskSize
#Write-Output $windowsPartitionSize

if ( $windowsPartitionSize -gt 300 ) {
    #Write-Output "This is Festo PC configuration"
    $BackupFilePath = "C:\Skripte\Home\festoLinuxPartitions.gpt"
}


if ( $ssdDiskSize -gt 1500 ) {
    #Write-Output "This is PC05 configuration"
    $BackupFilePath = "C:\Skripte\Home\pc05LinuxPartitions.gpt"
}
elseif ( $ssdDiskSize -gt 500 -and $ssdDiskSize -lt 1000 )
{
    #Write-Output "This is PC02,PC03 or PC04 configuration"
    $BackupFilePath = "C:\Skripte\Home\pc02LinuxPartitions.gpt"
}
else
{
    Write-Output "Something is wrong! No PC configuration is identified! Press any key to exit script"
    Read-Host
    exit
}


# PlaceHolder for restoration process of HDD GPT table based on PC configuration
#$cpuModel = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
#
#if ( $cpuModel -like "*i7-12700K" ) {
#   Write-Output "Nice CPU"
#}
#else
#{
#   Write-Output "Bad CPU"
#}