Import-Csv c:\scripts\MBAe\upn.csv | ForEach-Object {
    Set-MsolUserPrincipalNAme -UserPrincipalName $_.OldUPN -NewUserPrincipalName $_.NewUPN
    }

