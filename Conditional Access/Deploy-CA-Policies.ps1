<#
.SYNOPSIS
Script to create 2 Break Glass Accounts, each with a 16 Random character password
and create a bunch of Conditional Access Policies targeted to a group to test agains
each conditional access policy is set to ReportOnly initally. 

.DESCRIPTION
Created by Andrew Kemp
Version 1.2
Email andrew@kemponline.co.uk
Date Created 13th October 2024
Date Updated 13th October 2024
Updates made: 14th October 2024

.PARAMETER length
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
# Script to create a set of Conditional Access Policies for a Tenant
# These Policies will be set to Report Only and Target a CA Test Group
# Created by Andrew Kemp
# Version 1.1
# Email andrew@kemponline.co.uk
# Date Created 13th October 2024
# Date Updated 13th October 2024
# Updates made: 


# Ensure that the Microsoft Graph Module is installed by running:
# Install-Module Microsoft.Graph -Force
# If the Microsoft Graph is already installed then update running
# Update-Module Microsoft.Graph -Force

# Connect to the Microsoft Graph
Connect-MgGraph -Scopes "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess", "User.Read.All", "Group.ReadWrite.All"
Import-Module Microsoft.Graph.Identity.SignIns

# Get the Teanant domain name
$domains = Get-MgDomain
$onMicrosoftDomain = $domains | Where-Object { $_.Id -like "*.onmicrosoft.com" -and $_.ID -notlike "*.mail.onmicrosoft.com" }

if ($onMicrosoftDomain) {
    $onMicrosoftDomain | ForEach-Object { Write-Output "Found .onmicrosoft.com domain: $($_.ID)" }
    $domainName = $onMicrosoftDomain.ID  # Select the first .onmicrosoft.com domain
} else {
    Write-Output "No .onmicrosoft.com domain found."
    return
}

# create the Break Glass Account UPN if they will be needed down the line
$BreakGlass1 = "BreakGlass1@$domainName"
$BreakGlass2 = "BreakGlass2@$domainName"

# Fulntion to create a randomly generates 16 Character Password:
function Get-RandomPassword {
    param (
        [int]$length = 16
    )
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

$password1 = Get-RandomPassword
$password2 = Get-RandomPassword
# Create the two break glass accounts
$userInfo1 = @{
    accountEnabled = $true
    displayName = "Break Glass Admin 1"
    mailNickname = "breakglassadmin1"
    userPrincipalName = "$BreakGlass1"
    passwordProfile = @{
        forceChangePasswordNextSignIn = $false
        password = $password1
    }
}

$newUser1 = New-MgUser -BodyParameter $userInfo1
$UserID1 = $newUser1.ID



$userInfo2 = @{
    accountEnabled = $true
    displayName = "Break Glass Admin 2"
    mailNickname = "breakglassadmin2"
    userPrincipalName = "$BreakGlass2"
    passwordProfile = @{
        forceChangePasswordNextSignIn = $false
        password = $password2
    }
}

$newUser2 = New-MgUser -BodyParameter $userInfo2
$UserID2 = $newUser2.ID

Write-Output "User created. The user ID is: $userId1"
Write-Output "The password is: $password1"
Write-Output "User created. The user ID is: $userId2"
Write-Output "The password is: $password2"

# Add teh Global Admin Role to the new Break Glass Accounts
$roleName = "Global Administrator"
$role = Get-MgDirectoryRole | Where-Object { $_.DisplayName -eq $roleName }

if (-not $role) {
    # If the role does not exist, create it
    $roleTemplate = Get-MgDirectoryRoleTemplate | Where-Object { $_.DisplayName -eq $roleName }
    $role = New-MgDirectoryRole -DisplayName $roleName -RoleTemplateId $roleTemplate.Id
}

# Assign the role to the user
$roleMember = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId1"
}

New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.Id -BodyParameter $roleMember

Write-Output "Global Admin role assigned to user ID: $userId1"

$roleMember = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId2"
}

New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.Id -BodyParameter $roleMember

Write-Output "Global Admin role assigned to user ID: $userId2"


# Check to see if the test Group Exists if not create a test group

$groupName = "_Group - CA Test"
$group = Get-MgGroup -Filter "DisplayName eq '$groupName'"

if ($group) {
    # Group exists, store its ID in $GroupID
    $GroupID = $group.Id
    Write-Output "The targeted group ID for $groupName is: $GroupID which will be applied to the CA Policies"
} else {
    # Group does not exist, create the group
    $param = @{
        description="Conditional Access Policy Test Group"
        displayName="_Group - CA Test"
        mailEnabled=$false
        securityEnabled=$true
        mailNickname="catest"
       }
       # Create the group based on the parameters set above which are pulled from the CSV
       $newGroup =   New-MgGroup @param
     
    #New-MgGroup -DisplayName $groupName -MailEnabled $false -MailNickname $groupName -SecurityEnabled $true
    $GroupID = $newGroup.Id
    Write-Output "The target group $groupName for the CA Policies has been created. The group ID is: $GroupID"
}


# Enable MFA for all users
$PolicyName = "101 - Enable MFA for all - Graph API"
$params = @{
    displayName = $PolicyName 
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeGroups = @("$GroupID")
            excludeUsers = @("$UserID1",
                            "$UserID2")
        }
        applications = @{
            includeApplications = @("All")

        }
    }
    grantControls = @{
        operator = "OR"
        builtInControls = @("mfa")
    }
} 
Write-Output "Creating Conditional Access Policy $PolicyName "
New-MgIdentityConditionalAccessPolicy -BodyParameter $params
Write-output "$PolicyName has been created"



# Only Allow Company Owned Devices access
$params = @{
    displayName = "102 - Allow Company owned devices only - Graph API"
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeGroups = @("$GroupID")
            excludeUsers = @("$UserID1",
                            "$UserID2")
        }
        applications = @{
            includeApplications = @("All")
            excludeApplications = @(

            "270efc09-cd0d-444b-a71f-39af4910ec45",
            "372140e0-b3b7-4226-8ef9-d57986796201",
            "9cdead84-a844-4324-93f2-b2e6bb768d07",
            "0af06dc6-e4b5-4f28-818e-e78e62d137a5",
            "d4ebce55-015a-49b5-a083-c84d1797ae8c",
            "0000000a-0000-0000-c000-000000000000"

            )
        }
        devices = @{
            deviceFilter = @{
                mode = "exclude"
                rule = 'device.deviceOwnership -eq "Company"'
            }
        }
    }
    grantControls = @{
        operator = "OR"
        builtInControls = @("block")
    }
} 

New-MgIdentityConditionalAccessPolicy -BodyParameter $params



# Get the user ID of the owner
$Owner = Get-MgUser -UserID $OwnerUPN
$ownerId = $owner.Id

# Add the user as an owner of the group
$ownerRef = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ownerId"
}

New-MgGroupOwnerByRef -GroupId $groupId -BodyParameter $ownerRef

Write-Output "Owner added to the group. The owner ID is: $ownerId"
