Get-MgGroupMember -GroupId $groupId

$GroupID = "2973260c-6b0d-4bf9-bf51-276e0e178fce"

$Devices = Get-MgGroupMember -GroupId $groupId

$Attributes = @{
    "ExtensionAttributes" = @{
      "extensionAttribute1" = "IoT"
      "extensionAttribute2" = "Win365Access"
}
} | ConvertTo-Json

foreach ($Device in $Devices){
    Update-MgDevice -DeviceId $Device -BodyParameter $Attributes   
}
