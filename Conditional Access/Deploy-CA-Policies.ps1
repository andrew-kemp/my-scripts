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


########################################################################
# Connect to the Microsoft Graph
Connect-MgGraph -Scopes "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess", "User.Read.All", "Group.ReadWrite.All"
Import-Module Microsoft.Graph.Identity.SignIns
# End conect to Microsoft Graph
########################################################################

########################################################################
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
# End getting the tenant domain name
########################################################################

########################################################################
# create the Break Glass Account UPN if they will be needed down the line
$BreakGlass1 = "BreakGlass1@$domainName"
$BreakGlass2 = "BreakGlass2@$domainName"
# End setting the Break Glass UPN's
########################################################################

########################################################################
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
#End create 2 random passwords
########################################################################

########################################################################
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


# End create new Break Glass accounts
########################################################################

########################################################################
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
# End add Global Admin role to Break Glass accounts
########################################################################


########################################################################
# Check to see if the test Group Exists if not create a test group

$groupName = "_Group - CA Test"
$group = Get-MgGroup -Filter "DisplayName eq '$groupName'"

if ($group) {
    # Group exists, store its ID in $GroupID
    $GroupID = $group.Id
    Write-Output "The targeted group ID for $groupName is: $GroupID which will be applied to the CA Policies"
} else {
    # Group does not exist, create the group
    $grpParams = @{
        description="Conditional Access Policy Test Group"
        displayName="_Group - CA Test"
        mailEnabled=$false
        securityEnabled=$true
        mailNickname="catest"
       }
       # Create the group based on the parameters set above which are pulled from the CSV
       $newGroup =   New-MgGroup @grpParams
     
    #New-MgGroup -DisplayName $groupName -MailEnabled $false -MailNickname $groupName -SecurityEnabled $true
    $GroupID = $newGroup.Id
    Write-Output "The target group $groupName for the CA Policies has been created. The group ID is: $GroupID"
}

# End Create Test Group
########################################################################

########################################################################
# Create a group for Privileged accounts

# Define the dynamic membership rule
$membershipRule = '((user.userPrincipalName -contains "admin_"))'
# Create the dynamic group
$PrivgrpName = "_Priv - Admin Users"
$grpParams = @{
    displayName = $PrivgrpName
    groupTypes = "DynamicMembership"
    mailEnabled = $false
    mailNickname = "adminusersgroup"
    membershipRule = $membershipRule
    membershipRuleProcessingState = "On"
    securityEnabled = $true
}
$PrivGroup = New-MgGroup @grpParams
$PrivGroupID = $PrivGroup.Id
# End create Privileged Users Group
########################################################################

########################################################################
# Sleep for 5 Seconds to allow the groups to be created
Start-Sleep -Seconds 5
# End Sleep
########################################################################
# Add the 2 Break Glass Accounts as owners for the newly created groups
# Add BreakGlass 1 as Group Owner
$Owner = Get-MgUser -UserID $BreakGlass1
$ownerId = $owner.Id

# Add the user as an owner of the group
$ownerRef = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ownerId"
}

New-MgGroupOwnerByRef -GroupId $groupId -BodyParameter $ownerRef
New-MgGroupOwnerByRef -GroupId $PrivGroupID -BodyParameter $ownerRef
Write-Output "Owner added to the group. The owner ID is: $ownerId"

# Add BreakGlass 2 as Group Owner
$Owner = Get-MgUser -UserID $BreakGlass2
$ownerId = $owner.Id

# Add the user as an owner of the group
$ownerRef = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ownerId"
}

New-MgGroupOwnerByRef -GroupId $groupId -BodyParameter $ownerRef
New-MgGroupOwnerByRef -GroupId $PrivGroupID -BodyParameter $ownerRef

Write-Output "Owner added to the group. The owner ID is: $ownerId"
# End Add owners
########################################################################

########################################################################
# Enable MFA for all users
$PolicyName1 = "101 - Enable MFA for all - Graph API"
$params1 = @{
    displayName = $PolicyName1 
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
Write-Output "Creating Conditional Access Policy $PolicyName1 "
New-MgIdentityConditionalAccessPolicy -BodyParameter $params1



#########################################################################################
# Only Allow Company Owned Devices access
$PolicyName2 = "102 - Allow Company owned devices only - Graph API"
$params2 = @{
    displayName = $PolicyName2
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


Write-Output "Creating Conditional Access Policy $PolicyName2 "
New-MgIdentityConditionalAccessPolicy -BodyParameter $params2

#####################################################################################
# Privilege users to sign in every 8Hrs

$PolicyName3 = "901 - Privileged ssers sign in every 8 hours - Graph API"
$params3 = @{
    displayName = $PolicyName 
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            IncludeGroups = @("$PrivGroupID")
            excludeUsers = @("$UserID1",
                            "$UserID2")
        }
        applications = @{
            includeApplications = @("All")
        }
    }
    sessionControls = @{
        signInFrequency = @{
            value = 8
            type = "hours"
            isEnabled = $true

        }
    }
}
Write-Output "Creating Conditional Access Policy $PolicyName3 "
New-MgIdentityConditionalAccessPolicy -BodyParameter $params3
# End Creating Policy
#####################################################################################

#####################################################################################
# Create policy 4
$PolicyName4 = "103 - Block Downloads for None Company devices via web - Graph API"
$params4 = @{
    displayName = $PolicyName 
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            IncludeGroups = @("$PrivGroupID")
            excludeUsers = @("$UserID1",
                            "$UserID2")
        }
        applications = @{
            includeApplications = @("All")
        }
        clientAppTypes = @(
	            "browser"
	
        )
        
       deviceFilter = @{
                mode = "exclude"
                rule = 'device.trustType -eq "AzureAD" -or device.trustType -eq "ServerAD" -or device.deviceOwnership -eq "Company"'
    
}
        sessionControls = @{ 
            cloudAppSecurity = @{
                cloudAppSecurityType = "blockDownloads" 
                isEnabled = $true
            }
        }
        grantControls = @{
            operator = "OR"
            builtInControls = @(
            "block"
            )
        }
    }
}

Write-Output "Creating Conditional Access Policy $PolicyName4 "
New-MgIdentityConditionalAccessPolicy -BodyParameter $params4
# End create policy 4
#####################################################################################

#####################################################################################
# Create policy 4

# End create policy 4
#####################################################################################

#####################################################################################
# Create policy 4

# End create policy 4
#####################################################################################
Clear
# Write the details of what has been created
Write-Output "Break Glass 1 has been created with username $BreakGlass1. The user ID is: $userId1"
Write-Output "The password is: $password1"
Write-Output "Break Glass 1 has been created with username $BreakGlass2. The user ID is: $userId2"
Write-Output "The password is: $password2"

Write-output "$PolicyName1 has been created"
Write-output "$PolicyName2 has been created"
Write-output "$PolicyName3 has been created"






