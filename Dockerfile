FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y wireguard-tools iproute2 iptables dante-server curl openresolv && \
    rm -rf /var/lib/apt/lists/*

# Dante configuration
ADD dante.conf /etc/dante/dante.conf

# Startup script
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 1080
ENTRYPOINT ["/usr/local/bin/start.sh"]
