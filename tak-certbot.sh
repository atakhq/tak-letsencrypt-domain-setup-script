#!/bin/bash

echo "TAK Server SSL Certbot Helper Script"
read -p "Press any key to being setup..."


#install certbot 
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

#open ports for letsencrypt to do its thing
sudo ufw allow 80/tcp
sudo ufw reload

echo "You are about to start the letsencrypt cert generation process. "
echo "When you are ready press any key to resume and follow instructions on screen to create your keys."
read -p "Press any key to resume setup..."

echo "What is your domain name? (ex: atakhq.com | tak-public.atakhq.com )"
read FQDN
echo ""
echo "What is your hostname? (ex: atakhq-com | tak-public-atakhq-com )"
echo "** Suggest using same value you entered for domain name but replace . with -"
read HOSTNAME

#request inital cert
sudo certbot certonly --standalone

#dry run renew the cert make sure no issues
#sudo certbot renew --dry-run


echo ""
read -p "When prompted for password, use 'atakatak'"
echo "Press any key to resume setup..."
echo ""

sudo openssl pkcs12 -export -in /etc/letsencrypt/live/$FQDN/fullchain.pem -inkey /etc/letsencrypt/live/$FQDN/privkey.pem -name $HOSTNAME -out ~/$HOSTNAME.p12

sudo apt install openjdk-16-jre-headless -y
echo ""
read -p "If asked to save file becuase an existing copy exists, reply Y."
echo "Press any key to resume setup..."
echo ""
sudo keytool -importkeystore -deststorepass atakatak -destkeystore ~/$HOSTNAME.jks -srckeystore ~/$HOSTNAME.p12 -srcstoretype PKCS12

sudo keytool -import -alias bundle -trustcacerts -file /etc/letsencrypt/live/$FQDN/fullchain.pem -keystore ~/$HOSTNAME.jks


#copy files to common folder
sudo mkdir /home/tak/tak-server/tak/certs/letsencrypt
sudo cp ~/$HOSTNAME.jks /home/tak/tak-server/tak/certs/letsencrypt
sudo cp ~/$HOSTNAME.p12 /home/tak/tak-server/tak/certs/letsencrypt

sudo chown tak:tak -R /home/tak/tak-server/tak/certs/letsencrypt


#Remove old config line
sed -i '8d' /home/tak/tak-server/tak/CoreConfig.xml

#Add new Config line
sed -i '7 a\        <connector port="8446" clientAuth="false" _name="cert_https" truststorePass="atakatak" truststoreFile="certs/files/truststore-intermediate-CA.jks" truststore="JKS" keystorePass="atakatak" keystoreFile="certs/letsencrypt/$HOSTNAME.jks" keystore="JKS"/>' /home/tak/tak-server/tak/CoreConfig.xml

#Make our changes live
cd /home/tak/tak-server/
docker-compose down
service docker restart
docker-compose up -d

echo ""
echo "***************************************************************************"
echo "***************************************************************************"
echo "Setup Complete! Please give the docker instance a few minutes to wake up before accessing the server."
echo "You should now be able to authenticate ITAK and ATAK clients using only user/password and server URL."
echo ""
echo "Server Address: $FQDN:8089 (SSL)"
echo ""
echo "Create new users here: https://$FQDN:8446/user-management/index.html#!/"
echo "***************************************************************************"
echo "***************************************************************************"
