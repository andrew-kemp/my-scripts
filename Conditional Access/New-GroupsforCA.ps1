function Get-GroupByName {
    param (
        [string]$groupName
    )
    $group = Get-MgGroup -Filter "displayName eq '$groupName'"
    return $group
}

# Function to create a new group
function Create-NewGroup {
    param (
        [string]$groupName
    )
    $mailNickname = $groupName -replace " ", ""
    $newGroup = New-MgGroup -DisplayName $groupName -MailEnabled:$false -MailNickname $mailNickname -SecurityEnabled:$true
    return $newGroup
}

# Function to get or create a group with custom prompts
function GetOrCreateGroup {
    param (
        [string]$defaultGroupName,
        [string]$promptMessage
    )
    while ($true) {
        $useExistingGroup = Read-Host $promptMessage
        if ($useExistingGroup -eq "yes" -or $useExistingGroup -eq "y") {
            $groupName = Read-Host "Enter the group display name"
            $group = Get-GroupByName -groupName $groupName
            if ($null -eq $group) {
                Write-Host "Group not found. Please try again."
            } else {
                return $group
            }
        } else {
            $useTemplateName = Read-Host "Do you want to use the template name $defaultGroupName? (yes/no)"
            if ($useTemplateName -eq "yes" -or $useTemplateName -eq "y") {
                $groupName = $defaultGroupName
            } else {
                $groupName = Read-Host "Enter the new group name"
            }
            $group = Create-NewGroup -groupName $groupName
            return $group
        }
    }
}

# Main script with custom prompts
$group1 = GetOrCreateGroup -defaultGroupName "UserGroup1" -promptMessage "Would you like to use an existing group to target at the test users? (yes/no)"
$group2 = GetOrCreateGroup -defaultGroupName "VIPGroup" -promptMessage "Would you like to use an existing group to target at the  VIP test users? (yes/no)"
$group3 = GetOrCreateGroup -defaultGroupName "PrivGroup" -promptMessage "Would you like to use an existing group to target at the test users with Privileged Roels assigned? (yes/no)"

Write-Host "Group 1 ID: $($group1.Id)"
Write-Host "Group 2 ID: $($group2.Id)"
Write-Host "Group 3 ID: $($group3.Id)"

function Get-GroupByName {
    param (
        [string]$groupName
    )
    $group = Get-MgGroup -Filter "displayName eq '$groupName'"
    return $group
}

# Function to create a new group
function Create-NewGroup {
    param (
        [string]$groupName
    )
    $mailNickname = $groupName -replace " ", ""
    $newGroup = New-MgGroup -DisplayName $groupName -MailEnabled:$false -MailNickname $mailNickname -SecurityEnabled:$true
    return $newGroup
}

# Function to get or create a group with custom prompts
function GetOrCreateGroup {
    param (
        [string]$defaultGroupName,
        [string]$promptMessage
    )
    while ($true) {
        $useExistingGroup = Read-Host $promptMessage
        if ($useExistingGroup -eq "yes" -or $useExistingGroup -eq "y") {
            $groupName = Read-Host "Enter the group display name"
            $group = Get-GroupByName -groupName $groupName
            if ($null -eq $group) {
                Write-Host "Group not found. Please try again."
            } else {
                return $group
            }
        } else {
            $useTemplateName = Read-Host "Do you want to use the template name $defaultGroupName? (yes/no)"
            if ($useTemplateName -eq "yes" -or $useTemplateName -eq "y") {
                $groupName = $defaultGroupName
            } else {
                $groupName = Read-Host "Enter the new group name"
            }
            $group = Create-NewGroup -groupName $groupName
            return $group
        }
    }
}

# Main script with custom prompts
$group1 = GetOrCreateGroup -defaultGroupName "UserGroup1" -promptMessage "Would you like to use an existing group to target at the test users? (yes/no)"
$group2 = GetOrCreateGroup -defaultGroupName "VIPGroup" -promptMessage "Would you like to use an existing group to target at the  VIP test users? (yes/no)"
$group3 = GetOrCreateGroup -defaultGroupName "PrivGroup" -promptMessage "Would you like to use an existing group to target at the test users with Privileged Roels assigned? (yes/no)"

Write-Host "Group 1 ID: $($group1.Id)"
Write-Host "Group 2 ID: $($group2.Id)"
Write-Host "Group 3 ID: $($group3.Id)"

