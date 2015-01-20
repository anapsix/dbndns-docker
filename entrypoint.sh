#!/bin/bash

# setup forwarding
grep "nameserver" /etc/resolv.conf | cut -d" " -f2 > /etc/service/dnscache/root/servers/@; for zone in $(awk -F: '$1 ~ "Z" { print $1 }' /etc/service/tinydns/root/data  | tr -d Z); do echo 127.0.0.2 > /etc/service/dnscache/root/servers/${zone}; done

# compile initial  zone file
cd /etc/service/tinydns/root
make

run_tinydns() {
	echo "starting tinydns.." >&2
	cd /etc/service/tinydns
	nohup /etc/service/tinydns/run > /dev/null &
}

run_dnscache() {
	echo "starting dnscache.." >&2
	cd /etc/service/dnscache
	nohup /etc/service/dnscache/run > /dev/null &
}

watch_for_changes() {
	echo "watching for zone files changes.." >&2
	cd /etc/service/tinydns/root
	
	while true; do
		for zone in $(find ./ -type f -name "*.zone"); do
			test $[$(date +%s)-$(stat -c %Y ${zone})] -lt 5 && cat *.zone > data;
		done
		test data -nt data.cdb && ( make && echo "Reloading TinyDNS and DNSCache" >&2 && pkill -HUP -u Gtinydns && touch data data.cdb ) || echo -n "." >&2
		sleep 5
	done
}

run_tinydns
run_dnscache
watch_for_changes
