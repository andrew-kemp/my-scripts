# Script to bulk create security groups via the Microsoft Graph
# Install the Microsoft Graph Module by running Install-Module Microsoft.Graph.
# This Script will connect to the Microsoft Graph and then use a CSV file name SecGroups.csv in the same location as the script is located
# Written by Andrew Kemp 17th May 2024



# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All"
Import-Csv ".\SecGroups.csv" | ForEach-Object{

# Store the details from the CSV in the variables as for some reason they do not work if set directly in the details of the parameters new group    
$GroupName = $_.Name
$GroupDescription = $_.Description
$GroupMailNickName = $_.MailNickName
$Owner = $_.Owner

# Set the Parameters of the group
$param = @{
 description=$GroupDescription
 displayName=$GroupName
 mailEnabled=$false
 securityEnabled=$true
 mailNickname=$GroupMailNickName
}
# Create the group based on the parameters set above which are pulled from the CSV
New-MgGroup @param

#Sets the owner to the group
$Group = Get-MGGroup -Filter "DisplayName eq '$GroupName'"
$GroupOwner = Get-MGUser -Filter "UserPrincipalName eq '$Owner'"

New-MgGroupOwner -GroupId $Group.ID -DirectoryObjectId $GroupOwner.ID
}