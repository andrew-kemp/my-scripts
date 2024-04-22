sudo apt-get install apache2 php libsasl2-modules libapache2-mod-php php-gd mariadb-server mariadb-client php-mysql mailutils
sudo a2enmod ssl rewrite
sudo mysql_secure_installation 




sudo mkdir -p /var/www/www.andykemp.com
sudo chown -R $USER:$USER /var/www/www.andykemp.com
sudo chmod -R 755 /var/www 
sudo chmod 757 /var/www/www.andykemp.com
sudo chmod 757 /var/www/www.andykemp.com

wget -c http://wordpress.org/latest.tar.gz 
tar -xzvf latest.tar.gz 
sudo rsync -av wordpress/* /var/www/www.andykemp.com


sudo nano /etc/apache2/sites-available/www.andykemp.com.conf  




<VirtualHost *:80>  
ServerName www.andykemp.com  
ServerAlias andykemp.com  
Redirect / https://www.andykemp.com  
</VirtualHost>  
<VirtualHost _Default_:443>  
ServerAdmin admin@andykemp.com  
DocumentRoot /var/www/www.andykemp.com  
ServerName www.andykemp.com  
ServerAlias andykemp.com  
SSLEngine on  
SSLCertificateFile /var/cert/andykemp.crt  
SSLCertificateKeyFile /var/cert/andykemp.key  
SSLCACertificateFile /var/cert/DigiCertCA.crt  
<Directory /var/www/www.andykemp.com/>  
AllowOverride All  
</Directory> 
</VirtualHost> 


sudo mysql 
CREATE DATABASE db_andykemp; 
CREATE USER user_andykemp@localhost IDENTIFIED BY '32Ldd9^r%$£%$^vv783E&sKSg3e'; 
GRANT ALL PRIVILEGES ON db_andykemp.* TO user_andykemp@localhost; 
FLUSH PRIVILEGES; 
