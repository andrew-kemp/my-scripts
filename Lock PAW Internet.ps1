[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings]
"ProxyEnable"=dword:00000001
"ProxyServer"="127.0.0.2:8080"
"ProxyOverride"="*.azure.com;*.azure.net;*.microsoft.com;*.windowsupdate.com;*.microsoftonline.com;*.microsoftonline.cn;*.windows.net;*.windowsazure.com;*.windowsazure.cn;*.azure.cn;*.loganalytics.io;*.applicationinsights.io;*.vsassets.io;*.azure-automation.net;*.visualstudio.com,portal.office.com;*.aspnetcdn.com;*.sharepointonline.com;*.msecnd.net;*.msocdn.com;*.webtrends.com"
"AutoDetect"=dword:00000000

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

#Enable proxy
Set-ItemProperty -Path $regPath -Name "ProxyEnable" -Value 1
Set-ItemProperty -Path $regPath -Name "ProxyServer" -Value "127.0.0.2:8080"
Set-ItemProperty -Path $regPath -Name "ProxyOverride" -Value "*.GitHub;*.azure.com;*.azure.net;*.microsoft.com;*.windowsupdate.com;*.microsoftonline.com;*.microsoftonline.cn;*.windows.net;*.windowsazure.com;*.windowsazure.cn;*.azure.cn;*.loganalytics.io;*.applicationinsights.io;*.vsassets.io;*.azure-automation.net;*.visualstudio.com,portal.office.com;*.aspnetcdn.com;*.sharepointonline.com;*.msecnd.net;*.msocdn.com;*.webtrends.com"
Set-ItemProperty -Path $regPath -Name "AutoDetect" -Value 0


# Set the location to the registry
Set-Location -Path 'HKLM:\Software\Microsoft'

New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name

# Create a new Key
Get-Item -Path 'HKLM:\Software\Microsoft' | New-Item -Name 'W10MigInfo\Diskspace Info' -Force

# Create new items with values
New-ItemProperty -Path 'HKLM:\Software\Microsoft\W10MigInfo\Diskspace Info' -Name 'usedDiskspaceCDrive' -Value "$usedDiskspaceCDrive" -PropertyType String -Force
New-ItemProperty -Path 'HKLM:\Software\Microsoft\W10MigInfo\Diskspace Info' -Name 'usedDiskSpaceDDrive' -Value "$usedDiskspaceDDrive" -PropertyType String -Force