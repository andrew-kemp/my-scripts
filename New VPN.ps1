#
.SYNOPSIS
    Creates an Always On VPN user tunnel connection

.PARAMETER xmlFilePath
    Path to the ProfileXML configuration file

.PARAMETER ProfileName
    Name of the VPN profile to be created

.EXAMPLE
    .\New-AovpnUserTunnel.ps1 -xmlFilePath "C:\Temp\User.xml" -ProfileName "SLC User Tunnel"

.DESCRIPTION
    This script will create an Always On VPN user tunnel on supported Windows devices

.NOTES
    Updated:            07/06/23
    Creation Date:      30/07/21
    Note:               This is a modified version of a script that Jon Anderson created, in turn based upon scripts created by Richard Hicks
    Note:               With additions to prioritise the AOVPN Interface Metric based upon https://sccmf12twice.com/aovpn-deployment-with-sccm-lessons-learned/
    Note:               Profile capture + ConfigMgr deployment = https://configjon.com/always-on-vpn-user-tunnel/
    Original Script:    https://github.com/ConfigJon/AlwaysOnVPN/blob/master/New-AovpnUserTunnel.ps1
    Original Script:    https://github.com/richardhicks/aovpn/blob/master/New-AovpnConnection.ps1
#>

[CmdletBinding()]

Param(
    [Parameter(Mandatory = $True, HelpMessage = 'Enter the path to the ProfileXML file.')]    
    [string]$xmlFilePath,
    [Parameter(Mandatory = $False, HelpMessage = 'Enter a name for the VPN profile.')]        
    [string]$ProfileName = 'SLC User Tunnel'
)

#Variables ============================================================================================================
$UserTunnelVersion = 0.2
$DetectionRegKey = "SOFTWARE\SLC"
$DetectionRegValue = "AOVPNUserTunnelVersion"
$InterfaceMetric = 1
$LogsDirectory = "$ENV:ProgramData\AOVPN"
$RasphoneUsername = ((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$UserRasphonePath1 = "C:\Users\$RasphoneUsername\AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk"
$UserRasphoneBackupPath1 = Join-Path "C:\Users\$RasphoneUsername\AppData\Roaming\Microsoft\Network\Connections\Pbk\" -ChildPath "rasphone_$(Get-Date -Format FileDateTime).bak"
$UserRasphonePath2 = "C:\Users\$RasphoneUsername\AppData\Roaming\Microsoft\Network\Connections\Pbk\_hiddenPbk\rasphone.pbk"
$UserRasphoneBackupPath2 = Join-Path "C:\Users\$RasphoneUsername\AppData\Roaming\Microsoft\Network\Connections\Pbk\_hiddenPbk\" -ChildPath "rasphone_$(Get-Date -Format FileDateTime).bak"



#Functions ============================================================================================================
Function New-RegistryValue
{
    [CmdletBinding()]
    param(   
        [String][parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$DetectionRegKey,
        [String][parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$Name,
        [String][parameter(Mandatory=$true)][ValidateSet('String','ExpandString','Binary','DWord','MultiString','Qword','Unknown')]$PropertyType,
        [String][parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$Value
    )
        
    #Create the registry key if it does not exist
    if(!(Test-Path $DetectionRegKey))
    {
        try{New-Item -Path $DetectionRegKey -Force | Out-Null}
        catch{throw "Failed to create $DetectionRegKey"}
    }

    #Create the registry value
    try
    {
        New-ItemProperty -Path $DetectionRegKey -Name $Name -PropertyType $PropertyType -Value $Value -Force | Out-Null
    }
    catch
    {
        Write-LogEntry -Value "Failed to set $DetectionRegKey\$Name to $Value" -Severity 3
        throw "Failed to set $DetectionRegKey\$Name to $Value"
    }

    #Check if the registry value was successfully created
    $KeyCheck = Get-ItemProperty $DetectionRegKey
    if($KeyCheck.$Name -eq $Value)
    {
        Write-LogEntry -Value "Successfully set $DetectionRegKey\$Name to $Value" -Severity 1
    }
    else
    {
        Write-LogEntry -Value "Failed to set $DetectionRegKey\$Name to $Value" -Severity 3
        throw "Failed to set $DetectionRegKey\$Name to $Value"
    }
}

#Write data to a CMTrace compatible log file. (Credit to SCConfigMgr - https://www.scconfigmgr.com/)
Function Write-LogEntry
{
	param(
		[parameter(Mandatory = $true, HelpMessage = "Value added to the log file.")]
		[ValidateNotNullOrEmpty()]
		[string]$Value,
		[parameter(Mandatory = $true, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
		[ValidateNotNullOrEmpty()]
		[ValidateSet("1", "2", "3")]
		[string]$Severity,
		[parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
		[ValidateNotNullOrEmpty()]
		[string]$FileName = "Install-AOVPN-UserTunnel.log"
	)
    #Determine log file location
    $LogFilePath = Join-Path -Path $LogsDirectory -ChildPath $FileName
		
    #Construct time stamp for log entry
    if(-not(Test-Path -Path 'variable:global:TimezoneBias'))
    {
        [string]$global:TimezoneBias = [System.TimeZoneInfo]::Local.GetUtcOffset((Get-Date)).TotalMinutes
        if($TimezoneBias -match "^-")
        {
            $TimezoneBias = $TimezoneBias.Replace('-', '+')
        }
        else
        {
            $TimezoneBias = '-' + $TimezoneBias
        }
    }
    $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), $TimezoneBias)
		
    #Construct date for log entry
    $Date = (Get-Date -Format "MM-dd-yyyy")
		
    #Construct context for log entry
    $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
		
    #Construct final log entry
    $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""Install-AOVPN"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"
		
    #Add value to log file
    try
    {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception]
    {
        Write-Warning -Message "Unable to append log entry to $FileName file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}

Function Update-RASPhoneBook {

    [CmdletBinding(SupportsShouldProcess)]

    Param (

        [string]$Path,
        [string]$ProfileName,
        [hashtable]$Settings

    )

    $pattern = "(\[.*\])"
    $c = Get-Content $path -Raw
    $p = [System.Text.RegularExpressions.Regex]::Split($c, $pattern, "IgnoreCase") | Where-Object { $_ }

    # // Create a hashtable of VPN profiles
    Write-LogEntry -Value "Initializing a hashtable for VPN profiles from $path..." -Severity 1
    $profHash = [ordered]@{}

    For ($i = 0; $i -lt $p.count; $i += 2) {

        Write-LogEntry -Value "Adding $($p[$i]) to VPN profile hashtable..." -Severity 1
        $profhash.Add($p[$i], $p[$i + 1])

    }

    # // An array to hold changed values for -Passthru
    $pass = @()

    Write-LogEntry -Value "Found the following VPN profiles: $($profhash.keys -join ',')." -Severity 1

    $compare = "[$Profilename]"
    
    Write-LogEntry -Value "Searching for VPN profile $compare..." -Severity 1
    # // Need to make sure to get the exact profile
    $SelectedProfile = $profHash.GetEnumerator() | Where-Object { $_.name -eq $compare }

    If ($SelectedProfile) {

        Write-LogEntry -Value "Updating $($SelectedProfile.key)" -Severity 1
        $pass += $SelectedProfile.key

        $Settings.GetEnumerator() | ForEach-Object {

            $SettingName = $_.name
            Write-LogEntry -Value "Searching for setting $Settingname..." -Severity 1
            $Value = $_.Value
            $thisName = "$SettingName=.*\s?`n"
            $thatName = "$SettingName=$value`n"
            If ($SelectedProfile.Value -match $thisName) {

                Write-LogEntry -Value "Setting $SettingName = $Value." -Severity 1
                $SelectedProfile.value = $SelectedProfile.value -replace $thisName, $thatName
                $pass += ($ThatName).TrimEnd()
                # // Set a flag indicating the file should be updated
                $ChangeMade = $True

            }

            Else {

                Write-LogEntry -Value "Could not find an entry for $SettingName under [$($SelectedProfile.key)]." -Severity 2

            }

        } #ForEach setting

        If ($ChangeMade) {

            # // Update the VPN profile hashtable
            $profhash[$Selectedprofile.key] = $Selectedprofile.value

        }

    } #If found

    Else {

        Write-LogEntry -Value "VPN Profile [$profilename] not found." -Severity 2

    }

    # // Only update the file if changes were made
    If (($ChangeMade) -AND ($pscmdlet.ShouldProcess($path, "Update RAS PhoneBook"))) {

        Write-LogEntry -Value "Updating $Path" -Severity 1
        $output = $profHash.Keys | ForEach-Object { $_ ; ($profhash[$_] | Out-String).trim(); "`n" }
        $output | Out-File -FilePath $Path -Encoding ascii

    } #Whatif

} #close function

#Main Program =========================================================================================================

#Create the log directory
if(!(Test-Path -PathType Container $LogsDirectory))
{
    New-Item -Path $LogsDirectory -ItemType "Directory" -Force | Out-Null
}

Write-LogEntry -Value "START - Always On VPN User Tunnel Script" -Severity 1

#Import the Profile XML
Write-LogEntry -Value "Import the user profile XML" -Severity 1
$ProfileXML = Get-Content $xmlFilePath

#Escape spaces in the profile name
$ProfileNameEscaped = $ProfileName -replace ' ', '%20'
$ProfileXML = $ProfileXML -replace '<', '&lt;'
$ProfileXML = $ProfileXML -replace '>', '&gt;'
$ProfileXML = $ProfileXML -replace '"', '&quot;'

#OMA URI information
$NodeCSPURI = './Vendor/MSFT/VPNv2'
$NamespaceName = 'root\cimv2\mdm\dmmap'
$ClassName = 'MDM_VPNv2_01'

#Get the SID of the current user
try
{
    Write-LogEntry -Value "Find the SID of the currently logged on user" -Severity 1
    $Username = Get-WmiObject -Class Win32_ComputerSystem | Select-Object username
    $User = New-Object System.Security.Principal.NTAccount($Username.Username)
    $Sid = $User.Translate([System.Security.Principal.SecurityIdentifier])
    $SidValue = $Sid.Value
}
catch [Exception]
{
    $ErrorMessage = "Unable to get user SID. User may be logged on over Remote Desktop: $_"
    Write-LogEntry -Value $ErrorMessage -Severity 3
    throw $ErrorMessage
}
Write-LogEntry -Value "Successfully found the user SID: $SidValue ($User)" -Severity 1

#Create a new CimSession
$Session = New-CimSession
$Options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions
$Options.SetCustomOption('PolicyPlatformContext_PrincipalContext_Type', 'PolicyPlatform_UserContext', $false)
$Options.SetCustomOption('PolicyPlatformContext_PrincipalContext_Id', "$SidValue", $false)


# // Backup rasphone.pbk if it exists
If ((Test-Path $UserRasphonePath1)) {

    Write-LogEntry -Value "Backing up existing rasphone.pbk file to $UserRasphoneBackupPath1..." -Severity 1
    Copy-Item $UserRasphonePath1 $UserRasphoneBackupPath1

}

# // Backup hidden rasphone.pbk if it exists
If ((Test-Path $UserRasphonePath2)) {

    Write-LogEntry -Value "Backing up existing rasphone.pbk file to $UserRasphoneBackupPath2..." -Severity 1
    Copy-Item $UserRasphonePath2 $UserRasphoneBackupPath2

}

#Remove previous versions of the user tunnel
try
{
    Write-LogEntry -Value "Check for and remove old instances of the user tunnel" -Severity 1
	$DeleteInstances = $Session.EnumerateInstances($NamespaceName, $ClassName, $Options)
	foreach($DeleteInstance in $DeleteInstances)
	{
		$InstanceId = $DeleteInstance.InstanceID
		if($InstanceId -eq $ProfileNameEscaped)
		{
			$Session.DeleteInstance($NamespaceName, $DeleteInstance, $Options)
            Write-LogEntry -Value "Removed $ProfileName profile $InstanceId" -Severity 1
		}
		else
		{
            Write-LogEntry -Value "Ignoring existing VPN profile $InstanceId" -Severity 2
		}
	}
}
catch [Exception]
{
    $ErrorMessage = "Unable to remove existing outdated instance(s) of $ProfileName profile: $_"
    Write-LogEntry -Value $ErrorMessage -Severity 3
	throw $ErrorMessage
}

#Create the user tunnel
$Error.Clear()
try
{
    Write-LogEntry -Value "Construct a new CimInstance object" -Severity 1
    $NewInstance = New-Object Microsoft.Management.Infrastructure.CimInstance $ClassName, $NamespaceName
    $Property = [Microsoft.Management.Infrastructure.CimProperty]::Create('ParentID', "$nodeCSPURI", 'String', 'Key')
    $NewInstance.CimInstanceProperties.Add($Property)
    $Property = [Microsoft.Management.Infrastructure.CimProperty]::Create('InstanceID', "$ProfileNameEscaped", 'String', 'Key')
    $NewInstance.CimInstanceProperties.Add($Property)
    $Property = [Microsoft.Management.Infrastructure.CimProperty]::Create('ProfileXML', "$ProfileXML", 'String', 'Property')
    $NewInstance.CimInstanceProperties.Add($Property)
    Write-LogEntry -Value "Create the new user tunnel" -Severity 1
    $Session.CreateInstance($NamespaceName, $NewInstance, $Options)
    Write-LogEntry -Value "Always On VPN user tunnel ""$ProfileName"" created successfully." -Severity 1
}
catch [Exception]
{
    $ErrorMessage = "Unable to create ""$ProfileName"" profile: $_"
    Write-LogEntry -Value $ErrorMessage -Severity 3
    throw $ErrorMessage
}
Write-LogEntry -Value "Successfully created the new user tunnel" -Severity 1

# // Update Rasphone.pbk

# // Create empty VPN profile settings hashtable
$Settings = @{ }

# // Set IPv4 and IPv6 interface metrics to ensure VPN connection has priority over Ethernet connections
$Settings.Add('IpInterfaceMetric', $InterfaceMetric)
$Settings.Add('Ipv6InterfaceMetric', $InterfaceMetric)

Update-RasphoneBook -Path $UserRasphonePath1 -ProfileName $ProfileName -Settings $Settings

#Create a registry key for detection
if(!($Error))
{
    Write-LogEntry -Value "Create the registry key to use for the detection method" -Severity 1
    New-PSDrive -PSProvider registry -Root HKEY_USERS -Name HKU
    New-RegistryValue -DetectionRegKey "HKU:\$($SidValue)\$($DetectionRegKey)" -Name $DetectionRegValue -PropertyType String -Value $UserTunnelVersion
    Remove-PSDrive -Name HKU
}

Write-LogEntry -Value "END - Always On VPN User Tunnel Script" -Severity 1