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
helm uninstall vault-secrets-operator  -n vault-secrets-operator-system --kube-context k8s-app@app
```

- Export vault address, and skip cert verify values:
`export VAULT_SKIP_VERIFY=true`
`export VAULT_ADDR=https://192.168.50.76:8200`

- Then login using vault token:
`vault login -tls-skip-verify`

- run vso setup
```console
./setup_vso.sh
```

- Rotate db credential through VSO

```console
./setup_rotate_rp.sh
```
