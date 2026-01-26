#!/bin/sh

set -ue

APP_K8S=https://192.168.50.30:6443
VAULT_AUTH=k8s-auth
APP_SA=sb-sa
APP_ROLE=sb-role
APP_NAMESPACE=sb-app
APP_POLICY=sb
SECRETS=kvv2

TRANSIT=sb-transit
TRANSIT_KEY=vso-client-cache
CACHE_POLICY=auth-policy-operator
OPERATOR_ROLE=auth-role-operator
OPERATOR_SA=vso-operator-sa
OPERATOR_NAMESPACE=vault-secrets-operator-system


if ! vault auth list | grep -q $VAULT_AUTH ; then
  vault auth enable -path $VAULT_AUTH kubernetes
   
  #  sleep 20

  KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten \
      -o jsonpath='{.clusters[].cluster.certificate-authority-data}' \
      | base64 -d)

  vault write auth/$VAULT_AUTH/config \
        kubernetes_host="$APP_K8S" \
        disable_local_ca_jwt=true \
        kubernetes_ca_cert="$KUBE_CA_CERT"
fi

vault write auth/$VAULT_AUTH/role/$APP_ROLE \
   bound_service_account_names=$APP_SA \
   bound_service_account_namespaces=$APP_NAMESPACE \
   policies=$APP_POLICY \
   token_period=2m \
   audience=vault

vault write auth/$VAULT_AUTH/role/$OPERATOR_ROLE \
   bound_service_account_names=$OPERATOR_SA \
   bound_service_account_namespaces=$OPERATOR_NAMESPACE \
   token_ttl=0 \
   token_period=120 \
   token_policies=$CACHE_POLICY \
   audience=vault

# transit
if ! vault secrets list | grep -q  "$TRANSIT/" ; then
   vault secrets enable -path=$transit transit
   vault write -force $transit/keys/$TRANSIT_KEY
fi

if ! vault policy list | grep -q $CACHE_POLICY ; then
   vault policy write $CACHE_POLICY - <<EOF
path "$transit/encrypt/$TRANSIT_KEY" {
   capabilities = ["create", "update"]
}
path "$transit/decrypt/$TRANSIT_KEY" {
   capabilities = ["create", "update"]
}
EOF
fi


# setup secret
if ! vault secrets list | grep -q  "$SECRETS/" ; then
   vault secrets enable -path=$SECRETS kv-v2
   sleep 10
fi

# write app policy
if ! vault policy list | grep -q $APP_POLICY ; then
   vault policy write $APP_POLICY - <<EOF
path "$SECRETS/data/$APP_NAMESPACE/*" {
   capabilities = ["read", "list", "subscribe"]
   subscribe_event_types = ["kv*"]
}
path "sys/events/subscribe/kv*" {
   capabilities = ["read"]
}
EOF
fi

# create vso auth to k8s vault
kubectl apply -f ./vault-auth.yaml

# create static secrets
kubectl apply -f ./static-secret-vso.yaml
