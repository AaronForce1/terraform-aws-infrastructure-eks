# This should be done for every namespace for their related development environments.

echo "Creating K8S secrets with the CA private keys (will be used by the cert-manager CA Issuer)"

kubectl -n ${K8S_NS} create secret tls tls-ca-development-${K8S_NS} \
--key=${CA_CERTS_FOLDER}/${ENVIRONMENT_DEV}/rootCA-key.pem \
--cert=${CA_CERTS_FOLDER}/${ENVIRONMENT_DEV}/rootCA.pem

kubectl -n ${K8S_NS} create secret tls tls-ca-development-${K8S_NS} \
--key=.certs/rootCA-key.pem \
--cert=.certs/rootCA.pem