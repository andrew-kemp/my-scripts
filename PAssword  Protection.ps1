Import-Module AzureADPasswordProtection
Get-Service AzureADPasswordProtectionProxy | fl

Register-AzureADPasswordProtectionProxy -AccountUpn 'admin@andykempdev.onmicrosoft.com' -AuthenticateUsingDeviceCode

Enter-PSSession -ComputerName akdev-pwdproxy3

New-PSDrive -Name "S" -PSProvider "FileSystem" -Root "\\akdev-dc2\apps" -Credential akdev\adminak

S:\AzureADPasswordProtectionProxySetup.exe /quiet


Register-AzureADPasswordProtectionForest -AccountUpn 'admin@andykempdev.onmicrosoft.com' -AuthenticateUsingDeviceCode

Test-AzureADPasswordProtectionProxyHealth -TestAll
