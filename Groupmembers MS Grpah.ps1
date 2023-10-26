Import-Module Microsoft.Graph.Identity.DirectoryManagement
Select-MgProfile -Name "beta"
Connect-mgGraph -Scopes Device.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All
$GroupID = "2973260c-6b0d-4bf9-bf51-276e0e178fce"
$Devices = Get-MgGroupMember -GroupId $groupId

ForEach ($device in $Devices) {

$uri = $null
$uri = "https://graph.microsoft.com/beta/devices/" + $device.id

$json = @{
      "extensionAttributes" = @{
      "extensionAttribute1" = "IoT"
      "extensionAttribute2" = "Win365Access"
         }
  } | ConvertTo-Json
  
Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
}