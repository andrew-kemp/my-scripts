Connect-MgGraph -Scopes "Device.ReadWrite.All"
$devices = Get-MgDevice -Filter "startswith(displayName,'PAW-')"

foreach ($device in $devices) {
    Update-MgDevice -DeviceId $device.Id -BodyParameter @{
        "extensionAttribute1" = "Privileged Access Workstation"
    }
}