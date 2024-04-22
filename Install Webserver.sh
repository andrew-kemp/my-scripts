sudo apt-get install apache2 php libsasl2-modules libapache2-mod-php mariadb-server mariadb-client php-mysql 



sudo mkdir -p /var/www/www.andrewkemp.co.uk 
sudo chown -R $USER:$USER /var/www/www.andrewkemp.co.uk 
sudo chmod -R 755 /var/www 
sudo chmod 757 /var/www/www.andrewkemp.co.uk 
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/andrewkemp.co.uk.conf 

sudo mkdir -p /var/www/www.andykemp.com 
sudo chown -R $USER:$USER /var/www/www.andykemp.com
sudo chmod -R 755 /var/www 
sudo chmod 757 /var/www/www.andykemp.com


sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/andrewkemp.co.uk.conf 


sudo nano /etc/apache2/sites-available/www.andykemp.com.conf 