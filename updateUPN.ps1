Import-Csv c:\scripts\upn.csv | ForEach-Object {
    Set-MsolUserPrincipalNAme -UserPrincipalName $_.OldUPN -NewUserPrincipalName $_.NewUPN
    }

