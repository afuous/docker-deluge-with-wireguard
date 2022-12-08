FROM debian:unstable

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y deluged deluge-web wireguard-tools openresolv procps iptables
# openresolv and procps are needed by wg-quick, iptables is needed for killswitch
RUN apt-get install -y curl iproute2

ENTRYPOINT ["/entrypoint.sh"]
