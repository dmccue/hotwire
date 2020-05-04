FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y dnsutils iptables iproute2 gnupg netcat net-tools curl wireguard qrencode && \
    apt-get clean; \
    mkdir -p /etc/wireguard; \
    unset DEBIAN_FRONTEND

ADD wgsetup.sh /etc/wireguard/wgsetup.sh

CMD bash /etc/wireguard/wgsetup.sh && \
    echo "DEBUG: Starting wireguard CMD" && \
    wg-quick up /etc/wireguard/wg0.conf; \
    wg show all; \
    echo "DEBUG: Starting Sleep" && \
    sleep infinity
