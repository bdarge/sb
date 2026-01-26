## Install vault-secrets-operator (VSO)  

```console
helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault-secrets-operator-system --create-namespace --values vault-operator-values.yaml [--kube-context k8s-app@app]
```

To setup vso, in this project root dir, after running `vault login`:
```console
./setup_vso.sh
```

### uninstall

```console
helm uninstall vault-secrets-operator  -n vault-secrets-operator-system [--kube-context k8s-app@app]
```

- Export vault address, and skip cert verify (`-tls-skip-verify`) if you don't have the server cert:
```
  export VAULT_ADDR=https://192.168.50.77:8200
  vault login
```

Add vault k8s's cert in app k8s:

```console
./add_vault_cert.sh
```

Setup auth, roles, and static and dynamic secret vault secret values


```console
./setup_vso.sh
```

After sb-app has been installed, setup a rotating mysql db credential through VSO

```console
./refresh_db_pw.sh
```

Add then run `kubectl apply -f ./dynamic-secret-vso.yaml` to add a dynamic vso secret type to generate a secret which contains a new connection string every 24 hours.
