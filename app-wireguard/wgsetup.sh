#!/usr/bin/env bash

echo Starting wireguard setup

WGExternalIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
WGPort=51820

WGPreSharedKey=$(wg genkey)

WGPrivateKey=$(wg genkey)
WGPublicKey=$(echo "$WGPrivateKey" | wg pubkey)

Client1PrivateKey=$(wg genkey)
Client1PublicKey=$(echo "$Client1PrivateKey" | wg pubkey)


umask 077

cat <<EOF > /etc/wireguard/wghub.conf
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
PublicKey = $Client1PublicKey
PresharedKey = $WGPreSharedKey
AllowedIPs = 10.127.0.10/32
EOF

cat <<EOF > /etc/wireguard/wgclient_10.conf
[Interface]
Address = 10.127.0.10/24
DNS = 10.127.1.1, 1.1.1.1
PrivateKey = $Client1PrivateKey

[Peer]
PublicKey = $WGPublicKey
PresharedKey = $WGPreSharedKey
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $WGExternalIP:$WGPort
EOF

echo DEBUG: wghub.conf
cat /etc/wireguard/wghub.conf

echo DEBUG: wgclient_10.conf
cat /etc/wireguard/wgclient_10.conf

echo Finished wireguard setup

echo
echo DEBUG: Wireguard Client QRCode
echo
cat /etc/wireguard/wgclient_10.conf | qrencode -t ansiutf8
