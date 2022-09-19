powercfg -x  -standby-timeout-ac 0
powercfg -x  -standby-timeout-dc 0


$ipAddress = Get-NetIPAddress | Where-Object { $_.IPaddress -like "192.168.*" -and $_.PrefixOrigin -notmatch "Manual"} | Select-Object -ExpandProperty IPaddress

$networkPortion = $ipAddress.Split(".")[2]

$hostPortion = $ipAddress.Split(".")[3]


if ( $networkPortion -match 70 ) { 
    
    $labLocation = 'lb32'

} elseif ( $networkPortion -match 80 ) {

    $labLocation = 'lb31'

}  else {

    Write-Output "Nesto nije u redu"

}
 

if ( $hostPortion -In 10..22 ) { 
    
    $hostValue = '{0:d2}' -f ($hostPortion - 10)

} elseif ( $hostPortion -In 50..62 ) {

    $hostValue = '{0:d2}' -f ($hostPortion - 50)

}  else {

    Write-Output "Nesto nije u redu"

}


Rename-Computer -NewName WS"$hostValue$labLocation"



# Username and Password
$username = -join("WS",$hostValue)
$password = ConvertTo-SecureString $username -AsPlainText -Force  # Super strong plane text password here (yes this isn't secure at all)

# Creating the user
New-LocalUser -Name $username -Password $password -FullName $username -Description $username



Add-LocalGroupMember -Group Administrators -Member $username

Restart-Computer -Force
