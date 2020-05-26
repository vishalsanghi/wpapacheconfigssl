#!/bin/bash
# Author: Vishal Dilip Sanghi
# Apache configuration for Wordpress Install on a Debian/Ubuntu VPS
# Created on: 25th May 2020
# Last Updated on: 25th May 2020

# Your certbot auto file path and name. Ideally keep it the sample path mentioned below.
# Sample - /etc/letsencrypt/certbot-auto
CERTFILE=your-certbotauto-path

# Your letsencrypt path. The letsencrypt issues the SSL certificate for your website by using certbot-auto.
# Sample - /etc/letsencrypt
LENCRYPTPATH=your-letsencrypt-path

# Your domain name to be mentioned here. The wordpress folder name for installation needs to be same. 
# Sample - www.example.com
DOMAIN=<your-domain-name>

# This is the path where your SSL certificates are stored with standard letsencrypt installation.
# Sample - /etc/letsencrypt/live/$DOMAIN
CERTDIR=your-certiridation-path

# This is the wordpress installation path with domain name as the folder name.
# Sample - /var/www/www.example.com
WPPATH=your-wpinstallation-path

# This is the apache sites available path. All the sites in apache will stored in this folder.
# Sample - /etc/apache2/sites-available
SITEAVAILABLEPATH=your-site-available-path

# This is crontab path where your cron jobs are stored. Root in the sample path can be replaced with username.
# Sample - /var/spool/cron/crontabs/root
CRONTABFILEPATH=your-crontab-path

# This is the WPCLI file name.
WPCLI=wp-cli.phar
