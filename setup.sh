#!/bin/bash

set -eu

### Common Settings ###
sudo timedatectl set-timezone Asia/Tokyo
sudo localectl set-locale LANG=ja_JP.utf8


### nmap ###
sudo yum -y install nmap
nmap localhost


### Apache ###
sudo yum -y install httpd
sudo sed -i -e "/\/var\/www\/html/s/\/var\/www\/html/\/vagrant\/html/g" /etc/httpd/conf/httpd.conf

### SSL Module (If necessary) ###
# sudo yum -y install mod_ssl

### WAF Module (If necessary) ###
# sudo yum -y install mod_security


### PHP7.1 ###
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

sudo yum -y install --enablerepo=remi,remi-php71 php php-devel php-common php-cli php-pear php-pdo php-mysqlnd php-opcache php-gd php-mbstring php-mcrypt php-xml php-fpm

sudo sed -i -e "s|;error_log = syslog|error_log = /var/log/php.log|" /etc/php.ini
sudo sed -i -e "s|;date.timezone =|date.timezone = Asia/Tokyo|" /etc/php.ini

sudo sed -i -e "s|        SetHandler application/x-httpd-php|        SetHandler \"proxy:fcgi://127.0.0.1:9000\"|" /etc/httpd/conf.d/php.conf
sudo sed -i -e "s|DirectoryIndex index.php|DirectoryIndex index.php index.html|" /etc/httpd/conf.d/php.conf

sudo sed -i -e "/^ /s/php_value session.save_handler/#php_value session.save_handler/g" /etc/httpd/conf.d/php.conf
sudo sed -i -e "/^ /s/php_value session.save_path/#php_value session.save_path/g" /etc/httpd/conf.d/php.conf
sudo sed -i -e "/^ /s/php_value soap.wsdl_cache_dir/#php_value soap.wsdl_cache_dir/g" /etc/httpd/conf.d/php.conf


### MariaDB ###
sudo chown root. /tmp/MariaDB.repo
sudo mv /tmp/MariaDB.repo /etc/yum.repos.d/
sudo yum -y install MariaDB-server MariaDB-client

### It is necessary to manually installation ###
# mysql_secure_installation


### git ###
yum -y install gcc openssl-devel perl-ExtUtils-MakeMaker

cd /usr/local/src
wget https://www.kernel.org/pub/software/scm/git/git-2.14.1.tar.gz
tar zxvf git-2.14.1.tar.gz
cd git-2.14.1/

./configure
make
make install

sudo sed -i -e "8a PATH=/usr/local/bin:\$PATH:\$HOME/.local/bin:\$HOME/bin" /root/.bashrc
sudo sed -i -e "9a export PATH" /root/.bashrc
sudo sed -i -e "s|PATH=\$PATH:\$HOME/bin|PATH=/usr/local/bin:\$PATH:\$HOME/bin|" /root/.bash_profile


### Node.js ###
sudo rpm -Uvh https://kojipkgs.fedoraproject.org//packages/http-parser/2.7.1/3.el7/x86_64/http-parser-2.7.1-3.el7.x86_64.rpm
sudo yum -y install nodejs npm

npm i -g n
n stable
npm i -g gulp


### Startup ###
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo systemctl start httpd
sudo systemctl enable httpd

sudo systemctl start php-fpm
sudo systemctl enable php-fpm

sudo systemctl start firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --add-service=http --zone=public --permanent
sudo firewall-cmd --add-service=https --zone=public --permanent
sudo firewall-cmd --reload

### XDebug ###
sudo su

pecl channel-update pecl.php.net
pecl install xdebug
chmod 755 /usr/lib64/php/modules/xdebug.so

echo 'zend_extension=/usr/lib64/php/modules/xdebug.so' >> /etc/php.ini
echo 'xdebug.remote_enable=on' >> /etc/php.ini
echo 'xdebug.remote_autostart=on' >> /etc/php.ini
echo 'xdebug.remote_handler=dbgp' >> /etc/php.ini
echo 'xdebug.remote_host=192.168.33.1' >> /etc/php.ini
echo 'xdebug.remote_port=9001' >> /etc/php.ini
echo 'xdebug.idekey="phpstorm"' >> /etc/php.ini

systemctl restart httpd
systemctl restart php-fpm

