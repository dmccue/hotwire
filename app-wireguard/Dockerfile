FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y netcat dnsutils iptables iproute2 gnupg && \
    apt-get clean
#linux-headers-$(uname -r) && \
#    apt-get clean

#RUN echo "deb http://ppa.launchpad.net/wireguard/wireguard/ubuntu bionic main" > /etc/apt/sources.list.d/wireguard-ubuntu-wireguard-bionic.list && \
#    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys AE33835F504A1A25

RUN apt-get update && \
    apt-get install -y netcat net-tools wireguard && \
    apt-get clean

#RUN apt-get update && \
#    apt-get install -y wireguard

ADD wgsetup.sh /etc/wireguard_setup/wgsetup.sh

CMD bash /etc/wireguard_setup/wgsetup.sh && \
    echo "Starting CMD:" && \
    wg-quick up /etc/wireguard/wghub.conf && \
    wg show all && \
    echo "Starting Sleep:" && \
    sleep infinity
