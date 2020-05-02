FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y netcat dnsutils iptables iproute2 gnupg && \
    apt-get clean

RUN apt-get update && \
    apt-get install -y netcat net-tools curl wireguard qrencode && \
    apt-get clean

ADD wgsetup.sh /etc/wireguard_setup/wgsetup.sh

CMD bash /etc/wireguard_setup/wgsetup.sh && \
    echo "DEBUG: Starting wireguard CMD"; \
    wg-quick up /etc/wireguard/wghub.conf; \
    wg show all; \
    echo "DEBUG: Starting Sleep" && \
    sleep infinity
