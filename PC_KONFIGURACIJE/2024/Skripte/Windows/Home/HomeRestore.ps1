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

$DiskNumber = 1
$BackupFilePath = "C:\Skripte\Home\Linux_Partitions.gpt"

# Get the physical disk object
$PhysicalDisk = Get-PhysicalDisk -DeviceNumber $DiskNumber

# Get the size of the physical disk in bytes
$DiskSize = $PhysicalDisk.Size

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
$GptBackupTableOffset = (($DiskSize / 512) - 33) * 512
$GptBackupTableLength = 32 * 512

# Calculate the sector offset and length of the backup GPT header
$GptBackupHeaderOffset = (($DiskSize / 512) - 1)* 512
$GptBackupHeaderLength = 1 * 512

# Read the protective MBR and GPT backup from the backup file into byte arrays
$BackupBytes = New-Object byte[] ($MbrLength + $GptHeaderLength + $GptBackupHeaderLength + $GptTableLength)
$BackupStream = New-Object System.IO.FileStream($BackupFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
$BackupStream.Read($BackupBytes, 0, $MbrLength + $GptHeaderLength + $GptBackupHeaderLength + $GptTableLength)
$BackupStream.Close()

$MbrBytes = New-Object byte[] $MbrLength
[System.Buffer]::BlockCopy($BackupBytes, 0, $MbrBytes, 0, $MbrLength)

$GptHeaderBytes = New-Object byte[] $GptHeaderLength
[System.Buffer]::BlockCopy($BackupBytes, $MbrLength, $GptHeaderBytes, 0, $GptHeaderLength)

$GptBackupHeaderBytes = New-Object byte[] $GptBackupHeaderLength
[System.Buffer]::BlockCopy($BackupBytes, $MbrLength + $GptHeaderLength, $GptBackupHeaderBytes, 0, $GptBackupHeaderLength)

$GptTableBytes = New-Object byte[] $GptTableLength
[System.Buffer]::BlockCopy($BackupBytes, $MbrLength + $GptHeaderLength + $GptBackupHeaderLength, $GptTableBytes, 0, $GptTableLength)

# Write the protective MBR and primary GPT backup to the disk
$DiskStream = New-Object System.IO.FileStream("\\.\PhysicalDrive$DiskNumber", [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write)
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

# Display a message indicating the restore was successful
Write-Host "GPT, protective MBR, primary GPT backup, and partition table restore successful."

Write-Host "Computer will restart in 5 seconds"
Start-Sleep -seconds 5
Restart-Computer