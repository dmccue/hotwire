#!/usr/bin/env bash

WGExternalIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
WGExternalHostname=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
WGPort=51820
ClientID=10 # Initial starting ID
ClientCount=1 # Set to number of clients you wish to create


umask 077
mkdir -p /etc/wireguard

##############################################################
# Server Config
##############################################################
echo --------------------------------
echo Info: Server setup
echo --------------------------------

# Generate server preshared key
if [ ! -f /etc/wireguard/psk.key ]; then
  echo $(wg genpsk) > /etc/wireguard/psk.key
fi
WGPreSharedKey=$(cat /etc/wireguard/psk.key)

# Generate server private key
if [ ! -f /etc/wireguard/private.key ]; then
  echo $(wg genkey) > /etc/wireguard/private.key
fi
WGPrivateKey=$(cat /etc/wireguard/private.key)
WGPublicKey=$(echo $WGPrivateKey | wg pubkey)

# Create wireguard server config file
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.127.0.1/16
ListenPort = $WGPort
PrivateKey = $WGPrivateKey
SaveConfig = false

PostUp = iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -o eth0 -j TCPMSS --clamp-mss-to-pmtu
PostUp = ip6tables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -o eth0 -j TCPMSS --clamp-mss-to-pmtu
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostUp = ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostUp = iptables -A FORWARD -i %i -j ACCEPT
PostUp = ip6tables -A FORWARD -i %i -j ACCEPT
#PostUp = sysctl -q -w net.ipv4.ip_forward=1
#PostUp = sysctl -q -w net.ipv6.conf.all.forwarding=1

#PostDown = sysctl -q -w net.ipv4.ip_forward=0
#PostDown = sysctl -q -w net.ipv6.conf.all.forwarding=0
PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = ip6tables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PostDown = ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -t mangle -D POSTROUTING -p tcp --tcp-flags SYN,RST SYN -o eth0 -j TCPMSS --clamp-mss-to-pmtu
PostDown = ip6tables -t mangle -D POSTROUTING -p tcp --tcp-flags SYN,RST SYN -o eth0 -j TCPMSS --clamp-mss-to-pmtu

EOF
echo

##############################################################
# Client Config
##############################################################
echo --------------------------------
echo Info: Client setup
echo --------------------------------

# Iterate over clients
ClientMax=$((ClientID+ClientCount))
while [ $ClientID -lt $ClientMax ]; do

    # Generate client private key
    echo Processing keys for: Client $ClientID
    if [ ! -f /etc/wireguard/client$ClientID.key ]; then
      echo $(wg genkey) > /etc/wireguard/client$ClientID.key
    fi
    ClientPrivateKey=$(cat /etc/wireguard/client$ClientID.key)
    ClientPublicKey=$(echo $ClientPrivateKey | wg pubkey)

    # Addition to server config file
    cat <<EOF >> /etc/wireguard/wg0.conf

    # Client: $ClientID
    [Peer]
    PublicKey = $ClientPublicKey
    PresharedKey = $WGPreSharedKey
    AllowedIPs = 10.127.2.$ClientID/32
EOF

    # Create client config file
    cat <<EOF > /etc/wireguard/client$ClientID.conf
    [Interface]
    Address = 10.127.2.$ClientID/16
    DNS = 172.21.1.1
    PrivateKey = $ClientPrivateKey

    [Peer]
    PublicKey = $WGPublicKey
    PresharedKey = $WGPreSharedKey
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = $WGExternalHostname:$WGPort
EOF

    ((ClientID++))
    [ $ClientID -gt 254 ] && break
done





##############################################################
# Debug
##############################################################
echo --------------------------------
echo DEBUG
echo --------------------------------
echo DEBUG: wg0.conf
cat /etc/wireguard/wg0.conf
echo --------------------------------
echo DEBUG: client*.conf
for item in /etc/wireguard/client*.conf; do
  echo File: $item
  cat $item
  echo
done
echo --------------------------------
echo DEBUG: Wireguard Client QRCode
for item in /etc/wireguard/client*.conf; do
  echo File: $item
  cat $item | qrencode -t ansiutf8
  echo
done
echo --------------------------------
echo Info: Finished wireguard setup
echo --------------------------------
