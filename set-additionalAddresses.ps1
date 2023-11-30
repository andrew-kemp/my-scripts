Import
Import-Csv “.\EspionUsers_Import.csv” | ForEach-Object{
New-MailUser -Name $_.Name -DisplayName $_.DisplayName -SamAccountName $_.SamAccountName -UserPrincipalName $_.BSIEmail -Alias $_.Alias -PrimarySMTPAddress $_.BSIEmail -ExternalEmailAddress $_.PrimarySmtpAddress -OrganizationalUnit "bsi-global.net//Test/Contacts"  -Password (ConvertTo-SecureString -String 'P@ssw0rd1' -AsPlainText -Force)
  $name = $_.BSIEmail
  $proxy = $_.emailaddresses -split ' '
  Set-MailUser -Identity $name -EmailAddresses @{add= $proxy}
}
