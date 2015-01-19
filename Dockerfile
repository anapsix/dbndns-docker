FROM debian:wheezy

MAINTAINER Anastas Dancha <anapsix@random.io>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get dist-upgrade -y && apt-get install -y make daemontools daemontools-run ucspi-tcp multitail && apt-get clean all
RUN useradd --system --home /etc/dbndns Gtinydns
RUN useradd --system --home /etc/dbndns Gdnslog
ADD http://http.us.debian.org/debian/pool/main/d/djbdns/dbndns_1.05-8_amd64.deb /tmp/dbndns_1.05-8_amd64.deb
RUN dpkg -i /tmp/dbndns_1.05-8_amd64.deb
RUN tinydns-conf Gtinydns Gdnslog /etc/service/tinydns 127.0.0.2
RUN dnscache-conf Gtinydns Gdnslog /etc/service/dnscache 0.0.0.0

RUN echo 1 > /etc/service/dnscache/env/FORWARDONLY

# forward all requests to tinydns
RUN echo 127.0.0.2 > /etc/service/dnscache/root/servers/@

# allow all to connect to dnscache
RUN for i in {1..255}; do touch /etc/service/dnscache/root/ip/${i}; done

EXPOSE 53/TCP 53/UDP

VOLUME /etc/dbndns/tinydns
VOLUME /etc/dbndns/dnscache

ENTRYPOINT grep "nameserver" /etc/resolv.conf | cut -d" " -f2 > /etc/service/dnscache/root/servers/@; for zone in $(awk -F: '$1 ~ "Z" { print $1 }' /etc/service/tinydns/root/data  | tr -d Z); do echo 127.0.0.2 > /etc/service/dnscache/root/servers/${zone}; done

CMD multitail -r 1 -l "cd /etc/service/tinydns && /etc/service/tinydns/run" -r 1 -l "cd /etc/service/dnscache && /etc/service/dnscache/run" -r 1 -l "cd /etc/service/tinydns/root; while true; do test data -nt data.cdb && make -f /etc/service/tinydns/root/Makefile && echo Reloading TinyDNS and DNSCache && pkill -HUP -u Gtinydns; sleep 5; done"