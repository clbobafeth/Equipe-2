FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y bind9 bind9-dnsutils && \
    rm -rf /var/lib/apt/lists/*

# Copie de la configuration BIND9
COPY config/ /etc/bind/

EXPOSE 53/udp 53/tcp

# Lancement en foreground
CMD ["named", "-g"]
