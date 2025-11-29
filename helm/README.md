
## Use helm to install on k8s

```console
helm install sb helm/ [--kube-context k8s-app@app] -f helm/values.yaml --namespace sb-app --create-namespace
```

```console
helm uninstall sb --namespace sb-app [--kube-context k8s-app@app]
```
