$DiskNumber = 0
$SectorSize = 512
$SectorStart = $SectorSize * 0
$FilePath = "C:\Users\strippy\Desktop\01_SAMO_WINDOWS_MBR.gpt"

$DiskPath = "\\.\PhysicalDrive$DiskNumber"
$DiskStream = [System.IO.File]::Open($DiskPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
$FileStream = [System.IO.File]::OpenRead($FilePath)
$Bytes = [Byte[]](0x0) * $FileStream.Length
$FileStream.Read($Bytes, 0, $Bytes.Length)

$DiskStream.Position = $SectorStart
$DiskStream.Write($Bytes, 0, $Bytes.Length)
$DiskStream.Close()
$FileStream.Close()
