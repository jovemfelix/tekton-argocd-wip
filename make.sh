set -x

export NS_NAME=rfelix-cicd

### CI
oc -n $NS_NAME apply -f ci/argocd
helm template ci/sil/fuse-app-01/ --name-template fuse-app-01-pipeline  --namespace $NS_NAME --output-dir target/ci/
oc -n $NS_NAME apply -f target/ci/fuse-app-01/templates


# nexus
#oc kustomize tools/nexus-3x/base | oc -n $NS_NAME apply -f -
#source tools/nexus-3x/scripts/nexus-functions; add_nexus2_redhat_repos admin admin123 http://nexus3-rfelix-cicd.apps.tim.rhbr-lab.com/

### CD
helm template cd/sil/fuse-app-01/ --name-template fuse-app-01  --namespace $NS_NAME --output-dir target/cd/
oc -n $NS_NAME apply -f target/cd/fuse-app-01/templates

# Promote Image
helm template ci/sil/promoteapp --name-template fuse-app-01-promote --namespace rfelix-cicd --output-dir target/ci/
