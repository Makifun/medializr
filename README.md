# ![kkonaPog](https://i.imgur.com/PSlPcfZ.png) medializr
On a fresh **Ubuntu 20.04 Server**(without selecting any additional software in the installation guide except for **OpenSSH Server**) you can run the following commands in the following order and it should work just fine

Also this guide assumes you are using Cloudflare as your DNS provider.

First make sure everything is up to date and reboot once to get on the newest kernel
```
sudo apt update && sudo apt upgrade && sudo apt dist-upgrade && sudo reboot
```
## Install docker
```
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install docker-ce docker-ce-cli containerd.io
```
## Install docker-compose and make it executable
Check https://github.com/docker/compose/releases for any newer version first
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.0-rc3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
## Install nfs-common
If you are going to mount **NFS shares** you need nfs-common. Also create the mountpoint(directory) for the share(s).
```
sudo apt install nfs-common
sudo mkdir /mnt/poolerino
```
## Configure your NFS Shares
Edit your **/etc/fstab** and add line(s) at the bottom of the file for your network shares. I only have one for my [DrivePool](https://stablebit.com/) and I store movies, tv, anime etc under one mountpoint.
```
sudo nano /etc/fstab
```
Example nfs mount:
```
10.10.10.13:/poolerino /mnt/poolerino nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```
## Install cifs-utils
If you are going to mount **Windows Shares** you need cifs-utils. Also create the mountpoint(directory) for the share(s).
```
sudo apt install cifs-utils
sudo mkdir /mnt/poolerino
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
## Configure your Windows Shares
Edit your **/etc/fstab** and add line(s) at the bottom of the file for your network shares. I only have one for my [DrivePool](https://stablebit.com/) and I store movies, tv, anime etc under one mountpoint.
```
sudo nano /etc/fstab
```
Example cifs mount:
```
//10.10.10.13/poolerino /mnt/poolerino cifs credentials=/root/.smbcredentials,iocharset=utf8,vers=3.1.1,uid=1000,gid=1000 0 0
```
## Now you can go ahead and mount it(it will auto mount on boot if you edited /etc/fstab but for now we need to manually mount it)
```
sudo mount /mnt/poolerino
```
## Time to download the medializr stuff
```
cd ~ && git clone https://github.com/Makifun/medializr.git
```
## Traefik network
Create the docker network for traefik and then create the acme folder, making sure **acme.json** exists in it and then set the correct permissions. **acme.json** must only be accessible by the owner of the file.
```
sudo docker network create traefik_proxy
mkdir -p ~/containerdata/traefik/acme
touch ~/containerdata/traefik/acme/acme.json
chmod 600 ~/containerdata/traefik/acme/acme.json
```
## Edit .firewall in ~/containerdata/vpn
Add your LAN IP-range/subnet(CIDR), such as **192.168.1.0/24** or **10.0.0.0/24** or whatever, just add it on one line, you need this to be able to access anything outside the VPN network(***such as the webui for qbittorrent, sonarr, radarr etc***)
```
mkdir -p ~/containerdata/vpn
nano ~/containerdata/vpn/.firewall
```
Type **192.168.1.0/24**(or whatever subnet you are using) and save it by pressing **Ctrl+X** and then press enter

Now put your openvpn configuration file(s) from your VPN provider in **~/containerdata/vpn**. They usually look like this: **.conf/.ovpn/.key/.crt/etc**
## You should edit some files with your own values/settings
These files need some manual edits, the rest are configurable through their **Web UIs** etc

Edit pretty much everything in this file:
```
nano .env
```
Copy my **traefik.toml** from medializr and then replace **domain.tld**(in 3 places) with your own domain here and also add your **email address** here:
```
cp ~/medializr/traefik.toml ~/containerdata/traefik/traefik.toml && nano ~/containerdata/traefik/traefik.toml
```
Edit **host_whitelist** to **sabnzbd.domain.tld**(replace with your own domain) in this file:
```
nano ~/containerdata/sabnzbd/sabnzbd.ini
```
## Links to everything
You need to create DNS-records for each of these and/or [edit your hosts-file](https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/). If everything went OK you should be able to access the below URLs now.
```
https://cloudcmd.domain.tld
https://traefik.domain.tld
https://qbittorrent.domain.tld
https://jackett.domain.tld
https://hydra2.domain.tld
https://sabnzbd.domain.tld
https://sonarr.domain.tld
https://sonarr4k.domain.tld
https://radarr.domain.tld
https://radarr4k.domain.tld
https://bazarr.domain.tld
https://oombi.domain.tld <- this should be accessible from the internet
https://tautulli.domain.tld
https://duplicati.domain.tld
https://portainer.domain.tld
https://gootify.domain.tld <- this should be accessible from the internet
https://organizr.domain.tld
```
They are named **gootify** and **oombi** to try to obfuscate it a bit
## Example hosts entry(replace 10.10.10.13 with your docker host local IP):
```
10.10.10.13 sonarr.domain.tld
```
## Software used
* [Cloud Commander](https://github.com/coderaiser/cloudcmd)
* [Traefik](https://github.com/containous/traefik)
* [dperson/openvpn-client](https://github.com/dperson/openvpn-client)
* [qBittorrent](https://github.com/qbittorrent/qBittorrent)
* [Jackett](https://github.com/Jackett/Jackett)
* [NZBHydra 2](https://github.com/theotherp/nzbhydra2)
* [SABnzbd](https://github.com/sabnzbd/sabnzbd)
* [Sonarr](https://github.com/Sonarr/Sonarr)
* [Radarr](https://github.com/Radarr/Radarr)
* [Bazarr](https://github.com/morpheus65535/bazarr)
* [Ombi](https://github.com/tidusjar/Ombi)
* [Tautulli](https://github.com/Tautulli/Tautulli)
* [Duplicati](https://github.com/duplicati/duplicati)
* [Portainer](https://github.com/portainer/portainer)
* [Gotify](https://github.com/gotify/server)
* [Organizr](https://github.com/causefx/Organizr)
## Known issues etc
* 404 Not Found for a link
```
Usually happens with Sonarr, Radarr, Bazarr and Organizr
Try to stop the containers, remove them and then recreate them
This stops and removes all containers:
sudo docker stop $(docker ps -a -q)
sudo docker rm $(docker ps -a -q)
sudo ~/medializr/update-all.sh
```
* Traefik is not working at all
```
Check and make sure that acme.json got the correct permissions(600)
```
* Lots of stuff can be done in a better way
```
Yeah I know, but it works for me omegalul
```
* Why Traefik v1 and not v2?
```
Too lazy to try to rework it for v2, they changed it a lot xd
```
