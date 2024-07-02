"Conecting to Required Services"
Import-Module ActiveDirectory
$ExchangeFQDN = Read-Host "What is the FQDN of the local Exchange Server (eg at365-ex2013.allthings365.co.uk)"
$ExchangeURI = "http" + $ExchangeFQDN + "/PowerShell/"
$usercred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeURI -Authentication Kerberos -Credential $usercred
Import-PSSession $Session
$s = NEW-PSSESSION -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $userCred -Authentication Basic -AllowRedirection 
$importresults=import-pssession $s -Prefix Cloud
Connect-MSolService -credential $usercred
Import-Module DirSync
$TenantName = Read-Host "Please enter in the tenant domain name (without the .onmicrosoft.com)"
$LicensePack = Read-Host "Please enter the License SKU/ E3 = ENTERPRISEPACK, E1 = STANDARDPACK"

do {

cls
"##################################################################
## Which Admin Task do you want to do?                          ##
##  1 - Reconnecto to the online Services                       ##
##  2 - Create a new user                                       ##
##  3 - Change a users name                                     ##
##  4 - Create a shared mailbox                                 ##
##  5 - Check mailboxes a user has access to                    ##
##  6 - Check who has access to s specified mailbox             ##
##  7 - Convert a Mailbox to Shared/resource/regular            ##
##  8 - License a USer                                          ##
##  9 - Add Multiple users in a CSV File                        ##
##  10 - Force a delta Sync                                     ##
##  11 - Force a full Sync                                      ##
##  12 - quit                                                   ##
##################################################################"
$TaskSelection = Read-Host
If ($TaskSelection -Eq 1)
{
    "Reconnecting to the online services"
}

If ($TaskSelection -Eq 2)
{
    "Creating a new User"
    do {
    #User Account Varialbles:
    $SamAccountName = Read-Host "Please enter in the new SamAccountName (eg Luke.Skywalker)"
    $UPNSuffix = Read-Host "Please enter in the UPN Suffix (eg allthings365.co.uk)"
    $FirstName = Read-Host "Please enter in the First Name (eg Luke)"
    $LastNAme = Read-Host "Please enter in the Surname (eg Skywalker)"
    $Company = Read-Host "Please enter in the company name (eg All Things 365)"
    $Title = Read-Host "please enter in the Job Title (eg Jedi Knight)"
    $DisplayName = $FirstNAme + " " + $LastName
    $UPN = $SamAccountName + "@" + $UPNSuffix
    $RoutingAddress = $SamAccountName + "@" + $TenantName + ".mail.onmicrosoft.com"
    $License = $TenantName + ":" + $LicensePack

    "SamAccountName:            $SamAccountName"
    "FirstName:                 $FirstName"
    "Last Name:                 $LastName"
    "Display Name:              $DisplayName"
    "User Principal Name:       $UPN"
    "Description and Job title: $Title"
    "Email Address:             $UPN"
    "Remote Routing Address:    $RoutingAddress"
    "Company:                   $Company"
    "License:                   $LicensePack"

     $response = read-host "Does the above look correct? (y/n)"
    }
    while ($response -eq "n")
    #Create the AD users based on the answers above
    New-ADUser -Name $DisplayName -GivenNAme $FirstNAme -Surname $LastName -SamAccountName $SamAccountName -UserPrincipalName $UPN -Description $Title -Title $title -Company $Company -HomePage "http://www.stobartgroup.com" -Path "OU=Standard,OU=Users,OU=Stobart Group OU,DC=stobartgroup,DC=com" -AccountPAssword(ConvertTo-SecureString "Stobart01" -AsPlainText -force) -enabled $true -ChangePasswordAtLogon $true -PassThru
    #Create a remote mailbox for the user
    Enable-RemoteMailbox $SamAccountName -RemoteRoutingAddress $RoutingAddress
    #Run a Windows Azure Active Directory Sync
    Start-OnlineCoexistenceSync
    Write-Host "Waiting for Directory Sync to run, this can take up to 2 minutes..."
    #Wait for Windows Azure Active Directory Sync to compelte
    Start-Sleep -Seconds 120
    Write-Host " Directory Sync complete Assigning Licenses to the user..."
    #Assign the license to the newly created user
    Set-MsolUser -UserPrincipalName $UPN -UsageLocation GB
    Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses $License
    #give the option to create another user
   

}
If ($TaskSelection -Eq 3)
{
    "Change the name of an exisiting user"
}
If ($TaskSelection -Eq 4)
{
    "Creating a Shared Mailbox"
}
If ($TaskSelection -Eq 5)
{
    "Check mailboxes a user has access to "
}
If ($TaskSelection -Eq 6)
{
    "Check who has access to a specified mailbox"
}
If ($TaskSelection -Eq 7)
{

    
do {
cls
"##################################################################
##                                                                ##
##     What Type of Mailbox do you want to convert to             ##
##     1 - Shared                                                ##
##     2 - Equipment                                             ##
##     3 - Room                                                  ##
##     4 - User                                                  ##
##                                                                ##
####################################################################"
    $MailboxType = Read-Host
    If ($MailBoxType -Eq 1)
    {
        "Converting to shared"
    }
    If ($MailBoxType -Eq 2)
    {
        "Converting to Equipmnet"
    }
    If ($MailBoxType -Eq 3)
    {
        "Converting to Room"
    }
    If ($MailBoxType -Eq 4)
    {
        "Converting to Regular"
        }
    If ($MailBoxType -Eq 15)
    {
        "Go Back"
    }
    
      $responsemailbox = read-host "convert another mailbox (y/n)"
}
while ($responsemailbox -eq "Y")
}
If ($TaskSelection -Eq 8)
{
    "License a user"
}
If ($TaskSelection -Eq 9)
{
    "Add Multiple users"
}
If ($TaskSelection -Eq 10)
{
    Start-OnlineCoexistenceSync
}
If ($TaskSelection -Eq 11)
{
    Start-OnineCoexistenceSync -Full
    
}
If ($TaskSelection -Eq 12)
{
    exit
}

    $response = read-host "Do you want to run another task? (y/n)"
}
while ($response -eq "Y")