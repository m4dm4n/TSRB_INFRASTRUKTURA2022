#Requires -RunAsAdministrator
Clear-Host
Write-Host
Write-Host "*** Change Your Computer Name ***"
Write-Host
Write-Host -ForegroundColor Red "NOTE: Your computer will automatically reboot once complete"
Write-Host
Write-Host "Your computer name consists of your workstation number and lab room ID (ex. ws01lb32, for first PC in lab room LB3-2)"
Write-Host "Use only lower case letters (don't use WS01LB32)."
Write-Host
Write-Host "Your new username consists only of your workstation number (ex. ws01)." 
Write-Host "Use only lower case letters (don't use WS01)."
Write-Host
Write-Host
Write-Host
$Server = Read-Host -Prompt 'Input your computer name'
Write-Host
$Labroom = Read-Host -Prompt 'Input your lab room ID (ex. lb31,lb32,lb33,lb34,lb24)'
Write-Host
$User = Read-Host -Prompt 'Input new user name'
Write-Host
$Password = Read-Host -AsSecureString -Prompt 'Input new user password'
Write-Host
#Write-Host "You input server '$Server' , lab room '$Labroom', user '$User' and password '$Password'"
Write-Host
Write-Host "Your new computer name is : $Server$Labroom"
Write-Host
Write-Host "New username is : $User"
Write-Host
$Answer = Read-Host 'Is the information correct [y/n]?'


while("y","n" -notcontains $Answer)
{
	$Answer = Read-Host "Please enter your response (y/n)"
} 


if ("y" -contains $Answer)
{
Write-Host
Write-Host "Computer name will now be changed and user added. PC will automatically reboot."
Start-Sleep -Seconds 5
Write-Host "Adding new user"
New-Localuser $User -Password $Password

Write-Host "User is being added to Administrators group"
Add-LocalGroupMember -Group "Administrators" -Member $User

Write-Host "Changing computer name"
Rename-Computer -NewName $Server$Labroom -Force -PassThru
Write-Host
Write-Host -ForegroundColor Green "Restarting computer in 5 seconds..."
Start-Sleep -Seconds 5
Restart-Computer -Force
}

else
{
Write-Host
Write-Host "Please execute the script again with correct parameters"
Write-Host "Press any key to exit..."
[void][System.Console]::ReadKey($true)
Exit
}
