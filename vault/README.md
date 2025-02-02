## Install vault-secrets-operator (VSO)  

```console
helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault-secrets-operator-system --create-namespace --values vault-operator-values.yaml --kube-context k8s-app@app
```
### uninstall

```console
helm uninstall vault-secrets-operator  -n vault-secrets-operator-system --kube-context k8s-app@app
```

## Install NFS

```console
helm install --kube-context k8s-app@app csi-driver-nfs2 csi-driver-nfs/csi-driver-nfs --namespace kube-system --set driver.name="nfs2.csi.k8s.io" --set controller.name="csi-nfs2-controller" --set rbac.name=nfs2 --set serviceAccount.controller=csi-nfs2-controller-sa --set serviceAccount.node=csi-nfs2-node-sa --set node.name=csi-nfs2-node --set node.livenessProbe.healthPort=39653
```

Inter app k8s cert in vault
```console
kubectl config view --raw --minify --flatten \
       -o jsonpath='{.clusters[].cluster.certificate-authority-data}' --context k8s-app@app | base64 -d
```

