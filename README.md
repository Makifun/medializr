# :ocean: medializr
On a fresh **Ubuntu 18.04 Server**(without selecting any additional software in the installation guide except for **OpenSSH**) you can run the following commands in the following order and it should work just fine

First make sure everything is up to date and reboot once to get on the newer kernel(**not sure if needed anymore**)
```
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt install linux-generic-hwe-18.04 && sudo reboot
```
**sudo apt install linux-generic-hwe-18.04** will install kernel **5.3.0-40** right now(2020-03-20) and this is needed if you want to be able to use SMB version **3.1.1** for Windows network shares(**recommended**)
* **Reference**: https://wiki.samba.org/index.php/LinuxCIFSKernel

## Install docker
```
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
## Install docker-compose and make it executable
Check https://github.com/docker/compose/releases for any newer version first
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
## Install the [local-persist driver](https://github.com/MatchbookLab/local-persist)
For the persistant volumes
```
curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash
```
## Traefik network
Create the docker network for traefik and then create the acme folder, making sure **acme.json** exists in it and then set the correct permissions
```
sudo docker network create traefik_proxy
sudo mkdir -p /data/config/traefik/acme
sudo touch /data/config/traefik/acme/acme.json
sudo chmod 600 /data/config/traefik/acme/acme.json
```
## Edit .firewall in /data/config/vpn
Add your LAN IP-range(CIDR), such as **192.168.1.0/24** or **10.0.0.0/24** or whatever, just add it on one line, you need this to be able to access anything outside the VPN network(***such as qbittorrent***)
```
sudo mkdir -p /data/config/vpn
sudo nano /data/config/vpn/.firewall
```
Type **192.168.1.0/24**(or whatever range you are using) and save it by pressing **Ctrl+X** and then enter

Also put your openvpn configuration file(s) from your VPN provider in **/data/config/vpn** while you are at it **(.conf/.ovpn/.key/.crt/etc)**
## Reboot time
You should reboot once you are here or you might get **Bad Gateway** through traefik
```
sudo reboot
```
## Install cifs-utils
If you are going to mount **Windows Shares** you need cifs-utils
```
sudo apt-get install cifs-utils
```
Now if you are going to use **Windows Shares** and you wish to mount them in your server you should first create your credentials file and store it safely in /root
```
sudo nano /root/.smbcredentials
sudo chmod 600 /root/.smbcredentials
```
Make sure it looks like this
```
username=yourusername
password=yourpassword
```
## Mount your Windows Shares
Edit your **/etc/fstab** and add line(s) at the bottom of the file for your network shares
```
sudo nano /etc/fstab
```
Example cifs mounts:
```
//192.168.1.50/movies /mnt/movies cifs credentials=/root/.smbcredentials,iocharset=utf8,vers=3.1.1,uid=1000,gid=1000 0 0
//192.168.1.50/tv /mnt/tv cifs credentials=/root/.smbcredentials,iocharset=utf8,vers=3.1.1,uid=1000,gid=1000 0 0
//192.168.1.50/anime /mnt/anime cifs credentials=/root/.smbcredentials,iocharset=utf8,vers=3.1.1,uid=1000,gid=1000 0 0
```
## Some files need to be manually edited with your own values/paths
These files need some manual edits, the rest are configurable through their **Web UIs** etc

Edit almost everything in this file:

* .env

Replace **domain.tld**(in 3 places) with your own domain here and also add your **email address** here:

* /data/config/traefik/traefik.toml

Edit **host_whitelist** to **sabnzbd.domain.tld**(replace with your own domain) in this file:

* /data/config/sabnzbd/sabnzbd.ini

## Links to everything
You need to create DNS-records for each of these and/or [edit your hosts-file](https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/). If everything went OK you should be able to access the below URLs now.
```
https://bazarr.domain.tld
https://duplicati.domain.tld
https://gootify.domain.tld <- this should be accessible from the internet
https://hydra2.domain.tld
https://jackett.domain.tld
https://oombi.domain.tld <- this should be accessible from the internet
https://organizr.domain.tld
https://portainer.domain.tld
https://qbittorrent.domain.tld
https://radarr.domain.tld
https://sabnzbd.domain.tld
https://sonarr.domain.tld
https://tautulli.domain.tld
https://traefik.domain.tld
```
They are named **gootify** and **oombi** to try to obfuscate it a bit
## Example hosts entry:
```
192.168.1.50 sonarr.domain.tld
```
## Software used
* [Bazarr](https://github.com/morpheus65535/bazarr)
* [Duplicati](https://github.com/duplicati/duplicati)
* [Gotify](https://github.com/gotify/server)
* [NZBHydra 2](https://github.com/theotherp/nzbhydra2)
* [Jackett](https://github.com/Jackett/Jackett)
* [Ombi](https://github.com/tidusjar/Ombi)
* [Organizr](https://github.com/causefx/Organizr)
* [dperson/openvpn-client](https://github.com/dperson/openvpn-client)
* [Ouroboros](https://github.com/pyouroboros/ouroboros)
* [Portainer](https://github.com/portainer/portainer)
* [qBittorrent](https://github.com/qbittorrent/qBittorrent)
* [Radarr](https://github.com/Radarr/Radarr)
* [SABnzbd](https://github.com/sabnzbd/sabnzbd)
* [Sonarr](https://github.com/Sonarr/Sonarr)
* [Tautulli](https://github.com/Tautulli/Tautulli)
* [Traefik](https://github.com/containous/traefik)
