# This requires the Intune Graph Module:
# Install-Module -Name Microsoft.Graph.Intune


# Connect to Microsoft Graph with the required scopes
# Connect-MSGraph -Scopes "DeviceManagementManagedDevices.ReadWrite.All", "DeviceManagementManagedDevices.PrivilegedOperations.All"

# Define the necessary variables
$deviceIds = @("device-id-1", "device-id-2", "device-id-3") # Add your device IDs here or use a CSV file

# Loop through each device ID and send the wipe command
foreach ($deviceId in $deviceIds) {
    try {
        Invoke-IntuneManagedDeviceWipeDevice -managedDeviceId $deviceId -keepEnrollmentData $false -keepUserData $false
        Write-Output "Wipe command sent to device ID: $deviceId"
    } catch {
        Write-Output "Failed to send wipe command to device ID: $deviceId. Error: $_"
    }
}