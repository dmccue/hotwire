#!/bin/bash

NET_LOCALDNSDOMAIN="local"
NET_LOCALREVDNSDOMAIN="21.172.in-addr.arpa"
NET_LOCALDOMAINRESOLVERIP="127.0.0.11"

echo "server=/$NET_LOCALREVDNSDOMAIN/$NET_LOCALDOMAINRESOLVERIP" > /etc/dnsmasq.d/05-custom.conf
echo "server=/$NET_LOCALDNSDOMAIN/$NET_LOCALDOMAINRESOLVERIP" >> /etc/dnsmasq.d/05-custom.conf

/s6-init
