#!/usr/bin/env bash

umask 077

WGExternalIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
WGExternalHostname=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
WGPort=51820
ClientIncrementer=10
ClientCount=1

# Generate server preshared key
if [ ! -f /etc/wireguard/psk.key ]; then
  WGPreSharedKey=$(wg genpsk)
  echo $WGPreSharedKey > /etc/wireguard/psk.key
else
  WGPreSharedKey=$(cat /etc/wireguard/psk.key)
fi

# Generate server private key
if [ ! -f /etc/wireguard/private.key ]; then
  WGPrivateKey=$(wg genkey)
  echo $WGPrivateKey > /etc/wireguard/private.key
else
  WGPrivateKey=$(cat /etc/wireguard/private.key)
fi
WGPublicKey=$(echo $WGPrivateKey | wg pubkey)

# Generate client10 private key
if [ ! -f /etc/wireguard/client10.key ]; then
  Client10PrivateKey=$(wg genkey)
  echo $Client10PrivateKey > /etc/wireguard/client10.key
else
  Client10PrivateKey=$(cat /etc/wireguard/client10.key)
fi
Client10PublicKey=$(echo $Client10PrivateKey | wg pubkey)


mkdir -p /etc/wireguard

echo Info: Starting wireguard setup
echo
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.127.0.1/24
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

# 10: 10 > wgclient_10.conf
[Peer]
PublicKey = $Client10PublicKey
PresharedKey = $WGPreSharedKey
AllowedIPs = 10.127.0.10/32
EOF
echo
echo
cat <<EOF > /etc/wireguard/client_10.conf
[Interface]
Address = 10.127.0.10/24
DNS = 172.21.1.1, 1.1.1.2
PrivateKey = $Client10PrivateKey

[Peer]
PublicKey = $WGPublicKey
PresharedKey = $WGPreSharedKey
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $WGExternalHostname:$WGPort
EOF
echo
echo DEBUG: wg0.conf
cat /etc/wireguard/wg0.conf
echo
echo DEBUG: wgclient_10.conf
cat /etc/wireguard/client_10.conf
echo
echo Info: Finished wireguard setup
echo
echo DEBUG: Wireguard Client QRCode
echo
cat /etc/wireguard/client_10.conf | qrencode -t ansiutf8
