Connect-mgGraph -Scopes Device.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All
$GroupID = "2973260c-6b0d-4bf9-bf51-276e0e178fce"
$Devices = Get-MgGroupMember -GroupId $groupId

ForEach ($device in $Devices) {

$uri = $null
$uri = "https://graph.microsoft.com/v1.0/devices/" + $device.id

$json = @{
      "extensionAttributes" = @{
      "extensionAttribute1" = "IoT"
      "extensionAttribute2" = "Win365Access"
      "extensionAttribute3" = "IoT Access Only"
         }
  } | ConvertTo-Json
  
Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
}