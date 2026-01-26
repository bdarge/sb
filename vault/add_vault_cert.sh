#!/bin/sh

set -ue

# add vault cert in app k8s

VSO_NAMESPACE=vault-secrets-operator-system
APP_NAMESPACE=sb-app
SECRET_NAME=vault-crt
VAULT_NAMESPACE=vault
VAULT_K8S_CONTEXT=k8s@vault


# get vault server's cert
CERT_KEY=$(kubectl get secrets --context $VAULT_K8S_CONTEXT -n $VAULT_NAMESPACE vault-server-tls \
    -o jsonpath='{.data.ca\.crt}' | base64 -d)

# add it in vso ns
kubectl create secret generic $SECRET_NAME \
    --namespace ${VSO_NAMESPACE} \
    --from-literal=ca.crt="$CERT_KEY"

# add it in vso app ns
kubectl create secret generic $SECRET_NAME \
    --namespace ${APP_NAMESPACE} \
    --from-literal=ca.crt="$CERT_KEY"
