FROM ubuntu:22.04

# Installation des dépendances essentielles
RUN apt-get update && apt-get install -y \
    openvpn \
    easy-rsa \
    openssl \
    iptables \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/openvpn

# Copie des fichiers essentiels
COPY entrypoint.sh /entrypoint.sh
COPY generate-certs.sh /generate-certs.sh
COPY ../server.conf /etc/openvpn/server.conf

RUN chmod +x /entrypoint.sh /generate-certs.sh

EXPOSE 1194/udp

ENTRYPOINT ["/entrypoint.sh"]
