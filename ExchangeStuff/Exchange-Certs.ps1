#Set all the details for the request
#Ensure Script Execution is set to RemoteSigned (Set-ExecutionPolicy RemoteSigned)
$ExchServer = "dev-ex"
$Domain = "ad.andykemp.dev"
$ExchFQDN = "$ExchServer.$Domain"
Write-Host  $ExchFQDN
$Server = "akdev-mw"
$sharedFolder = "cert"
$path = "\\" + $Server + "\" + $sharedFolder
$FriendlyName = "Andy Kemp Dev Cert"
$certdomain = "*.andykemp.dev"

#Get the Creds for Exchange 
$SourceCred = Get-Credential -Message "Please enter Exchange Admin Credentials"

#Get the URI for the source Exchange Management Shell
$sourceExURI = "http://" + $ExchFQDN + "/PowerShell/"
Write-Host "Connecting to source Exchange Server URI: $sourceExURI"  

#Conenct to source Exchange Environment
$SourceSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $sourceExURI -Authentication Kerberos -Credential $SourceCred
Import-PSSession $SourceSession

#Create the Certificate
$csr = New-ExchangeCertificate -Server $ExchServer -GenerateRequest -FriendlyName $FriendlyName -PrivateKeyExportable $true -SubjectName "c=Edinburgh, o=Andy Kemp Dev, ou=IT Exchange, cn = $certdomain"
[System.IO.File]::WriteAllBytes("$path\$ExchServer.req", [System.Text.Encoding]::Unicode.GetBytes($csr))

#Send the CSR off to get a certificate from public CA.

#Import the verified Cert from the public CA
$crt = Read-Host "What is the name of the returned crt form the Certificate Authority? (you do not need to add the crt extension)"
Import-ExchangeCertificate -FileData ([System.IO.File]::ReadAllBytes("$Path\$crt.cer")) -PrivateKeyExportable:$true -Password (ConvertTo-SecureString -String 'P@ssw0rd1' -AsPlainText -Force)
