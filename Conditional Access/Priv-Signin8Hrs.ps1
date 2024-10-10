# Define the body of the request
$body = @{
    displayName = "Sign-in Every 8 Hours for All Privileged Roles"
    state = "reportOnly"  # Set to "enabled" to enforce the policy
    conditions = @{
        users = @{
            includeRoles = @("All")
            excludeUsers = @("user1@domain.com", "user2@domain.com")
        }
        applications = @{
            includeApplications = @("All")
        }
    }
    sessionControls = @{
        signInFrequency = @{
            value = 8
            type = "hours"
        }
    }
} | ConvertTo-Json

# Set the URI for the request
$uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"

# Send the POST request to create the policy
$response = Invoke-RestMethod -Uri $uri -Headers @{ "Authorization" = "Bearer $($global:MgGraphAccessToken)" } -Method Post -Body $body -ContentType "application/json"

# Output the response
$response