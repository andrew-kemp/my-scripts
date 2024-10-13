# Script to create a set of Conditional Access Policies for a Tenant
# These Policies will be set to Report Only and Target a CA Test Group


# Ensure that the Microsoft Graph Module is installed by running:
# Install-Module Microsoft.Graph -Force
# If the Microsoft Graph is already installed then update running
# Update-Module Microsoft.Graph -Force

# Connect to the Microsoft Graph
Connect-MgGraph -Scopes "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess", "User.Read.All", "Group.ReadWrite.All"
Import-Module Microsoft.Graph.Identity.SignIns

# Check to see if the test Group Exists if not create a test group

$groupName = "_Group - CA Test"
$group = Get-MgGroup -Filter "DisplayName eq '$groupName'"

if ($group) {
    # Group exists, store its ID in $GroupID
    $GroupID = $group.Id
    Write-Output "The targeted group ID for $groupName is: $GroupID which will be applied to the CA Policies"
} else {
    # Group does not exist, create the group
    $newGroup = New-MgGroup -DisplayName $groupName -MailEnabled $false -MailNickname $groupName -SecurityEnabled $true
    $GroupID = $newGroup.Id
    Write-Output "The target group $groupName for the CA Policies has been created. The group ID is: $GroupID"
}

# Get the ID of the main admin account to exclude from the CA Policy
$ExcludeAdmin = Get-MgUser -userID admin@andykempdev.onmicrosoft.com
$ExcludeAdminID =$ExcludeAdmin.ID
    Write-Output "The Excluded user for all polcieis is $ExcludedAdmin and its ID is $ExcludeAdminID"



# Enable MFA for all users
$PolicyName = "101 - Enable MFA for all - Graph API"
$params = @{
    displayName = $PolicyName 
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeGroups = @("$GroupID")
            excludeUsers = @("$ExcludeAdminID")
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
            excludeUsers = @("$ExcludeAdminID")
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