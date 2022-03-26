#! /usr/bin/env bash
C=DE
ST=RLP
L=Gundersheim
O=ORVEUS
OU=ORVEUS
CN=orveus.csrz.de
SUBJ=/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN

# Copy the created file out of the container to the host filesystem
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl/ssl_certificate.key -out ssl/ssl_certificate.crt -subj "$SUBJ"
