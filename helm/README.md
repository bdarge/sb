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

## Install NFS CSI
```
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --set externalSnapshotter.enabled=true --set controller.runOnControlPlane=true --set controller.livenessProbe.healthPort=39653
```

```
kubectl apply -f storageclass-nfs.yaml
```

## Test NFS mounting
```
sudo mount -t nfs  node7.lan.odainfo.com:/mnt/k8s-data/nfs4 /home/bdarge/temp
```

## Test
```
vault write auth/kubernetes/login role=demo jwt=...
```

```
export VAULT_SKIP_VERIFY=false
```

## Install/Uninstall on k8s using helm

```console
helm install sb helm/ [--kube-context k8s-app@app] -f helm/values.yaml --namespace sb-app --create-namespace
```

```console
helm uninstall sb --namespace sb-app [--kube-context k8s-app@app]
```
