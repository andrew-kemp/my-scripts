Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser
Install-Module PowershellGet -Force -Scope CurrentUser
Install-Module Microsoft.Graph -Force -Scope CurrentUser

Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser -Force

$params = @{
	extensionAttributes = @{
		extensionAttribute2 = "PAWAccess"
    }
}

$PAW = Get-MgDevice -Filter "startswith(displayName, 'Cloud-PAW')"

ForEach-Object {
    Update-MgDevice -DeviceId $PAW.ID -BodyParameter $params
}



Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/devices/8eb05d10-261b-4eb8-9ca1-833d5d574b0f" -Body @{extensionAttribute2 = "PAW"}