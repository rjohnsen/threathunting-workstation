#! /bin/bash

cd /etc/opensearch
sudo rm -f *pem
sudo openssl genrsa -out root-ca-key.pem 2048
sudo openssl req -new -x509 -sha256 -key root-ca-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=ROOT" -out root-ca.pem -days 730
sudo openssl genrsa -out admin-key-temp.pem 2048
sudo openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
sudo openssl req -new -key admin-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=A" -out admin.csr
sudo openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days 730
sudo openssl genrsa -out node1-key-temp.pem 2048
sudo openssl pkcs8 -inform PEM -outform PEM -in node1-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node1-key.pem
sudo openssl req -new -key node1-key.pem -subj "/C=CA/ST=OSLO/L=OSLO/O=ORG/OU=UNIT/CN=node1.dns.a-record" -out node1.csr
sudo sh -c 'echo subjectAltName=DNS:node1.dns.a-record > node1.ext'
sudo openssl x509 -req -in node1.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node1.pem -days 730 -extfile node1.ext
sudo rm -f *temp.pem *csr *ext
sudo chown opensearch:opensearch admin-key.pem admin.pem node1-key.pem node1.pem root-ca-key.pem root-ca.pem root-ca.srl

echo "plugins.security.ssl.transport.pemcert_filepath: /etc/opensearch/node1.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.transport.pemkey_filepath: /etc/opensearch/node1-key.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.transport.pemtrustedcas_filepath: /etc/opensearch/root-ca.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.enabled: true" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.pemcert_filepath: /etc/opensearch/node1.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.pemkey_filepath: /etc/opensearch/node1-key.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.ssl.http.pemtrustedcas_filepath: /etc/opensearch/root-ca.pem" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.allow_default_init_securityindex: true" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.authcz.admin_dn:" | sudo tee -a /etc/opensearch/opensearch.yml
echo "  - 'CN=A,OU=UNIT,O=ORG,L=Oslo,ST=Oslo,C=CA'" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.nodes_dn:" | sudo tee -a /etc/opensearch/opensearch.yml
echo "  - 'CN=node1.dns.a-record,OU=UNIT,O=ORG,L=Oslo,ST=Oslo,C=CA'" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.audit.type: internal_opensearch" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.enable_snapshot_restore_privilege: true" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.check_snapshot_restore_write_privileges: true" | sudo tee -a /etc/opensearch/opensearch.yml
echo "plugins.security.restapi.roles_enabled: [\"all_access\", \"security_rest_api_access\"]" | sudo tee -a /etc/opensearch/opensearch.yml