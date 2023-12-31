- decode base64
```console
echo cGFzc3dvcmQh | base64 --decode
```

## Helm:

- To install:
```console
helm secrets install sb helm/ -f helm/values.yaml -f helm/helm_vars/secrets.yaml
```

- To upgrade
```console
helm secrets upgrade sb helm/ -f helm/values.yaml -f helm/helm_vars/secrets.yaml
```

- Encrypt helm secrets with gpg
  https://medium.com/@Devopscontinens/encrypting-helm-secrets-7f37a0ccabeb
  `helm secrets enc secrets.yaml`


- How to transfer gpg keys
  https://stackoverflow.com/a/3176373
```console
ssh binyam@192.168.1.10 /usr/local/bin/gpg --export-secret-key bdarge | /usr/local/bin/gpg --import
```





