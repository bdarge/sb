# sb


### docker-compose

Run `Makefile` to test the app in docker locally.

### K8s

1. Setup Vault Secret Operator (vso)

- Export vault address, and skip cert verify values:
`export VAULT_SKIP_VERIFY=true`
`export VAULT_ADDR=https://192.168.50.76:8200`

- Then login using vault token:
`vault login -tls-skip-verify`

- run vso setup
```console
./setup_vso.sh
```

2. Install to k8s using helm

```console
helm install sb helm/ [--kube-context k8s-app@app] -f helm/values.yaml --namespace sb-app --create-namespace
```

3. Rotate db credential

```console
./rotate_rp.sh
```
