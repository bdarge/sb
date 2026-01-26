#!/bin/sh

set -eu

# setup db secret
APP_NAMESPACE=sb-app
VAULT_DB_SECRET=sb-db
VAULT_DB_ROLE=sb-mysql-role
CONFIG_NAME=profile
APP_K8S_CONTEXT=bd@app
USERNAME="root"
VAULT_AUTH=k8s-auth
APP_SA=sb-sa


if ! vault secrets list | grep -q  "$VAULT_DB_SECRET/" ; then
   vault secrets enable -path=$VAULT_DB_SECRET database
   sleep 10
fi

if ! vault policy list | grep -q $VAULT_DB_ROLE ; then
vault policy write $VAULT_DB_ROLE - <<EOF
path "$VAULT_DB_SECRET/creds/$VAULT_DB_ROLE" {
   capabilities = ["read"]
}
EOF
fi

# get db port from k8s service
PORT=$(kubectl get svc -n sb-app --context $APP_K8S_CONTEXT sb-db-svc -o=jsonpath='{.spec.ports[0].port}')

# read db_url from k8s service
DB_URL=$(kubectl get svc -n $APP_NAMESPACE --context $APP_K8S_CONTEXT sb-db-svc -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

# read db's root cred from k8s secrets
PASSWORD=$(kubectl get secrets -n $APP_NAMESPACE --context $APP_K8S_CONTEXT db-root-secret -o=jsonpath='{.data.root-password}' | base64 -d)

vault write $VAULT_DB_SECRET/config/$CONFIG_NAME \
    plugin_name=mysql-database-plugin \
    allowed_roles=$VAULT_DB_ROLE \
    connection_url="{{username}}:{{password}}@tcp($DB_URL:$PORT)/" \
    username="$USERNAME" \
    password="$PASSWORD"

vault write $VAULT_DB_SECRET/roles/$VAULT_DB_ROLE \
    db_name=$CONFIG_NAME \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON *.* TO '{{name}}'@'%';" \
    default_ttl="2h" \
    max_ttl="24h"

vault write auth/$VAULT_AUTH/role/$VAULT_DB_ROLE \
   bound_service_account_names=$APP_SA \
   bound_service_account_namespaces=$APP_NAMESPACE \
   policies=$VAULT_DB_ROLE \
   token_period=2m \
   audience=vault
