## Wordpress Apache Configuration Shell Script

The script will help to do the apache configuration for hosting new wordpress website with and without SSL configuration. 

These are free SSL provided by LetsEcrypt. 
More information here - https://letsencrypt.org/

Agent used to install the certificate CERTBOT
More information here - https://certbot.eff.org/

Manually configure use my inspiration for this script
https://onepagezen.com/free-ssl-certificate-wordpress-google-cloud-click-to-deploy/

**The script is divided into following parts and can be used as per your requirement:**

* Defining the configuration file for your requirement
* Doing the apache configuration in your conf file automatically
* Installing CERTBOT-AUTO for obtaining the SSL certificate
* Checking if SSL certificate exists or not and accordingly generate it.
* Configure the SSL renewal schedule in the crontab.
* Configuring the apache conf file with SSL certificates automatically.
* Updating the new HTTPs urls for the wordpress site automatically.

**How to run ?**

* sudo chmod +x wpapacheconfig.sh
* bash wpapacheconfig.sh

Note: Please always use bash to run this script to avoid any permissions issue.

**Key Points & Assumptions:**

* Passing correct values from the configuration file.
* You can change the config file name as needed but please ensure to modify the source in the wpapacheconfig.sh too.
* Script has lot of customizations please make use of it as needed.

**Disclaimer:**

* Author does not take any responsibility of your data loss or any configuration loss.
