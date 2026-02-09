# sb

## docker-compose

Use the `Makefile` to test the app in docker locally on watch mode. Add `.env` which contains the currency API token:

```
EXC_TOKEN={value goes here}
```

Then do `make up` to run docker compose in dev/watch mode

## k8s

1. Install NFS

```console
helm install --kube-context k8s-app@app csi-driver-nfs2 csi-driver-nfs/csi-driver-nfs --namespace kube-system --set driver.name="nfs2.csi.k8s.io" --set controller.name="csi-nfs2-controller" --set rbac.name=nfs2 --set serviceAccount.controller=csi-nfs2-controller-sa --set serviceAccount.node=csi-nfs2-node-sa --set node.name=csi-nfs2-node --set node.livenessProbe.healthPort=39653
```


2. Setup Vault Secret Operator (vso)

See, [here](vault/README.md) on how to install Vault Secret Operator


Add app k8s cert in vault k8s authentication method
```console
kubectl config view --raw --minify --flatten \
       -o jsonpath='{.clusters[].cluster.certificate-authority-data}' --context [k8s-app@app] | base64 -d
```

3. Install cert manager

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.1/cert-manager.yaml
```

4. Install on k8s using helm

```console
helm install sb helm/ -f helm/values.yaml --set "app.email=[email@example.com]" --namespace sb-app --create-namespace [--kube-context k8s-app@app]
```
To uninstall:
```console
helm uninstall sb --namespace sb-app [--kube-context k8s-app@app]
```

High level view of how this app deployed on a local k8s cluster:

![alt text](image.png)