- Encrypt helm secrets with gpg
  https://medium.com/@Devopscontinens/encrypting-helm-secrets-7f37a0ccabeb

- Transfer gpg keys
  https://stackoverflow.com/a/3176373
```console
ssh binyam@192.168.1.10 /usr/local/bin/gpg --export-secret-key bdarge | /usr/local/bin/gpg --import
```

- decode base64
```console
echo cGFzc3dvcmQh | base64 --decode
```

- install sb via helm:
```console
helm secrets install sb helm/ -f helm/values.yaml -f helm/helm_vars/secrets.yaml
```

-  Mount iscsi logical volume to troubleshooting
```console
pi@nfs:~ $ sudo mount /dev/tecmint_iscsi/tecmint_lun1 /mnt/fcroot -o rw,user
```



