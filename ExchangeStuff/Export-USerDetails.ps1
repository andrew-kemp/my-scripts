
do {
#Clear any current sessions
Get-PSsession | Remove-PSSession
#Clear the current Window
cls

"######################################################
##                                                  ##
##  What do you want to do?                         ##
##  1   -   Export Source Mailboxes to CSV          ##
##  2   -   Export Source RemoteMailboxes to CSV    ##
##  3   -   Import Mail Enabled Users into Target   ##
##  4   -   Import Mail Contacts into Target        ##
##                                                  ##
######################################################"
$Selection = Read-Host "Please Enter your selection: "

If ($TaskSelection -eq 1)
{
  #Get the credentials of the source admin account

$SourceCred = Get-Credential -Message "Please enter the SOURCE Admin Credentials"

#Get the URI for the source Exchange Management Shell
$SourceEx = Read-Host "Please enter the SOURCE Exchange Server FQDN eg andykemp-ex.ad.andykemp.com"
$sourceExURI = "http://" + $SourceEx + "/PowerShell/"
Write-Host "Connecting to source Exchange Server URI: " $sourceExURI  

#Conenct to source Exchange Environment
$SourceSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $sourceExURI -Authentication Kerberos -Credential $SourceCred
Import-PSSession $SourceSession

#Export User information
$Mailbox = Get-Mailbox -resultsize unlimited
$mailbox | ForEach-Object {Get-ADUser $_.SamAccountName -Properties * | 
Select-Object Name, GivenName, SurName, DisplayName, SamAccountName, UserPrincipalName, WindowsEmailAddress, mail, mailnickname, Title, Department, Company, Office, TelephoneNumber, Mobile, Description, City, @{Name="msExchHideFromAddressLists";Expression={$_.msExchHideFromAddressLists -join " "}}, LegacyExchangeDN, @{L='ProxyAddresses'; E={$_.ProxyAddresses -join ' '}} }|
Export-Csv -Path '.\UserDetails.csv' -Delimiter ";" -NoTypeInformation

Write-Host "File Exported to .\UserDetails.csv"

}
If ($TaskSelection -eq 1)
{

}
# Run another task
$response = read-host "Do you want to run another task? (y/n)"
}
while ($response -eq "Y")




#Get the credentials of the source admin account

$SourceCred = Get-Credential -Message "Please enter the SOURCE Admin Credentials"

#Get the URI for the source Exchange Management Shell
$SourceEx = Read-Host "Please enter the SOURCE Exchange Server FQDN eg andykemp-ex.ad.andykemp.com"
$sourceExURI = "http://" + $SourceEx + "/PowerShell/"
Write-Host "Source Exchange Server URI: " $sourceExURI



#Conenct to source Exchange Environment


$SourceSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $sourceExURI -Authentication Kerberos -Credential $SourceCred
Import-PSSession $SourceSession

$Mailbox = Get-Mailbox -resultsize unlimited

$mailbox | ForEach-Object {Get-ADUser $_.SamAccountName -Properties * | 
Select-Object Name, GivenName, SurName, DisplayName, SamAccountName, UserPrincipalName, WindowsEmailAddress, mail, mailnickname, Title, Department, Company, Office, TelephoneNumber, Mobile, Description, City, @{Name="msExchHideFromAddressLists";Expression={$_.msExchHideFromAddressLists -join " "}}, LegacyExchangeDN, @{L='ProxyAddresses'; E={$_.ProxyAddresses -join ' '}} }|
Export-Csv -Path '.\UserDetails' -Delimiter ";" -NoTypeInformation

#Disconnect from Source Exchange
Remove-PSSession $SourceSession

#Get the credentials of the Target admin account

$TargetCred = Get-Credential -Message "Please enter the TARGET Admin Credentials"

#Get the URI for the Target Exchange Management Shell
$TargeteEx = Read-Host "Please enter the TARGET Exchange Server FQDN eg andykemp-ex.ad.andykemp.com"
$TargetExURI = "http://" + $TargetEx + "/PowerShell/"
Write-Host "Source Exchange Server URI: " $TargetExURI

#Prompt for creation of Mail Enabled Users or Mail Contacts
Write-Host "Please make the following Selection:"
Write-Host "Select 1 for Mail Enabled Users"
Write-Host "Select 2 for Mail Contacts"
$Selection = Read-Host "Entet option: "





If ($Selection -eq 1){
    "Creating Mail Enabled Users"
}
elseif ($Selection -eq2) {
    "Creating Mail Contacts"
}
else {
    "You've Endered an incorrect option please start again"
}


#Get the OU where the new Contacts or MEU's are to be placed
$TargetOU = Read-Host "Waht is the Target OU for the new Objects?"
Write-Host "New objects will be created in " $TargetOU
