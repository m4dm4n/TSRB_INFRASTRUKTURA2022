$DiskNumber = 0
$BackupFilePath = "C:\users\strippy\desktop\GPT_Backup.bin"

# Get the physical disk object
$PhysicalDisk = Get-PhysicalDisk -DeviceNumber $DiskNumber

# Get the size of the physical disk in bytes
$DiskSize = $PhysicalDisk.Size

# Calculate the sector offset and length of the protective MBR
$MbrOffset = 0
$MbrLength = 1 * 512

# Calculate the sector offset and length of the GPT
$GptOffset = 1 * 512
$GptLength = 33 * 512

# Read the protective MBR and GPT backup from the disk into byte arrays
$MbrBytes = New-Object byte[] $MbrLength
$GptBytes = New-Object byte[] $GptLength
$DiskStream = New-Object System.IO.FileStream("\\.\PhysicalDrive$DiskNumber", [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
$DiskStream.Position = $MbrOffset
$DiskStream.Read($MbrBytes, 0, $MbrLength)
$DiskStream.Position = $GptOffset
$DiskStream.Read($GptBytes, 0, $GptLength)
$DiskStream.Close()

# Write the protective MBR and GPT backup to the backup file
$BackupStream = New-Object System.IO.FileStream($BackupFilePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
$BackupStream.Write($MbrBytes, 0, $MbrLength)
$BackupStream.Write($GptBytes, 0, $GptLength)
$BackupStream.Close()

# Display a message indicating the backup was successful
Write-Host "GPT and protective MBR backup successful."

