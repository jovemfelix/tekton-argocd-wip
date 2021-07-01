> Algumas atividades feitas usando ArgoCD com Teckton e repositório Bitbucket



## TO DEPLOY

```shell
$ sh make.sh
```



## Testing

```shell
# terminal 01
sh tests/view-logs.sh
{"level":"info","logger":"eventlistener","caller":"sink/sink.go:181","msg":"ResolvedParams : [{Name:nickname Value:Renato Felix} {Name:hash Value:5afc0dbd96e3ee448e326a15e61346c7de0382ee} {Name:url Value:https://bitbucket.org/rfelix80/simples/branch/master}]","knative.dev/controller":"eventlistener","/triggers-eventid":"2r6td","/trigger":""}
{"level":"info","logger":"eventlistener","caller":"resources/create.go:94","msg":"Generating resource: kind: &APIResource{Name:pipelineruns,Namespaced:true,Kind:PipelineRun,Verbs:[delete deletecollection get list patch create update watch],ShortNames:[pr prs],SingularName:pipelinerun,Categories:[tekton tekton-pipelines],Group:tekton.dev,Version:v1beta1,StorageVersionHash:RcAKAgPYYoo=,}, name: fuse-app-01-pipeline-","knative.dev/controller":"eventlistener"}
{"level":"info","logger":"eventlistener","caller":"resources/create.go:102","msg":"For event ID \"2r6td\" creating resource tekton.dev/v1beta1, Resource=pipelineruns","knative.dev/controller":"eventlistener"}

# terminal 02
$ sh tests/run-payload-branch_master.sh
Running run-payload-branch_master.sh
>> HOSTNAME=el-fuse-app-01-el-rfelix-cicd.apps.tim.rhbr-lab.com
{"eventListener":"fuse-app-01-el","namespace":"rfelix-cicd","eventID":"2r6td"}
```



## Dicas

1. Nome das tasks são únicos!

   ```properties
   Resource: "tekton.dev/v1beta1, Resource=pipelines", GroupVersionKind: "tekton.dev/v1beta1, Kind=Pipeline"
   Name: "fuse-app-01-pipeline", Namespace: "rfelix-cicd"
   for: "target/fuse-app-01/templates/pipeline.yaml": admission webhook "validation.webhook.pipeline.tekton.dev" denied the request: validation failed: expected exactly one, got both: spec.tasks[4].name
   ```

2. Erro de concorrência:

   > usar `runAfter`

   ```json
   + /ko-app/git-init -url git@bitbucket.org:rfelix80/fuse-app-01.git -revision develop -refspec '' -path /workspace/output/. -sslVerify=true -submodules=true -depth 0
   
   {"level":"error","ts":1624649318.1526377,"caller":"git/git.go:47","msg":"Error running git [init /workspace/output/.]: exit status 128\nfatal: cannot mkdir /workspace/output/.: Permission denied\n","stacktrace":"github.com/tektoncd/pipeline/pkg/git.run\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:47\ngithub.com/tektoncd/pipeline/pkg/git.Fetch\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/pkg/git/git.go:74\nmain.main\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/cmd/git-init/main.go:52\nruntime.main\n\t/usr/lib/golang/src/runtime/proc.go:203"}
   
   {"level":"fatal","ts":1624649318.152964,"caller":"git-init/main.go:53","msg":"Error fetching git repository: exit status 128","stacktrace":"main.main\n\t/opt/app-root/src/go/src/github.com/tektoncd/pipeline/cmd/git-init/main.go:53\nruntime.main\n\t/usr/lib/golang/src/runtime/proc.go:203"}
   ```

   

3. image.**pullPolicy**: `Always` vs `IfNotPresent` e uso de **hash**

## Nexus

```shell
$ oc expose deploy nexus3 --port=5000 --name=nexus-registry -n cicd
$ oc create route edge nexus-registry --service=nexus-registry --port=5000 -n cicd
```



> https://access.redhat.com/solutions/4395891

```
$ oc edit image.config.openshift.io/cluster

# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: config.openshift.io/v1
kind: Image
metadata:
  annotations:
    release.openshift.io/create-only: "true"
  creationTimestamp: "2021-04-06T20:21:21Z"
  generation: 1
  name: cluster
  resourceVersion: "76880402"
  selfLink: /apis/config.openshift.io/v1/images/cluster
  uid: f501ff95-38d6-483c-b4e9-279b11577672
spec: {}
status:
  internalRegistryHostname: image-registry.openshift-image-registry.svc:5000
```



```
curl -vv https://nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com:443/v2/
*   Trying 10.36.25.11...
* TCP_NODELAY set
* Connected to nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com (10.36.25.11) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/pki/tls/certs/ca-bundle.crt
  CApath: none
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (OUT), TLS alert, unknown CA (560):
* SSL certificate problem: self signed certificate in certificate chain
* Closing connection 0
curl: (60) SSL certificate problem: self signed certificate in certificate chain
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```



```
curl -vv https://nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com:443/v2/
*   Trying 10.36.25.11...
* TCP_NODELAY set
* Connected to nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com (10.36.25.11) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/pki/tls/certs/ca-bundle.crt
  CApath: none
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, [no content] (0):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server did not agree to a protocol
* Server certificate:
*  subject: CN=*.apps.tim.rhbr-lab.com
*  start date: Apr  6 20:27:07 2021 GMT
*  expire date: Apr  6 20:27:08 2023 GMT
*  subjectAltName: host "nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com" matched cert's "*.apps.tim.rhbr-lab.com"
*  issuer: CN=ingress-operator@1617740827
*  SSL certificate verify ok.
* TLSv1.3 (OUT), TLS app data, [no content] (0):
> GET /v2/ HTTP/1.1
> Host: nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com
> User-Agent: curl/7.61.1
> Accept: */*
>
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, [no content] (0):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS app data, [no content] (0):
< HTTP/1.1 401 Unauthorized
< Date: Sun, 27 Jun 2021 19:05:35 GMT
< Server: Nexus/3.31.0-01 (OSS)
< X-Content-Type-Options: nosniff
< Content-Security-Policy: sandbox allow-forms allow-modals allow-popups allow-presentation allow-scripts allow-top-navigation
< X-XSS-Protection: 1; mode=block
< WWW-Authenticate: BASIC realm="Sonatype Nexus Repository Manager"
< Docker-Distribution-Api-Version: registry/2.0
< Content-Type: application/json
< Content-Length: 113
< Set-Cookie: 8d8737c6e9d993da54a730e2ee40c826=42870e38d2c7e6f893dbab30ae31298c; path=/; HttpOnly; Secure; SameSite=None
<
* Connection #0 to host nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com left intact
{"errors":[{"code":"UNAUTHORIZED","message":"access to the requested resource is not authorized","detail":null}]}
```



```
oc create configmap nexus-registry-config \
  --from-file=nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com=tls.crt \
  -n openshift-config
```



```yaml
apiVersion: config.openshift.io/v1
kind: Image
metadata:
  annotations:
    release.openshift.io/create-only: 'true'
  creationTimestamp: '2021-04-06T20:21:21Z'
  generation: 8
  managedFields:
    - apiVersion: config.openshift.io/v1
      fieldsType: FieldsV1
      fieldsV1:
        'f:metadata':
          'f:annotations':
            .: {}
            'f:release.openshift.io/create-only': {}
        'f:spec': {}
      manager: cluster-version-operator
      operation: Update
      time: '2021-04-06T20:21:21Z'
    - apiVersion: config.openshift.io/v1
      fieldsType: FieldsV1
      fieldsV1:
        'f:status':
          .: {}
          'f:internalRegistryHostname': {}
      manager: cluster-image-registry-operator
      operation: Update
      time: '2021-05-31T19:54:05Z'
    - apiVersion: config.openshift.io/v1
      fieldsType: FieldsV1
      fieldsV1:
        'f:spec':
          'f:additionalTrustedCA':
            .: {}
            'f:name': {}
          'f:allowedRegistriesForImport': {}
      manager: Mozilla
      operation: Update
      time: '2021-06-27T19:58:28Z'
  name: cluster
  resourceVersion: '113768093'
  selfLink: /apis/config.openshift.io/v1/images/cluster
  uid: f501ff95-38d6-483c-b4e9-279b11577672
spec:
  additionalTrustedCA:
    name: nexus-registry-config
  allowedRegistriesForImport:
    - domainName: nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com
status:
  internalRegistryHostname: 'image-registry.openshift-image-registry.svc:5000'
```



```shell
$ oc api-resources --api-group='bitnami.com'
NAME                      SHORTNAMES   APIGROUP      NAMESPACED   KIND
sealedsecretcontrollers                bitnami.com   true         SealedSecretController
sealedsecrets                          bitnami.com   true         SealedSecret
```

```
kubectl create secret -n rfelix-cicd docker-registry nexus-registry-secret \
  --docker-server=nexus-registry.rfelix-cicd.svc.cluster.local:5000 \
  --docker-username=admin \
  --docker-password=admin123 --dry-run='client' -o yaml


kubectl create secret -n rfelix-cicd docker-registry nexus-secret \
  --docker-server=nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com \
  --docker-username=admin \
  --docker-password=admin123 --dry-run='client' -o yaml

Failed to pull image "nexus-registry.rfelix-cicd.svc.cluster.local:5000/rfelix-cicd/fuse-app-01:latest": 
rpc error: code = Unknown desc = error pinging 
docker registry nexus-registry.rfelix-cicd.svc.cluster.local:5000: 
Get "https://nexus-registry.rfelix-cicd.svc.cluster.local:5000/v2/": 
dial tcp: lookup nexus-registry.rfelix-cicd.svc.cluster.local: no such host


Failed to pull image "nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com/rfelix-cicd/fuse-app-01:latest": rpc error: code = Unknown desc = error pinging docker registry nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com: Get "https://nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com/v2/": x509: certificate signed by unknown authority


Failed to pull image "nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com/rfelix-cicd/fuse-app-01:latest": rpc error: code = Unknown desc = error pinging docker registry nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com: Get "https://nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com/v2/": x509: certificate signed by unknown authority'

Failed to pull image "nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com/rfelix-cicd/fuse-app-01:latest": rpc error: code = Unknown desc = error pinging docker registry nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com: Get "https://nexus-registry-rfelix-cicd.apps.tim.rhbr-lab.com/v2/": x509: certificate signed by unknown authority


Failed to pull image "nexus-registry.rfelix-cicd.svc.cluster.local:5000/rfelix-cicd/fuse-app-01:latest": rpc error: code = Unknown desc = error pinging docker registry nexus-registry.rfelix-cicd.svc.cluster.local:5000: Get "https://nexus-registry.rfelix-cicd.svc.cluster.local:5000/v2/": dial tcp: lookup nexus-registry.rfelix-cicd.svc.cluster.local: no such host

```



```
kubeseal --controller-namespace=sealed-secrets  --cert tests/cert.pem -f ci/argocd/bitbucket-secret.yaml -w ci/argocd/bitbucket-secret-x.yamloc get
```





## Example to create secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-git-secret
  annotations:
    tekton.dev/git-0: github.com
type: kubernetes.io/ssh-auth
data:
  # cat ~/.ssh/<your-git-private-key> | base64
  ssh-privatekey: <base64 encoded>
  # cat ~/.ssh/known_hosts | base64
  known_hosts: <base64 encoded>
```



## Referência

* OpenShift Pipelines - https://openshift.github.io/pipelines-docs/docs/0.10.5/index.html
* Unable to pull image from image registry and fails with x509 certificate issue - https://access.redhat.com/solutions/5915911
  * https://docs.openshift.com/container-platform/4.6/registry/configuring-registry-operator.html
  * https://docs.openshift.com/container-platform/4.6/openshift_images/image-configuration.html#images-configuration-allowed_image-configuration
* CronJob cleanup - https://github.com/tektoncd/pipeline/issues/2332
  * **failedBuildsHistoryLimit** and **successfulBuildsHistoryLimit** https://docs.okd.io/latest/rest_api/workloads_apis/buildconfig-build-openshift-io-v1.html