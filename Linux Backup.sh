https://andykempstorage.blob.core.windows.net/website-backup?sp=rw&st=2023-10-13T16:57:44Z&se=2023-10-14T00:57:44Z&spr=https&sv=2022-11-02&sr=c&sig=lMQdcJd9WzNVjhTOMEu33yTPuKZQEQOnJZ96ZGOO1RM%3D

#Backup Webiste, Database and config
#Created by Andrew Kemp
#11th May 2023
#Version 1.0

#Variables
Azure_Blob="https://andykempstorage.blob.core.windows.net/apollo?sp=rw&st=2024-01-10T09:43:48Z&se=2026-05-06T16:43:48Z&spr=https&sv=2022-11-02&sr=c&sig=I2IIgkahZARrCiVZxtZ7%2FRGHU0EW%2B%2F2IAOMn6cODYIg%3D"
Today=$(date +%A)
Web_Config="/etc/apache2/sites-available/andrewkemp.co.uk.conf"
DB_Name="db_andrewkemp"
Postfix_Config="/etc/postfix/main.cf"
SASL_Passwd="/etc/postfix/sasl_passwd"
Temp_Backup="/temp_backup"
Website_Path="/var/www/andrewkemp.co.uk"
Cert_Directory="/var/cert"


#Creat the temp backup folder
mkdir $Temp_Backup

# Create Archive with Website data and config files
tar -cpvzf $Temp_Backup"/"$Today".tar.gz" $Website_Path $Web_Config $Postfix_Config $SASL_Passwd $Cert_Directory

#Backup the Open VPN Access Server config
tar -cpvzf $Temp_Backup"/"$Today"-OpenVPN-AS.tar.gz" /usr/local/openvpn_as/etc/db/config.db /usr/local/openvpn_as/etc/db/certs.db /usr/local/openvpn_as/etc/db/userprop.db /usr/local/openvpn_as/etc/db/log.db /usr/local/openvpn_as/etc/as.conf /usr/local/openvpn_as/etc/db/userprop.db

#Backup the Database
mysqldump $DB_Name > $Temp_Backup"/"$DB_Name"-"$Today".sql"

#Uploaid the files to Azure Blob Storage
echo uploading to Azure
az storage blob upload-batch --destination $Azure_Blob --source $Temp_Backup --overwrite
clear
#Clearing Temp Backup
echo "Removing the local temp files"
rm -r -f $Temp_Backup
echo "Files removed"
echo "Backup has been run" | mail -s "Server Backup" -r wordpress@andrewkemp.co.uk andrew@kemponline.co.uk