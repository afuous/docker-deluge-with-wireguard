FROM alpine:edge

RUN apk add deluge wireguard-tools openresolv procps iptables curl iproute2
# openresolv and procps are needed by wg-quick, iptables is needed for killswitch

ENTRYPOINT ["/entrypoint.sh"]
