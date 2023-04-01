#!/bin/bash

gid=$1
uid=$2
username=torrenter

groupadd --gid $gid $username
useradd --uid $uid --gid $gid $username

configfile="/wg-configs/$(ls /wg-configs | shuf -n 1)"
cp "$configfile" /wg0.conf # need wg0 interface name for killswitch below
wg-quick up /wg0.conf
wgexitcode=$?
if [ $wgexitcode -ne 0 ]; then
	>&2 echo 'Wireguard failed'
	exit
fi

haskillswitch="$(grep '^PostUp.*iptables' "$configfile")"
if [ ! "$haskillswitch" ]; then
	iptables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
	ip6tables -I OUTPUT ! -o wg0 -m mark ! --mark $(wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
fi
# https://old.reddit.com/r/WireGuard/comments/ekdi8w/wireguard_kill_switch_blocks_connection_to_nas/fda0ikp/
iptables -I OUTPUT -d 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16 -j ACCEPT

# deluge autologin
# https://dukrat.net/124/deluge-webui-1-3-6-autologin-disable-password
# default password is deluge
sed -i 's/this\.passwordField\.focus(true, 300)/this.onLogin()/' /usr/lib/python3/dist-packages/deluge/ui/web/js/deluge-all-debug.js

su $username -c 'deluged --config=/deluge-config -d' &
delugedpid=$!
su $username -c 'deluge-web --config=/deluge-config --interface=0.0.0.0 -d' &
delugewebpid=$!

sigterm() {
	# these are the pids of su, not of deluged and deluge-web
	kill $delugedpid $delugewebpid
	wait
}
trap sigterm TERM

wait
