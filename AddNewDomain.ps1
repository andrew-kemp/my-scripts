$PrimaryDomain = Read-Host "What is the Primary Domain you want to update?"
$SecondaryDomain = Read-Host "What is the new doomain you want to add as an alias?"

$users = Get-Mailbox | Where-Object{$_.PrimarySMTPAddress -match $PrimaryDomain}
 
foreach($user in $users)
{
    Write-Host "Adding Alias $($user.alias)@+$SecondayDomain to $user.PrimarySmtpAddress"
    #Set-Mailbox $user.PrimarySmtpAddress -EmailAddresses @{add="$($user.Alias)@+$SecondayDomain"}
}