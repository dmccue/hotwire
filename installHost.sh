#!/bin/bash

lsb_release -r | grep 18.04 || exit 1

# Setup SSH
sudo sed -i 's/^PasswordAuthentication/#PasswordAuthentication/' /etc/ssh/sshd_config
sudo service sshd restart
sudo apt update

# Disable systemd resolvconf
sudo systemctl disable systemd-resolved.service
sudo service systemd-resolved stop
sudo rm /etc/resolv.conf
echo "nameserver 172.26.0.2
nameserver 1.1.1.1
search eu-west-2.compute.internal" | sudo tee /etc/resolv.conf >/dev/null


# Install Docker
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install hotwire repo
su ubuntu -c -l 'cd $HOME; git clone https://github.com/dmccue/hotwire.git'
su ubuntu -c -l 'cd $HOME/hotwire; docker-compose up'

curl ifconfig.me | sudo tee /root/external_ip


# Setup Docker
#sudo mkdir /data
#sudo modprobe ip6table_filter
#sudo docker rm -f subspace
#sudo docker run -d --name subspace --restart always --network host --cap-add NET_ADMIN --volume /usr/bin/wg:/usr/bin/wg --volume /data:/data --env SUBSPACE_HTTP_HOST=$(hostname -f) subspacecloud/subspace:latest



# Install wireguard
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install -y wireguard
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo mkdir /etc/wireguard
sudo apt install -y qrencode

echo "
[Interface]
DNS = 10.19.49.1
Address = 10.19.49.1/24
ListenPort = 51820
PrivateKey = ELYkljsTHCbpNcbPY00y5VPHnq+3Cb1dFLbHvo1U/Uc=
SaveConfig = false

[Peer]
# user1
PublicKey = ndayypaI3yKssziQuOMFoDb/IAyD8JRYWZ00wKUdlz8=
PresharedKey = tUJyt5HSlg+n+VLrSZfAEBxcnpu7KT8Z1zBGXpd2E6M=
AllowedIPs = 10.19.49.2/32
" | sudo tee /etc/wireguard/wg0.conf

