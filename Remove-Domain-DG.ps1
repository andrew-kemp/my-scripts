$Records = Get-DistributionGroup -ResultSize Unlimited| where {$_.emailaddresses -like "smtp:*@esprit-group.com"} | Select-Object DisplayName,@{Name=“EmailAddresses”;Expression={$_.EmailAddresses |Where-Object {$_ -like “smtp:*esprit-group.com”}}}
 
foreach ($record in $Records)
{
    write-host "Removing Alias" $record.EmailAddresses "for" $record.DisplayName
    Set-DistributionGroup $record.DisplayName -EmailAddresses @{Remove=$record.EmailAddresses}
}