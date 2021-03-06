#!/usr/bin/env bash

set -ex

apt-get update

# Check arguments
#
# Default values
reinstall='';
with_sample_data='';
deploy_static_view_files='';
for var in "$@"
do
    if [ "${var}" == "reinstall" ]; then
        reinstall=true;
    fi
    if [ "${var}" == "with_sample_data" ]; then
        with_sample_data=true;
    fi
    if [ "${var}" == "deploy_static_view_files" ]; then
        deploy_static_view_files=true;
    fi
done

# Determine external IP address
set +x
IP=`ifconfig eth1 | grep inet | awk '{print $2}' | sed 's/addr://'`
echo "IP address is '${IP}'"
set -x

# Determine hostname for Magento web-site
HOST=`hostname -f`
if [ -z ${HOST} ]; then
    # Use external IP address as hostname
    set +x
    HOST=${IP}
    echo "Use IP address '${HOST}' as hostname"
    set -x
fi

# Setup Apache
apt-get install -y apache2
a2enmod rewrite
apache_config="/etc/apache2/sites-available/magento2.conf"
cp /vagrant/magento2.vhost.conf ${apache_config}
sed -i "s/<host>/${HOST}/g" ${apache_config}
# Enable Magento virtual host
a2ensite magento2.conf
# Disable default virtual host
sudo a2dissite 000-default

# Setup PHP
apt-get install -y php5 php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-xsl curl
if [ ! -f /etc/php5/apache2/conf.d/20-mcrypt.ini ]; then
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
fi
if [ ! -f /etc/php5/cli/conf.d/20-mcrypt.ini ]; then
    ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
fi
echo "date.timezone = America/Chicago" >> /etc/php5/cli/php.ini

# Restart Apache
service apache2 restart

# Setup MySQL
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
apt-get install -q -y mysql-server-5.6 mysql-client-5.6

# Setup Composer
apt-get install -y git
if [ ! -f /usr/local/bin/composer ]; then
    cd /tmp
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi
github_token="/vagrant/local.config/github.oauth.token"
if [ -f ${github_token} ]; then
    set +x
    echo "Installing GitHub OAuth token from ${github_token}..."
    composer config -g github-oauth.github.com `cat ${github_token}`
    set -x
fi

# Install Magento code base
# Create Magento root dir
magento_dir="/var/www/magento2"
if [ ! -d ${magento_dir} ] || [ ${reinstall} ]; then
	# Create DB
	db_name="magento"
    if [ ${reinstall} ]; then
        mysql -u root -ppassword -e "drop database if exists ${db_name}; create database ${db_name};"
    else
    	mysql -u root -ppassword -e "create database if not exists ${db_name};"
    fi
	mysql -u root -ppassword -e "GRANT ALL ON ${db_name}.* TO magento@localhost IDENTIFIED BY 'magento';"

    if [ -d ${magento_dir} ]; then
        rm -rf ${magento_dir}
    fi
	mkdir ${magento_dir}
	cd ${magento_dir}
	if [ ${with_sample_data} ]; then
	    composer create-project --stability=beta --no-install magento/project-community-edition .
		composer require "magento/sample-data":"*"
	else
		composer create-project --stability=beta magento/project-community-edition .
	fi

    chmod +x bin/magento

	# Install Magento application
	install_cmd="./bin/magento setup:install \
		--db-host=localhost \
		--db-name=magento \
		--db-user=magento \
		--db-password=magento \
		--backend-frontname=admin \
		--base-url=http://${HOST}/ \
		--language=en_US \
		--timezone=America/Chicago \
		--currency=USD \
		--admin-lastname=Admin \
		--admin-firstname=Admin \
		--admin-email=admin@example.com \
		--admin-user=admin \
		--admin-password=1amtheadmin"

	if [ ${with_sample_data} ]; then
		install_cmd="${install_cmd} --use-sample-data"
	fi

	eval ${install_cmd}

	chown -R www-data:www-data .

	# Deploy static view files for better performance
	if [ ${deploy_static_view_files} ]; then
		./bin/magento setup:static-content:deploy
	fi
fi

set +x
echo "Installed Magento application in ${magento_dir}"
echo "Access front-end at http://${HOST}/"
echo "Access back-end at http://${HOST}/admin/"
if [ ${HOST} != ${IP} ]; then
    echo "Don't forget to update your 'hosts' file with '${IP} ${HOST}'"
fi
