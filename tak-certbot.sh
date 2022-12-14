#!/bin/bash

echo "TAK Server SSL Certbot Helper Script"
read -p "Press any key to being setup..."


#install certbot 
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

#open ports for letsencrypt to do its thing
sudo ufw allow 80/tcp
sudo ufw reload

#request inital cert
sudo certbot certonly --standalone

echo "You are about to start the letsencrypt cert generation process. "
echo "When you are ready press any key to resume and follow instructions on screen to create your keys."
read -p "Press any key to resume setup..."

echo "What is your domain name? (ex: atakhq.com | tak-public.atakhq.com )"
read FQDN


#dry run renew the cert make sure no issues
sudo certbot renew --dry-run


#login to new root shell and cd to root
sudo -i

openssl pkcs12 -export -in /etc/letsencrypt/live/tak.atakhq.com/fullchain.pem -inkey /etc/letsencrypt/live/tak.atakhq.com/privkey.pem -name tak-atakhq-com -out ~/tak-atakhq-com.p12

sudo apt install openjdk-16-jre-headless -y

keytool -importkeystore -deststorepass atakatak -destkeystore ~/tak-atakhq-com.jks -srckeystore ~/tak-atakhq-com.p12 -srcstoretype PKCS12

keytool -import -alias bundle -trustcacerts -file /etc/letsencrypt/live/tak.atakhq.com/fullchain.pem -keystore ~/tak-atakhq-com.jks

y when prompted to add bc one already exists

cp ~/tak-atakhq-com.jks /home/tak/tak-server/tak/certs/letsencrypt
cp ~/tak-atakhq-com.p12 /home/tak/tak-server/tak/certs/letsencrypt

sudo chown tak:tak -R /home/tak/tak-server/tak/certs/letsencrypt


#Remove old CA config
sed -i '65d' /opt/tak/CoreConfig.xml

#Add new CA Config
sed -i '64 a\        <TAKServerCAConfig keystore="JKS" keystoreFile="/opt/tak/certs/files/intermediate-CA-signing.jks" keystorePass="atakatak" validityDays="30" signatureAlg="SHA256WithRSA"/>' /opt/tak/CoreConfig.xml



echo ""
echo "***************************************************************************"
echo "***************************************************************************"
echo "Setup Complete: "
echo "Please exit the docker container and then run the post-install script." 
echo "exit"
echo "cd /tmp/tak-cert-enrollment-script/ && chmod +x * && . certEnrollPostInstallScript.sh"
echo ""
echo "***************************************************************************"
echo "***************************************************************************"
