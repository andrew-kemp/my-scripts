New-Item -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name IsWVDEnvironment -PropertyType DWORD -Value 1 -Force


New-Item -Path "HKCU:\SOFTWARE\Microsoft\Terminal Server Client\Default" -Force
New-Item -Path "HKCU:\SOFTWARE\Microsoft\Terminal Server Client\Default\AddIns" -Force
New-Item -Path "HKCU:\SOFTWARE\Microsoft\Terminal Server Client\Default\AddIns\WebRTC Redirector" -Force

New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Terminal Server Client\Default\AddIns\WebRTC Redirector" -Name UseHardwareEncoding -PropertyType DWORD -Value 1 -Force

New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\Policy"
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\Policy" -Name ShareClientDesktop -PropertyType DWORD -Value 1 -Force

