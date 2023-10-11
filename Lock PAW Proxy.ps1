#Enable proxy
Set-ItemProperty -Path $regPath -Name "ProxyEnable" -Value 1
Set-ItemProperty -Path $regPath -Name "ProxyServer" -Value "127.0.0.2:8080"
Set-ItemProperty -Path $regPath -Name "ProxyOverride" -Value "*.GitHub;*.azure.com;*.azure.net;*.microsoft.com;*.windowsupdate.com;*.microsoftonline.com;*.microsoftonline.cn;*.windows.net;*.windowsazure.com;*.windowsazure.cn;*.azure.cn;*.loganalytics.io;*.applicationinsights.io;*.vsassets.io;*.azure-automation.net;*.visualstudio.com,portal.office.com;*.aspnetcdn.com;*.sharepointonline.com;*.msecnd.net;*.msocdn.com;*.webtrends.com"
Set-ItemProperty -Path $regPath -Name "AutoDetect" -Value 0