sudo apt-get install apache2 php libsasl2-modules libapache2-mod-php php-gd mariadb-server mariadb-client php-mysql mailutils
sudo a2enmod ssl rewrite
sudo mysql_secure_installation 




sudo mkdir -p /var/www/andrewkemp.co.uk
sudo chown -R $USER:$USER /var/www/andrewkemp.co.uk
sudo chmod -R 755 /var/www 
sudo chmod 757 /var/www/andrewkemp.co.uk
sudo chmod 757 /var/www/andrewkemp.co.uk

sudo nano /etc/apache2/sites-available/andrewkemp.co.uk.conf  

<VirtualHost *:80>  
ServerName www.andrewkemp.co.uk  
ServerAliasandrewkemp.co.uk  
Redirect / https://www.andrewkemp.co.uk  
</VirtualHost>  
<VirtualHost _Default_:443>  
ServerAdmin admin@andrewkemp.co.uk  
DocumentRoot /var/www/andrewkemp.co.uk  
ServerName www.andrewkemp.co.uk  
ServerAlias andrewkemp.co.uk  
SSLEngine on  
SSLCertificateFile /var/cert/andrewkemp.crt  
SSLCertificateKeyFile /var/cert/andrewkemp.key  
SSLCACertificateFile /var/cert/DigiCertCA.crt  
<Directory /var/www/andrewkemp.co.uk/>  
AllowOverride All  
</Directory> 
</VirtualHost> 



32Ldd9^r%$£%$^vv783E&sKSg3e

sudo mysql 
CREATE DATABASE db_andrewkemp; 
CREATE USER user_andrewkemp@localhost IDENTIFIED BY '32Ldd9^r%$£%$^vv783E&sKSg3e'; 
GRANT ALL PRIVILEGES ON db_andrewkemp.* TO user_andrewkemp@localhost; 
FLUSH PRIVILEGES; 

Exit 



openssl req -new -newkey rsa:2048 -nodes -out andrewkemp.csr -keyout andrewkemp.key -subj "/C=GB/ST=Edinburgh/L=Edinburgh/O=AK Demo Labs/OU=IT/CN=*.andrewkemp.co.uk"

wget -c http://wordpress.org/latest.tar.gz 
tar -xzvf latest.tar.gz 
sudo rsync -av wordpress/* /var/www/andrewkemp.co.uk 


#######
OpenVPN Acccess Server
sudo -s

apt update && apt -y install ca-certificates wget net-tools gnupg
wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main">/etc/apt/sources.list.d/openvpn-as-repo.list
apt update && apt -y install openvpn-as
Exit


Access Server Web UIs are available here:
Admin  UI: https://192.168.1.228:943/admin
Client UI: https://192.168.1.228:943/
To login please use the "openvpn" account with "32Ldd9^r%$£%$^vv783E&sKSg3e" password.
(password can be changed on Admin UI)

###################
Webmin 
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
sh setup-repos.sh

apt-get install --install-recommends webmin


 [i] Pi-hole blocking will be enabled
  [i] Enabling blocking
  [✓] Reloading DNS lists
  [✓] Pi-hole Enabled
  [i] Web Interface password: KBbHYk6X
  [i] This can be changed using 'pihole -a -p'

  [i] View the web interface at http://pi.hole/admin or http://192.168.1.228/admin

  [i] You may now configure your devices to use the Pi-hole as their DNS server
  [i] Pi-hole DNS (IPv4): 192.168.1.228
  [i] If you have not done so already, the above IP should be set to static.

  [i] The install log is located at: /etc/pihole/install.log
  [✓] Installation complete!