#!/bin/sh

set -ue

# Run 'vault login' before running this script
KUBERNETES_CLUSTER=https://192.168.50.30
KUBERNETES_PORT_443_TCP_ADDR=https://192.168.50.30:6443
k8s_context=bd@app
app_ns=sb-app
app_sa=sb-sa
app_role=sb-role
app_name=sb-app
app_policy=sb
auth=k8s
secrets=kvv2
transit=sb-transit
key=vso-client-cache
cache_policy=auth-policy-operator
operator_role=auth-role-operator
operator_sa=vso-operator-sa
operator_ns=vault-secrets-operator-system

# setup vault access
if ! vault auth list | grep -q $auth ; then
   vault auth enable -path $auth kubernetes
   sleep 20

   vault write auth/$auth/config \
         kubernetes_host="$KUBERNETES_PORT_443_TCP_ADDR" \
         disable_local_ca_jwt=true
fi

# setup secret
if ! vault secrets list | grep -q  "$secrets/" ; then
   vault secrets enable -path=$secrets kv-v2
   sleep 10
fi

# write app policy
if ! vault policy list | grep -q $app_policy ; then
   vault policy write $app_policy - <<EOF
path "$secrets/data/$app_name/db-root" {
   capabilities = ["read"]
}
path "$secrets/data/$app_name/jwt-key" {
   capabilities = ["read"]
}
path "$secrets/data/$app_name/git-token" {
   capabilities = ["read"]
}
path "kvv2/data/$app_policy/cloudflare_api_token" {
   capabilities = ["read"]
}
path "$secrets/data/$app_name/ghcr" {
   capabilities = ["read", "list", "subscribe"]
   subscribe_event_types = ["kv*"]
}
path "sys/events/subscribe/kv*" {
   capabilities = ["read"]
}
EOF
fi

# create app ns
kubectl get namespace --context $k8s_context | grep -q "^$app_ns" || kubectl create namespace $app_ns --context $k8s_context

# add app role
vault write auth/$auth/role/$app_role \
   bound_service_account_names=$app_sa \
   bound_service_account_namespaces=$app_ns \
   policies=$app_policy \
   token_period=2m

# transit
if ! vault secrets list | grep -q  "$transit/" ; then
   vault secrets enable -path=$transit transit
   vault write -force $transit/keys/$key
fi

if ! vault policy list | grep -q $cache_policy ; then
   vault policy write $cache_policy - <<EOF
path "$transit/encrypt/$key" {
   capabilities = ["create", "update"]
}
path "$transit/decrypt/$key" {
   capabilities = ["create", "update"]
}
EOF
fi

vault write auth/$auth/role/$operator_role \
   bound_service_account_names=$operator_sa \
   bound_service_account_namespaces=$operator_ns \
   token_ttl=0 \
   token_period=120 \
   token_policies=$cache_policy \
   audience=vault


# setup vso
kubectl apply -f ./vault-auth.yaml --context $k8s_context

# create static secrets
kubectl apply -f ./static-secret-vso.yaml --context $k8s_context

# create dynamic secrets
kubectl apply -f ./dynamic-secret-vso.yaml --context $k8s_context
