#!/bin/bash

set -e

OPENVPN_DIR="/etc/openvpn"
EASYRSA_DIR="/usr/share/easy-rsa"

# Vérifier si PKI existe déjà
if [ -d "$OPENVPN_DIR/pki" ] && [ -f "$OPENVPN_DIR/pki/issued/server.crt" ]; then
    echo "PKI déjà correctement initialisé"
    exit 0
fi

cd "$OPENVPN_DIR"

echo "Nettoyage de l'ancien PKI..."
rm -rf pki

echo "Initialisation de PKI..."
mkdir -p pki
EASYRSA_BATCH=yes EASYRSA="$EASYRSA_DIR" EASYRSA_PKI="$OPENVPN_DIR/pki" $EASYRSA_DIR/easyrsa init-pki

echo "Génération de la clé CA..."
EASYRSA_BATCH=yes EASYRSA="$EASYRSA_DIR" EASYRSA_PKI="$OPENVPN_DIR/pki" $EASYRSA_DIR/easyrsa build-ca nopass

echo "Génération du certificat serveur..."
EASYRSA_BATCH=yes EASYRSA="$EASYRSA_DIR" EASYRSA_PKI="$OPENVPN_DIR/pki" $EASYRSA_DIR/easyrsa gen-req server nopass
EASYRSA_BATCH=yes EASYRSA="$EASYRSA_DIR" EASYRSA_PKI="$OPENVPN_DIR/pki" $EASYRSA_DIR/easyrsa sign-req server server nopass

echo "Génération du certificat client..."
EASYRSA_BATCH=yes EASYRSA="$EASYRSA_DIR" EASYRSA_PKI="$OPENVPN_DIR/pki" $EASYRSA_DIR/easyrsa gen-req client1 nopass
EASYRSA_BATCH=yes EASYRSA="$EASYRSA_DIR" EASYRSA_PKI="$OPENVPN_DIR/pki" $EASYRSA_DIR/easyrsa sign-req client client1 nopass

echo "Génération de la clé TLS-auth..."
openvpn --genkey secret "$OPENVPN_DIR/ta.key"

echo ""
echo "========================================="
echo "Certificats générés avec succès!"
echo "========================================="
echo ""
echo "Fichiers créés:"
find "$OPENVPN_DIR/pki" -type f 2>/dev/null | while read f; do
    echo "  - $f"
done

echo ""
echo "Vérification des fichiers essentiels:"
test -f "$OPENVPN_DIR/pki/ca.crt" && echo "✓ CA Certificate" || echo "✗ CA Certificate MANQUANT"
test -f "$OPENVPN_DIR/pki/issued/server.crt" && echo "✓ Server Certificate" || echo "✗ Server Certificate MANQUANT"
test -f "$OPENVPN_DIR/pki/private/server.key" && echo "✓ Server Key" || echo "✗ Server Key MANQUANT"
test -f "$OPENVPN_DIR/ta.key" && echo "✓ TLS Key" || echo "✗ TLS Key MANQUANT"
