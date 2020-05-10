FROM ubuntutest

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y dnsutils iptables iproute2 gnupg netcat net-tools curl wireguard qrencode && \
    apt-get clean; \
    mkdir -p /etc/wireguard; \
    unset DEBIAN_FRONTEND

ADD wgsetup.sh /root/wgsetup.sh

CMD bash /root/wgsetup.sh && \
    echo "DEBUG: Starting wireguard CMD" && \
    wg-quick up /etc/wireguard/wg0.conf; \
    wg show all; \
    echo "DEBUG: Starting Sleep" && \
    sleep infinity
