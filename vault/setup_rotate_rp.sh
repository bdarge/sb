#!/bin/sh

use -eu

app_ns=sb-app
db_secret=sb-db
db_roles=sb-mysql-role
db_policy=sb-auth-policy-db
config_name=profile
context=bd@app

# setup db secret
db_secret=sb-db
db_roles=sb-mysql-role
db_policy=sb-auth-policy-db
config_name=profile

if ! vault secrets list | grep -q  "$db_secret/" ; then
   vault secrets enable -path=$db_secret database
   sleep 10
fi

if ! vault policy list | grep -q $db_policy ; then
vault policy write $db_policy - <<EOF
path "$db_secret/creds/$db_roles" {
   capabilities = ["read"]
}
EOF
fi

# get db port from k8s service
port=$(kubectl get svc -n sb-app --context $context sb-db-svc -o=jsonpath='{.spec.ports[0].port}')
# read db_url from k8s service
db_url=$(kubectl get svc -n $app_ns --context $context sb-db-svc -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
# read db's root cred from k8s secrets
password=$(kubectl get secrets -n $app_ns --context $context db-root-secret -o=jsonpath='{.data.root_password}' | base64 -d)
username="root"

vault write $db_secret/config/$config_name \
    plugin_name=mysql-database-plugin \
    allowed_roles=$db_roles \
    connection_url="{{username}}:{{password}}@tcp($db_url:$port)/" \
    username="$username" \
    password="$password"

vault write $db_secret/roles/$db_roles \
    db_name=$config_name \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

# add auth
app_sa=sb-sa
auth=k8s
db_auth_role=auth-role

vault write auth/$auth/role/$db_auth_role \
   bound_service_account_names=$app_sa \
   bound_service_account_namespaces=$app_ns \
   token_ttl=0 \
   token_period=120 \
   token_policies=$db_policy \
