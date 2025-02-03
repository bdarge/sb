# sb


## How to build

- git submodule update --init

- `./build.sh -p` or for production `./build.sh`

## Database
generate migration script
```console
migrate create -ext sql -dir db/migrations add_account_table
```

## Install apps

### login to vault
- Export vault address, and skip cert verify values:
`export VAULT_SKIP_VERIFY=true`
`export VAULT_ADDR=https://192.168.50.76:8200` 
- Then login using vault token:
`vault login -tls-skip-verify`

### Setup vso

```console
./setup_vso.sh
```

### Install app using helm

```console
helm install sb helm/ --kube-context k8s-app@app -f helm/values.yaml --namespace sb-app --create-namespace
```

### Rotate db credential

```console
./rotate_rp.sh
```
