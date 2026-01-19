#!/bin/bash

set -e

OPENVPN_DIR="/etc/openvpn"

echo "========================================="
echo "Initialisation du serveur OpenVPN"
echo "========================================="

# Vérifier si les certificats existent déjà
if [ ! -d "$OPENVPN_DIR/pki" ] || [ ! -f "$OPENVPN_DIR/pki/ca.crt" ]; then
    echo "Génération des certificats OpenVPN..."
    bash /generate-certs.sh
else
    echo "Certificats trouvés, passage de la génération"
fi

# Vérifier si la clé Diffie-Hellman existe
if [ ! -f "$OPENVPN_DIR/dh.pem" ]; then
    echo "Génération de la clé Diffie-Hellman (cela peut prendre du temps)..."
    openssl dhparam -out "$OPENVPN_DIR/dh.pem" 2048
fi

echo ""
echo "========================================="
echo "Certificats et clés générés:"
echo "========================================="
ls -la "$OPENVPN_DIR/pki/ca.crt" 2>/dev/null && echo "✓ CA" || echo "✗ CA manquant"
ls -la "$OPENVPN_DIR/pki/issued/server.crt" 2>/dev/null && echo "✓ Server Cert" || echo "✗ Server Cert manquant"
ls -la "$OPENVPN_DIR/pki/private/server.key" 2>/dev/null && echo "✓ Server Key" || echo "✗ Server Key manquant"
ls -la "$OPENVPN_DIR/dh.pem" 2>/dev/null && echo "✓ DH Parameters" || echo "✗ DH Parameters manquant"
ls -la "$OPENVPN_DIR/ta.key" 2>/dev/null && echo "✓ TLS Auth Key" || echo "✗ TLS Auth Key manquant"
echo ""

# Activer le IP forwarding (peut échouer en mode conteneur restreint)
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || echo "⚠ IP forwarding non accessible (attendu en Docker)"

# Configuration iptables pour NAT
echo "Configuration des règles iptables..."
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -o lo -j MASQUERADE 2>/dev/null || echo "⚠ iptables NAT non accessible"
iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT 2>/dev/null || echo "⚠ iptables FORWARD non accessible"
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true

echo ""
echo "========================================="
echo "Démarrage du serveur OpenVPN..."
echo "========================================="
exec openvpn --config "$OPENVPN_DIR/server.conf"
