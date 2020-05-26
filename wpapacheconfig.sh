#!/bin/bash
# Author: Vishal Dilip Sanghi
# Apache configuration for Wordpress Install on a Debian/Ubuntu VPS
# Created on: 25th May 2020
# Last Updated on: 25th May 2020
source config.sh

certbotinstall() {
	echo "====================================="
	echo "Cerbot Installation Operation Started"
	echo "====================================="
	# Install Cerbot Command
	wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto
	echo
	echo "**Certbot Install Operation Completed**"
	echo
	# Moving cerbot auto to letsencrypt directory
	mv certbot-auto $LENCRYPTPATH/
	echo
	echo "**Moved Cerbot-auto to $LENCRYPTPATH**"
	echo
	echo "==========================="
	echo "Finished Installing Certbot"
	echo "==========================="
	echo
}

wpcliinstall() {
        echo "===================================="
        echo "Please wait while we install wp-cli"
        echo "===================================="
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        cp wp-cli.phar /usr/bin/wp
        echo "=========================="
        echo "Finished installing wp-cli"
        echo "=========================="
        echo
}

cerbotcertgenerate() {
	# Checking whether the DOMAIN folder exists at certification path
	if [ -d "$CERTDIR" ]
	then
		# Exists condition then directly configure the apache to run the website
		echo "=========================================="
		echo "Certificate Exists Skipping the Generation"
		echo "=========================================="
		echo
		configureapachessl
	else
		# Not exists condition then generate certificate and then configure the apache to run the website
		echo "=============================="
		echo "Certificate Generation Started"
		echo "=============================="
		echo
		echo "**Certficate does not exists generating certficate via Certbot**"
		echo
		# Command to generate the certificate for the DOMAIN with installation path
		certdetails=$(sudo $LENCRYPTPATH/certbot-auto certonly --webroot -w $WPPATH/ -d $DOMAIN)
		echo
		echo "**Certficate Generated for $DOMAIN**"
		# Command to paste details of certificate generation into a file that is moved to installation folder for reference 
		sudo echo "$certdetails" > "$WPPATH/certdetails.txt"
		echo
		echo "**Certficate Details stored at $WPPATH/certdetails.txt**"
		echo
		echo "================================"
		echo "Certificate Generation Completed"
		echo "================================"
		configureapachessl
	fi
}

cerbotcertrenew() {
	echo "**Checking if the renewal entry exists**"
	# Command to check the string of certbot auto if exists in the corntab file and echo the result
	echo
	grep -q "certbot-auto renew" "$CRONTABFILEPATH"; [ $? -eq 0 ] && echo "**Cronjob Entry Exists**" || echo "**Cronjob Entry does not Exists**"
	echo
	echo "=================================="
	echo "Auto Renewal Configuration Started"
	echo "=================================="
	# Command to check the string of certbot auto if exists in the corntab file and then take actions
	if grep -q "certbot-auto renew" "$CRONTABFILEPATH"; 
	then
		echo
		# Exists condition then do nothing just list the cronjobs for user
		echo "**Auto-renewal is already scheduled in a cronjob**"
		# list the cronjobs for user
		# crontab -l
		grep ^[^#] $CRONTABFILEPATH
	else
		# Not exists condition then schedule a cronjob to auto renew 3:45 AM Every Saturday (can be changed as needed)
		# Schedule format MIN HOUR DOM MON DOW CMD what you have in below command 45 3 * * 6 <command>
		sudo crontab -l | { cat; echo "45 3 * * 6 $LENCRYPTPATH/certbot-auto renew --cert-name $DOMAIN && /etc/init.d/apache2 restart"; } | crontab -
		echo
		echo "**Auto-renewal is already scheduled in a cronjob**"
		# list the cronjobs for user
		# crontab -l
		grep ^[^#] $CRONTABFILEPATH
	fi
	echo
	echo "===================================="
	echo "Auto Renewal Configuration Completed"
	echo "===================================="
	
	# Use the below command if you want to manually renew the specific DOMAIN do a dry run if all ok then remove --dry-run. 
	# Always check if you are running cerbot in right directory as per your machine installation and configuration
	# /etc/letsencrypt/certbot-auto renew --cert-name <your-DOMAIN> --dry-run && /etc/init.d/apache2 restart
	
	# Use the below command if you want to manually renew the specific DOMAIN do a dry run if all ok then remove --dry-run
	# Always check if you are running cerbot in right directory as per your machine installation and configuration
	# /etc/letsencrypt/certbot-auto renew && /etc/init.d/apache2 restart
}

configureapache() {
	echo
	echo "============================"
	echo "Apache Configuration Started"
	echo "============================"
	echo
	# Command to remove the symbolic link between if already exists. You can comment if you don't need this.
	a2dissite $DOMAIN.conf
	echo
	echo "**Removed Symbolic Link for $DOMAIN.conf**"
	
	# Command to remove the current apache conf file for your DOMAIN if already exists. You can comment if you don't need this.
	rm -r $SITEAVAILABLEPATH/$DOMAIN.conf
	echo
	echo "**Removed Apache conf file for $DOMAIN.conf**"
	
	# Restarting Apache Service to see the changes.
	systemctl reload apache2
	echo
	echo "**Restarted Apache Service**"
	
	# Copying the wpapache conf with your DOMAIN name in sites-available.
	cp wpapache.conf wpapache_temp.conf
	echo
	echo "**Created temp standard conf file**"
	
	# Using sed command to replace the content in default conf file. It will replace all the instances of WPPATH to the value you mentioned.
	sudo sed -i "s|WPPATH|$WPPATH|g" wpapache.conf
	sudo sed -i "s|WPDOMAIN|$DOMAIN|g" wpapache.conf
	echo
	echo "**Replaced content to the required conf file **"
	
	# Copying conf file to sites available folder
	cp wpapache.conf $DOMAIN.conf
	mv $DOMAIN.conf $SITEAVAILABLEPATH/
	echo
	echo "**Copied the apache conf file of your DOMAIN to siteavailable path $SITEAVAILABLEPATH**"
	
	# Resetting the standard file of script
	mv wpapache_temp.conf wpapache.conf
	echo
	echo "**Standard apache conf file reset done**"
	
	# Command to add the symbolic link between your DOMAIN and sites-enabled.
	echo
	a2ensite $DOMAIN.conf
	echo
	echo "**Created Symbolic Link for $DOMAIN.conf**"
	
	# Restarting Apache Service to see the changes.
	systemctl reload apache2
	echo
	echo "**Restarted Apache Service**"
	echo
	echo "=============================="
	echo "Apache Configuration Completed"
	echo "=============================="
	echo
}


configureapachessl() {
	echo
	echo "====================================="
	echo "Apache SSL Configuration Started"
	echo "====================================="
	echo
	# Copying the wpapache conf with your DOMAIN name in sites-available.
	cp wpapachessl.conf wpapachessl_temp.conf
	echo "**Created temp standard conf file**"
	
	# Using sed command to replace the content in default conf file. It will replace all the instances of WPPATH to the value you mentioned.
	sed -i "s|WPPATH|$WPPATH|g" wpapachessl.conf
	sed -i "s|WPDOMAIN|$DOMAIN|g" wpapachessl.conf
	echo
	echo "**Replaced content to the required conf file **"
	
	# Copying conf file to sites available folder
	cp wpapachessl.conf $DOMAIN.conf
	mv $DOMAIN.conf $SITEAVAILABLEPATH/
	echo
	echo "**Copied the apache conf file of your DOMAIN to siteavailable path $SITEAVAILABLEPATH**"
	
	# Resetting the standard file of script
	mv wpapachessl_temp.conf wpapachessl.conf
	echo
	echo "**Standard apache conf file reset done**"
			
	# Restarting Apache Service to see the changes.
	systemctl reload apache2
	echo
	echo "**Restarted Apache Service**"
	echo
	if [ -f "$WPCLI" ]
	then
		# Exists condition continue to update the wordpress home and site URL
		wp option update home 'https://$DOMAIN' --path=$WPPATH --allow-root
		wp option update siteurl 'https://$DOMAIN' --path=$WPPATH --allow-root
		echo "Wordpress URL sucessfully updated to https"
	else
		# Not exists condition install WPCLI and continue to update the wordpress home and site URL
		wpcliinstall
		wp option update home 'https://$DOMAIN' --path=$WPPATH --allow-root
		wp option update siteurl 'https://$DOMAIN' --path=$WPPATH --allow-root
		echo "Wordpress URL sucessfully updated to https"
	fi
	echo
	echo "=================================="
	echo "Apache SSL Configuration Completed"
	echo "=================================="
	echo
}

# Starting the Apache Configuration Script
	echo
	echo "======================================="
	echo "Choose Option for Apache Configuration:"
	echo "======================================="
	echo
	echo "1. Setup Website with SSL"
	echo "2. Setup Website without SSL"
	echo
	read -p "Choose install method: " install_method
	if [ "$install_method" == 1 ]
	then
		if [ -f "$CERTFILE" ]
		then
			echo
			echo "===================================================="
			echo "Certbot file exists at $CERTFILE"
			echo "===================================================="
			echo
			configureapache
			cerbotcertgenerate
			cerbotcertrenew
		else
			echo
			echo "============================================================="
			echo "Certbot file does not exists at $CERTFILE"
			echo "============================================================="
			echo
			certbotinstall
			configureapache
			cerbotcertgenerate
			cerbotcertrenew
		fi
	else
		configureapache
	fi

