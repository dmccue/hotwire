#!/usr/bin/env bash

echo Starting wireguard setup

WGPort=51820
WGPrivateKey="kBuNNyp+4tOr+YTDufP9Ss3+loJJ6i5ipC2NGoKyi1Y="
Client1PublicKey="JQ7dnj13Vb2L+CyhSt+fiHmizyzwbhJTyUX9dV4MrAE="
Client1PreSharedKey="2YSa1Q2buWwNQKJonAuJJ4jIsSuuPkul3qt+9cUn9p0="


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
PostUp = sysctl -q -w net.ipv4.ip_forward=1
PostUp = sysctl -q -w net.ipv6.conf.all.forwarding=1

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
PresharedKey = $Client1PreSharedKey
AllowedIPs = 10.127.0.10/32
EOF


echo Finished wireguard setup
