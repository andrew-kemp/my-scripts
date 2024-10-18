# Authenticate with Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"
######
function Get-RandomPassword {
    param (
        [int]$length = 16
    )
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}



#$password1 = Get-RandomPassword
#$password2 = Get-RandomPassword

$domains = Get-MgDomain
$onMicrosoftDomain = $domains | Where-Object { $_.Id -like "*.onmicrosoft.com" -and $_.ID -notlike "*.mail.onmicrosoft.com" }

if ($onMicrosoftDomain) {
    $onMicrosoftDomain | ForEach-Object { Write-Output "Found .onmicrosoft.com domain: $($_.ID)" }
    $domainName = $onMicrosoftDomain.ID  # Select the first .onmicrosoft.com domain
} else {
    Write-Output "No .onmicrosoft.com domain found."
    return
}
f# Function to check if a user exists
function Get-UserByUPN {
    param (
        [string]$upn
    )
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    return $user
}

# Function to create a new user with a specified password
function Create-NewUser {
    param (
        [string]$upnPrefix,
        [string]$password,
        [string]$domainName
    )
    $displayName = $upnPrefix -replace "\.", " "
    $names = $upnPrefix -split "\."
    $firstName = [string]$names
    $lastName = [string]$names
    $passwordProfile = @{
        Password = $password
        ForceChangePasswordNextSignIn = $true
    }
    $newUser = New-MgUser -AccountEnabled $true -DisplayName $displayName -MailNickname $upnPrefix -UserPrincipalName "$upnPrefix@$domainName" -PasswordProfile $passwordProfile -GivenName $firstName -Surname $lastName
    return $newUser
}

# Function to get or create a break glass account with a specified password
function GetOrCreateBreakGlassAccount {
    param (
        [string]$defaultUPNPrefix,
        [string]$password,
        [string]$domainName
    )
    $upnPrefix = Read-Host "Enter the UPN prefix for $defaultUPNPrefix (or press Enter to use default)"
    if ([string]::IsNullOrWhiteSpace($upnPrefix)) {
        $upnPrefix = $defaultUPNPrefix
    }
    $upn = "$upnPrefix@$domainName"
    $user = Get-UserByUPN -upn $upn
    if ($null -eq $user) {
        Write-Host "User not found. Creating new user..."
        $user = Create-NewUser -upnPrefix $upnPrefix -password $password -domainName $domainName
    }
    return $user
}

# Main script

$password1 = Get-RandomPassword  # Replace with your actual password
$password2 = Get-RandomPassword  # Replace with your actual password

$breakGlass1 = GetOrCreateBreakGlassAccount -defaultUPNPrefix "Break.Glass1" -password $password1 -domainName $domainName
$breakGlass2 = GetOrCreateBreakGlassAccount -defaultUPNPrefix "Break.Glass2" -password $password2 -domainName $domainName

Write-Host "Break Glass Account 1 UPN: $($breakGlass1.UserPrincipalName)"
Write-Host "Break Glass Account 2 UPN: $($breakGlass2.UserPrincipalName)"