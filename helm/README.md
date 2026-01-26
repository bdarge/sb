
## Use helm to install on k8s

```console
helm install sb helm/ -f helm/values.yaml --namespace sb-app --create-namespace [--kube-context k8s-app@app]
```

```console
helm uninstall sb --namespace sb-app [--kube-context k8s-app@app]
```
