Import-Csv .\2012Users.csv | foreach-object {

Set-ADUser -identity $_.Pre2000UN -UserprincipalName USerLogonName
Enable-MailUser -identity $_.Pre2000UN  -PrimarySMTPAddress $_.UserLogonName -ExternalEmailAddress $_.EXTE-Mail

}