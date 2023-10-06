$users = Get-Mailbox | Where-Object{$_.PrimarySMTPAddress -match "londonsouthendjetcentre.co.uk"}


foreach($user in $users){
    Write-Host "Adding Alias $($user.alias)@londonsouthendjetcentre.co.uk"
    Set-Mailbox $user.PrimarySmtpAddress -EmailAddresses @{add="$($user.Alias)@londonsjc.com"}
}