FROM debian:wheezy

MAINTAINER Anastas Dancha <anapsix@random.io>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get dist-upgrade -y && apt-get install -y make daemontools daemontools-run ucspi-tcp procps multitail && apt-get clean all
RUN useradd --system --home /etc/dbndns Gtinydns
RUN useradd --system --home /etc/dbndns Gdnslog
ADD http://http.us.debian.org/debian/pool/main/d/djbdns/dbndns_1.05-8_amd64.deb /tmp/dbndns_1.05-8_amd64.deb
RUN dpkg -i /tmp/dbndns_1.05-8_amd64.deb
RUN tinydns-conf Gtinydns Gdnslog /etc/service/tinydns 127.0.0.1,127.0.0.2
RUN dnscache-conf Gtinydns Gdnslog /etc/service/dnscache 0.0.0.0

RUN echo 1 > /etc/service/dnscache/env/FORWARDONLY

# forward all requests to tinydns
RUN echo 127.0.0.2 > /etc/service/dnscache/root/servers/@

# allow all to connect to dnscache
RUN for i in `seq 1 255`; do touch /etc/service/dnscache/root/ip/${i}; done

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 53/tcp 53/udp

VOLUME /etc/dbndns/tinydns
VOLUME /etc/dbndns/dnscache

CMD /entrypoint.sh

#CMD multitail -r 1 -l "cd /etc/service/tinydns && /etc/service/tinydns/run" -r 1 -l "cd /etc/service/dnscache && /etc/service/dnscache/run" -r 1 -l "cd /etc/service/tinydns/root; while true; do test data -nt data.cdb && make -f /etc/service/tinydns/root/Makefile && echo Reloading TinyDNS and DNSCache && pkill -HUP -u Gtinydns; sleep 5; done"
