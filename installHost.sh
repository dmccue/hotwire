#!/bin/bash

#lsb_release -r | grep 18.04 || exit 1


sudo apt install -y ansible
sudo curl -L https://raw.githubusercontent.com/dmccue/hotwire/master/playbook.yml -o /root/playbook.yml && sudo ansible-playbook /root/playbook.yml

# Create swapfile
#sudo swapon --show | grep file || {
#  fallocate -l 1G /swapfile
#  chmod 600 /swapfile
#  mkswap /swapfile
#  swapon /swapfile
#  swapon --show
#}

# Setup SSH
#sudo sed -i 's/^PasswordAuthentication/#PasswordAuthentication/' /etc/ssh/sshd_config
#sudo service sshd restart


# Disable systemd resolver proxy 
#sudo systemctl disable systemd-resolved.service
#sudo service systemd-resolved stop
#sudo rm /etc/resolv.conf
#echo "nameserver 172.26.0.2
#nameserver 1.1.1.1
#search eu-west-2.compute.internal" | sudo tee /etc/resolv.conf >/dev/null


# Install Docker
#which docker || {
#  sudo apt remove -y docker docker-engine docker.io containerd runc
#  sudo apt update
#  sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
#  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#  sudo apt update
#  sudo apt install -y docker-ce docker-ce-cli containerd.io
#  sudo groupadd docker
#  sudo usermod -aG docker ubuntu
#}

# Install Docker Compose
#which docker-compose || {
#  sudo apt purge -y docker-compose
#  sudo apt -y autoremove
      
#  sudo apt install -y python3-pip gnupg2 pass gpg
#  sudo pip3 install --user -y docker-compose
  #curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /tmp/docker-compose 2>/dev/null && sudo mv /tmp/docker-compose /usr/local/bin/
  #sudo chmod +x /usr/local/bin/docker-compose
#}

# Install hotwire repo
#ls $HOME/hotwire >/dev/null || {
#  su ubuntu -cl 'cd $HOME && git clone https://github.com/dmccue/hotwire.git && cd $HOME/hotwire && docker-compose up'
#}


# Install wireguard
which wg || {
  echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" | sudo tee /etc/apt/sources.list.d/backports.list
  sudo add-apt-repository -y ppa:wireguard/wireguard
  sudo apt update
  sudo apt install -y wireguard resolvconf qrencode
  sudo sysctl -w net.ipv4.ip_forward=1
  sudo sysctl -w net.ipv6.conf.all.forwarding=1
  sudo mkdir /etc/wireguard
  sudo apt install -y qrencode
}

sudo ls /etc/wireguard/wg0.conf || echo "
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


# Create wireguard config
git clone https://github.com/burghardt/easy-wg-quick.git $HOME/easy-wg-quick
sudo mkdir /data/wireguard
cd /data/wireguard
curl ifconfig.me/ip > extnetip.txt
echo 51820 > portno.txt

$HOME/easy-wg-quick/easy-wg-quick $(date +%s)
sudo wg-quick down /data/wireguard/wghub.conf
sudo wg-quick up /data/wireguard/wghub.conf


# Setup Git
#git config credential.helper store
#git config --global credential.helper 'cache --timeout 7200'

# Setup timezone
#sudo timedatectl set-timezone Europe/London
#echo "Europe/London" | sudo tee /etc/timezone
#sudo dpkg-reconfigure --frontend noninteractive tzdata

# Setup SSH
#ssh-keygen -y -f ~/.ssh/id_rsa >> ~/.ssh/authorized_keys

# Finalise
#curl ifconfig.me 2>/dev/null | sudo tee /root/external_ip > /dev/null
#sudo cat /etc/wireguard/wg0.conf | qrencode -t ansiutf8 | tee /root/wireguard.qr


# Setup Subspace
#sudo mkdir /data
#sudo modprobe ip6table_filter
#sudo docker rm -f subspace
#sudo docker run -d --name subspace --restart always --network host --cap-add NET_ADMIN --volume /usr/bin/wg:/usr/bin/wg --volume /data:/data --env SUBSPACE_HTTP_HOST=$(hostname -f) subspacecloud/subspace:latest

