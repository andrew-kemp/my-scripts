Connect-MgGraph -Scopes "Policy.Read.All", "Policy.ReadWrite.ConditionalAccess"
Import-Module Microsoft.Graph.Identity.SignIns

$params = @{
    displayName = "103 - Allow Company owned devices only - Graph API"
    state = "enabledForReportingButNotEnforced"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeGroups = @("44cb023b-43fe-4f9b-89cd-e021ea139ce5")
            excludeUsers = @("834bc9aa-557b-4e4d-8f2e-6882bbbeaeb7")
        }
        applications = @{
            includeApplications = @("All")
            excludeApplications = @(

                "d4ebce55-015a-49b5-a083-c84d1797ae8c",
                "0000000a-0000-0000-c000-000000000000" # Microsoft Intune Enrollment app ID

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