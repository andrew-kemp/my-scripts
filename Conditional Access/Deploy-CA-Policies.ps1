Connect-MgGraph -Scopes "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess", "User.Read.All"
Import-Module Microsoft.Graph.Identity.SignIns
# Get the ID of the main admin account to exclude from the CA Policy
$ExcludeAdmin = Get-MgUser -userID admin@andykempdev.onmicrosoft.com
$ExcludeAdminID =$ExcludeAdmin.ID

# Get the ID of the group to target the policies at
$GroupName = "_Group - CA Test"
$TargetGroup = Get-MgGroup -Filter "DisplayName eq '$groupName'"
$TargetGroupID = $TargetGroup.ID

# Enable MFA for all users
$params = @{
    displayName = "101 - Enable MFA for all - Graph API"
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeGroups = @("$TargetGroupID")
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

New-MgIdentityConditionalAccessPolicy -BodyParameter $params


# Only Allow Company Owned Devices access
$params = @{
    displayName = "102 - Allow Company owned devices only - Graph API"
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeGroups = @("$TargetGroupID")
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