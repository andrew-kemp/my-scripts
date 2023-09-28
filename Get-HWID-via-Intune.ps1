#Script to collect HWID for Windows AutoPilot preperation
#This will collect the data and then upload to Azure Blob Storage
#then clean up the HWID folder
#Created by Andrew Kemp
#andrew@kemponline.co.uk
#Created on 10th April 2023
#version 1.0

#Setup the basics: Folder, Path etc...
New-Item -Type Directory -Path "C:\HWID"
Set-Location -Path "C:\HWID"
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned


#Install NuGet and the Get-AutoPilotInfo scrript
Install-PackageProvider -Name NuGet -Force
Install-Script -Name Get-WindowsAutoPilotInfo -force


#Download  and install AzCopy 
Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing   
#Curl.exe option (Windows 10 Spring 2018 Update (or later)) 
curl.exe -L -o AzCopy.zip https://aka.ms/downloadazcopy-v10-windows   
#Expand Archive 
Expand-Archive ./AzCopy.zip ./AzCopy -Force   
#Move AzCopy to the destination you want to store it 
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination "C:\HWID\AzCopy.exe"   
#Add your AzCopy path to the Windows environment PATH  
$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User") 
[System.Environment]::SetEnvironmentVariable("PATH", $userenv + ";C:\HWID\AzCopy", "User")


#Get the Hardware ID:
Get-WindowsAutopilotInfo -OutputFile "$env:COMPUTERNAME.csv"
#Copy the CSV to Azure Blob Storage
#blob sas url will be specific and will be only valid for a certain amount of time.
.\azcopy.exe copy "c:\HWID\$env:COMPUTERNAME.csv" "https://mystorage.blob.core.windows.net/autopilot?sp=rw&st=2023-04-10T13:30:52Z&se=2023-08-30T21:30:52Z&spr=https&sv=2021-12-02&sr=c&sig=0A8QGSprlAQJH%2B0cMZdwRL%2Fasdwerwfds45435%$£dfdg" --recursive

#Cleanup
Set-Location -Path "C:\"
Remove-Item -LiteralPath "c:\HWID" -Force -Recurse
Uninstall-Script Get-WindowsAutoPilotInfo