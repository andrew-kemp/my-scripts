# Connect to Microsoft Graph interactively
#Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess"
# Define the body of the request

$BreakGlass1 = "admin1@tenant.onmicrosoft.com"
$BreakGlass2 = "admin2@tenant.onmicrosoft.com"

$body = @{
    displayName = "Require MFA for All Users Except Two"
    state = "reportOnly"
    conditions = @{
        users = @{
            includeUsers = @("All")
            excludeUsers = @($BreakGlass1, $BreakGlass2)
        }
        applications = @{
            includeApplications = @("All")
        }
    }
    grantControls = @{
        operator = "OR"
        builtInControls = @("mfa")
    }
} | ConvertTo-Json

# Set the URI for the request
$uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"

# Send the POST request to create the policy
$response = Invoke-RestMethod -Uri $uri -Headers @{ "Authorization" = "Bearer $($global:MgGraphAccessToken)" } -Method Post -Body $body -ContentType "application/json"

# Output the response
$response