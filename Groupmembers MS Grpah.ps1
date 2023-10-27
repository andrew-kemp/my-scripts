# Update Device extensionAttributes in bulk
# V1.0 by Andrew Kemp
# www.andrewkemp.co.uk
# www.x.com/andrew_kemp
#
# This script can do it one of two ways:
# 1. Get all devices with that have the name "PAW" in the DisplayNAme
# 2. Get Devices that are members of a specific Group.
#
# The idea behind this script is to tag devices that are used as Privilieged Access Workstations
# With the extensionAttribute set a Conditional Access Policy can be used to block access to 
# the Microsoft 365 portals for Admin users unless coming from the PAW


Connect-mgGraph -Scopes Device.Read.All, Directory.ReadWrite.All, Directory.AccessAsUser.All

# if using the device DisplayName then comment out the 2 lines in the group section and use 
# this line 
#Device DisplayName Option
$Devices = Get-MgDevice | Where-Object {$_.DisplayName -like '*PAW*'}

# If using a group use these 2 lines and comment out the above line
# Group Membership option
$GroupID = "2973260c-6b0d-4bf9-bf51-276e0e178fce"
$Devices = Get-MgGroupMember -GroupId $groupId

#Get each device that is in the group or has the name starting with PAW
ForEach ($device in $Devices) {

# The Graph Magic    
$uri = $null
$uri = "https://graph.microsoft.com/v1.0/devices/" + $device.id

$json = @{
      "extensionAttributes" = @{
      "extensionAttribute1" = "PAW"

         }
  } | ConvertTo-Json
  
Invoke-MgGraphRequest -Uri $uri -Body $json -Method PATCH -ContentType "application/json"
}

