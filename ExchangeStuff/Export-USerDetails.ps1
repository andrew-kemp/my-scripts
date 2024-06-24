$SourceCred = "Enter Source Credentials" Get-Credential

$Mailbox = Get-Mailbox -resultsize unlimited

$mailbox | foreach {Get-ADUser $_.SamAccountName -Properties * | 
Select-Object Name, GivenName, SurName, DisplayName, SamAccountName, UserPrincipalName, WindowsEmailAddress, mail, mailnickname, Title, Department, Company, Office, TelephoneNumber, Mobile, Description, City, @{Name="msExchHideFromAddressLists";Expression={$_.msExchHideFromAddressLists -join " "}}, LegacyExchangeDN, @{L='ProxyAddresses'; E={$_.ProxyAddresses -join ' '}} }|
Export-Csv -Path 'C:\scripts\10proxyaddresses.csv' -Delimiter ";" -NoTypeInformation