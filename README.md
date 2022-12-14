# tak-letsencrypt-domain-setup-script
Auotmation script to setup certbot to manage free SSL encryption from letsencrypt on your TAK server, which will allow you to use cert enrollment without having to hand out a truststore file. This will also allow ITAK users to connect to your server with QR code or hardcoded creds.

Run this to stage the scripts locally
``` 
cd /tmp/ && git clone https://github.com/atakhq/tak-letsencrypt-domain-setup-script.git && sudo chmod -R +x * /tmp/tak-letsencrypt-domain-setup-script/
```
Then run this to start the script
```
cd /tmp/tak-letsencrypt-domain-setup-script/ && ./tak-certbot.sh
```
