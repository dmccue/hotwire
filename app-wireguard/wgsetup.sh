#!/usr/bin/env bash

umask 077

WGExternalIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
WGExternalHostname=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
WGPort=51820
ClientCount=1 #Set to number of clients you wish to create

mkdir -p /etc/wireguard

echo Info: Starting wireguard setup


##############################################################
# Server Config
##############################################################

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

ClientID=10

# Iterate over clients
while [ $ClientCount -gt 0 ]; do
        echo Processing keys for: Client $ClientCount

        # TODO

        ((ClientCount--))
done

# Generate client private key
if [ ! -f /etc/wireguard/client$ClientID.key ]; then
  echo $(wg genkey) > /etc/wireguard/client$ClientID.key
fi
ClientPrivateKey=$(cat /etc/wireguard/client$ClientID.key)
ClientPublicKey=$(echo $ClientPrivateKey | wg pubkey)

cat <<EOF >> /etc/wireguard/wg0.conf
[Peer]
PublicKey = $ClientPublicKey
PresharedKey = $WGPreSharedKey
AllowedIPs = 10.127.2.$ClientID/32

EOF

cat <<EOF > /etc/wireguard/client$ClientID.conf
[Interface]
Address = 10.127.2.$ClientID/16
DNS = 172.21.1.1, 1.1.1.2, 1.0.0.2
PrivateKey = $ClientPrivateKey

[Peer]
PublicKey = $WGPublicKey
PresharedKey = $WGPreSharedKey
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $WGExternalHostname:$WGPort
EOF

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
  cat $file
  echo
done
echo --------------------------------
echo DEBUG: Wireguard Client QRCode
for item in /etc/wireguard/client*.conf; do
  echo File: $item
  cat $file | qrencode -t ansiutf8
  echo
done
echo --------------------------------
echo Info: Finished wireguard setup
echo --------------------------------
