#! /bin/bash

cd /etc/opensearch
sudo rm -f *pem

# Root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=root.dns.a-record" -out root-ca.pem -days 730
# Admin cert
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=A" -out admin.csr
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days 730
# Node cert 1
openssl genrsa -out node1-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node1-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node1-key.pem
openssl req -new -key node1-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=node1.dns.a-record" -out node1.csr
echo 'subjectAltName=DNS:node1.dns.a-record' > node1.ext
openssl x509 -req -in node1.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node1.pem -days 730 -extfile node1.ext
# Node cert 2
openssl genrsa -out node2-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node2-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node2-key.pem
openssl req -new -key node2-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=node2.dns.a-record" -out node2.csr
echo 'subjectAltName=DNS:node2.dns.a-record' > node2.ext
openssl x509 -req -in node2.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node2.pem -days 730 -extfile node2.ext
# Client cert
openssl genrsa -out client-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out client-key.pem
openssl req -new -key client-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=client.dns.a-record" -out client.csr
echo 'subjectAltName=DNS:client.dns.a-record' > client.ext
openssl x509 -req -in client.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out client.pem -days 730 -extfile client.ext
# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node1-key-temp.pem
rm node1.csr
rm node1.ext
rm node2-key-temp.pem
rm node2.csr
rm node2.ext
rm client-key-temp.pem
rm client.csr
rm client.ext

# Convert node certificate
cat root-ca.pem node1.pem node1-key.pem > combined-node1.pem
echo "Enter password for node1-cert.p12"
openssl pkcs12 -export -in combined-node1.pem -out node1-cert.p12 -name node1
echo "Enter password for keystore.jks"
keytool -importkeystore -srckeystore node1-cert.p12 -srcstoretype pkcs12 -destkeystore keystore.jks

# Convert admin certificate
cat root-ca.pem admin.pem admin-key.pem > combined-admin.pem
echo "Enter password for admin-cert.p12"
openssl pkcs12 -export -in combined-admin.pem -out admin-cert.p12 -name admin
echo "Enter password for keystore.jks"
keytool -importkeystore -srckeystore admin-cert.p12 -srcstoretype pkcs12 -destkeystore keystore.jks

# Import certificates to truststore
keytool -importcert -keystore truststore.jks -file root-ca.cer -storepass changeit -trustcacerts -deststoretype pkcs12

# Cleanup
rm combined-admin.pem
rm combined-node1.pem

echo "plugins.security.ssl.transport.pemcert_filepath: node1.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.transport.pemkey_filepath: node1-key.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.transport.pemtrustedcas_filepath: root-ca.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.transport.enforce_hostname_verification: false" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.enabled: true" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.pemcert_filepath: node1.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.pemkey_filepath: node1-key.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.pemtrustedcas_filepath: root-ca.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.authcz.admin_dn:" | sudo tee -a /etc/opensearch/opensearch.yml
echo "  - 'CN=A,OU=UNIT,O=ORG,L=OSLO,ST=OSLO,C=CA'" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.nodes_dn:" | sudo tee -a /etc/opensearch/opensearch.yml
echo "  - 'CN=node1.dns.a-record,OU=UNIT,O=ORG,L=OSLO,ST=OSLO,C=CA'" | sudo tee -a /etc/opensearch/opensearch.yml
echo "  - 'CN=node2.dns.a-record,OU=UNIT,O=ORG,L=OSLO,ST=OSLO,C=CA'" | sudo tee -a /etc/opensearch/opensearch.yml
echo "discovery.type: single-node" | sudo tee -a /etc/opensearch/opensearch.yml
"