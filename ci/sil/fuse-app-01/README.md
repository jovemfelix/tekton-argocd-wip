```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sil-pipeline
  namespace: openshift-gitops
spec:
  project: ci
  source:
    repoURL: 'git@bitbucket.org:rfelix80/devops-config.git'
    path: ci/sil/fuse-app-01
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: sil-dev
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd-pipeline
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: 'git@bitbucket.org:rfelix80/devops-config.git'
    path: ci/argocd
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: openshift-gitops
  syncPolicy:
    automated: { }
    syncOptions:
      - CreateNamespace=true
```
