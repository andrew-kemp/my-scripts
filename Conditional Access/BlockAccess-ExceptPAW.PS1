# Define the body of the request
$body = @{
    displayName = "Block All Apps Except Autopilot for Privileged Roles"
    state = "reportOnly"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeRoles = @("All")
            excludeUsers = @("user1@domain.com", "user2@domain.com")
        }
        applications = @{
            includeApplications = @("All")
            excludeApplications = @(
                "0000000a-0000-0000-c000-000000000000",  # Autopilot app ID
                "d4ebce55-015a-49b5-a083-c84d1797ae8c",  # Microsoft Intune Enrollment app ID
                "0000000a-0000-0000-c000-000000000001"   # Microsoft Intune app ID
            )
        }
        devices = @{
            deviceFilter = @{
                mode = "exclude"
                rule = "(device.extensionAttribute1 -eq 'Privileged Access Workstation')"
            }
        }
    }
    grantControls = @{
        operator = "OR"
        builtInControls = @("block")
    }
} | ConvertTo-Json

# Set the URI for the request
$uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"

# Send the POST request to create the policy
$response = Invoke-RestMethod -Uri $uri -Headers @{ "Authorization" = "Bearer $($global:MgGraphAccessToken)" } -Method Post -Body $body -ContentType "application/json"

# Output the response
$response