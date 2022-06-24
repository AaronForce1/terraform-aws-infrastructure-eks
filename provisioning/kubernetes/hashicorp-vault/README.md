# VAULT
## VAULT SETUP AND UNSEAL
After building the cluster, we need to port forward vault and init:

`kubectl port-forward service/<vault-service> 8200:8200 --address 0.0.0.0`


Next we init vault from web url otherwise you can vault operator init which wont require you to submit gpg keys but will generate the keys and output to your terminal:

*It is recommended to init with GPG keys that can be shared across DevOps team members:*
- Aaron Baideme
- Ronel Cartas
- Clayton Stevenson
- Diederik Damen
- Dan Helyar

```bash
export VAULT_ADDR=http://localhost:8200
vault operator init
```
This will then output 5 unseal key and a root token. Open your browser and browse for http://localhost:8200 input the master token and input the 5 unseal key next. Issue a vault status:

```bash
vault status

Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.6.1
```
It should show that vault is already unsealed.

## AWS Auto-Seal *(optional)*

Configuring the terraform variable `enable_aws_vault_unseal` to `true` will allow you to leverage AWS keys for automatic unsealing. That said, even with KMS auto-unseal, you will still need to run `vault operator init` upon first initialisation.

https://learn.hashicorp.com/tutorials/vault/autounseal-aws-kms
> The initialization generates recovery keys (instead of unseal keys) when using auto-unseal. Some of the Vault operations still require Shamir keys. For example, to regenerate a root token, each key holder must enter their recovery key. Similar to unseal keys, you can specify the number of recovery keys and the threshold using the -recovery-shares and -recovery-threshold flags. It is strongly recommended to initialize Vault with PGP.

Make sure that both vault pods are unsealed - in this example we are using dev1
Port forward to the first pod which is the master node and then make sure it is unsealed
```bash
kubectl port-forward pods/dev1-0 8200:8200 --address 0.0.0.0 -n hashicorp
export VAULT_ADDR=http://127.0.0.1:8200
vault status
vault operator init \
    -recovery-shares=4 \
    -recovery-threshold=2 \
    -recovery-pgp-keys="aaron.baideme.asc,ronel.cartas.asc,clayton.stevenson.asc,dan.helyar.asc,diederik.damen.asc" \
    -root-token-pgp-key="aaron.baideme.asc"
```
**Example Output**
```bash
Recovery Key 1: iz1XWxe4CM+wrOGqRCx8ex8kB2XvGJEdfjhXFC+MA6Rc
Recovery Key 2: rKZETr6IAy686IxfO3ZBKXPDAOkkwkpSepIME+bjeUT7
Recovery Key 3: 4XA/KJqFOm+jzbBkKQuRVePEYPrQe3H3TmFVmdlUjRFv
Recovery Key 4: lfnaYoZufP0uhooO3mHDAKGNZB5HLP9HYYb+LAfKkUmd
Recovery Key 5: L169hHj3DMpphGsOnS8TEz3Febvdx3vsG3Xr8kGWdUtW

Initial Root Token: s.AWnDagUkKNNbvkENiL72wysn

Success! Vault is initialized

Recovery key initialized with 5 key shares and a key threshold of 3. Please
securely distribute the key shares printed above.
```

## Configure Kubernetes Auth Capabilities Deployment Integration
The example below assumes the service account required is named `vault` however - for ETS, we typically use a service account named `{app}-{namespace}-{tfenv}-service-account`. The serviceaccount must be made in the default namespace and this functions as the anchor to auth between vault and k8s.

Create the service account to be used by your pods that needs the secret
```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: <SERVICE ACCOUNT NAME>
    namespace: default
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: <SERVICE ACCOUNT NAME>
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["*"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: <SERVICE ACCOUNT NAME>
roleRef:
  kind: Role
  name: <SERVICE ACCOUNT NAME>
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: <SERVICE ACCOUNT NAME>
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <SERVICE ACCOUNT NAME>
  namespace: default
```

```bash
kubectl apply -f k8s-auth-role.yaml

# Port forward via vault service
kubectl port-forward -n hashicorp svc/vault-eks-ets... 8200:8200
export VAULT_ADDR=http://127.0.0.1:8200

export VAULT_SA_NAME=$(kubectl -n hashicorp get sa -l app.kubernetes.io/name=vault -o jsonpath="{..secrets[*]['name']}")

export SA_JWT_TOKEN=$(kubectl -n hashicorp get secret $VAULT_SA_NAME \
    -o jsonpath="{.data.token}" | base64 --decode; echo)

export SA_CA_CRT=$(kubectl -n hashicorp get secret $VAULT_SA_NAME \
    -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)    

# Use kubectl cluster-info to get the kubernetes master API url which should be exported as:
export K8S_HOST=$(kubectl config view --minify | grep server | sed "s/^.*http/http/g")
# Activate kubernetes authentication method
vault auth enable kubernetes

# Create the hashicorp role you need - this will have a read permission on your secret/ keystore
vault write auth/kubernetes/role/<ROLE NAME> \
  bound_service_account_names=<SA NAMES, COMMA SEPARATED> \
  bound_service_account_namespaces="*" \
  policies="secret-reader" \
  ttl=1h

# Create k8s-manager policy
vault policy write k8s-manager provisioning/kubernetes/hashicorp-vault/files/k8s-manager.hcl 
```

**IMPORTANT: If using EKS version 1.21 and above we need to add `disable_iss_validation=true` as an option.**
```bash
vault write auth/kubernetes/config \
        token_reviewer_jwt="$SA_JWT_TOKEN" \
        kubernetes_host="$K8S_HOST" \
        kubernetes_ca_cert="$SA_CA_CRT" \
        disable_iss_validation=true
```

**NOTE: If using EKS earlier than version 1.21, use this setting.**
```bash
vault write auth/kubernetes/config \
        token_reviewer_jwt="$SA_JWT_TOKEN" \
        kubernetes_host="$K8S_HOST" \
        kubernetes_ca_cert="$SA_CA_CRT"
```

## OIDC SETUP FOR VAULT
Next is to enable OIDC on vault. Enter the root token when logging in:
```bash
vault login
Token (will be hidden): *********

vault auth enable oidc
Success! Enabled oidc auth method at: oidc/
```

Next is we need to create the vault OIDC roles, we have `oidc-manager` `secret-manager` and `secret-reader` hcl files #that we can apply:

#### Create new policy oidc-manager:
```bash
vault policy write oidc-manager provisioning/kubernetes/hashicorp-vault/files/oidc-manager.hcl
Success! Uploaded policy: oidc-manager
```
#### Create new policy secret-manager:
```bash
vault policy write secret-manager provisioning/kubernetes/hashicorp-vault/files/secrets-manager.hcl 
Success! Uploaded policy: secret-manager
```
#### Create new policy secret-reader:
```bash
vault policy write secret-reader provisioning/kubernetes/hashicorp-vault/files/secrets-reader.hcl 
Success! Uploaded policy: secret-reader
```

#### Create default vault oidc configuration:
This should be configured within Google Cloud: APIs and Services (https://console.cloud.google.com/apis);
   - the `AUTH0_DOMAIN` domain should be the OAUTH provider; in our main case it is `https://accounts.google.com`
   - the `VAULT_URL` should reflect the domain standard configured by our helm chart: `https://vault.{app_namespace}-{tvenv}.{root_domain_name}`

```bash
export AUTH0_DOMAIN=https://accounts.google.com
export VAULT_URL=https://vault.<APP_NAMESPACE>-<TFENV>.<ROOT>
```

The folowing specifications should be used when configuring a new OAuth API Client in GCP (https://console.cloud.google.com/apis/credentials):

1. Application Type: `Web Application`
2. Name: `vault-{app_name}-{app_namespace}-{tfenv}
3. Authorized Javascript Origins: `https://vault.{app_namespace}-{tfenv}.{root_domain_name}`
4. Authorized Redirect URIs:
    - `https://vault.{app_namespace}-{tfenv}.{root_domain_name}/ui/vault/auth/oidc/oidc/callback`
    - `https://vault.{app_namespace}-{tfenv}.{root_domain_name}/oidc/callback`

```bash
vault write auth/oidc/config \
        oidc_discovery_url="$AUTH0_DOMAIN" \
        oidc_client_id="$AUTH0_CLIENT_ID" \
        oidc_client_secret="$AUTH0_CLIENT_SECRET" \
        default_role="secret-manager"
Success! Data written to: auth/oidc/config
```

#### Create the default vault oidc role:
```bash
vault write auth/oidc/role/secret-reader \
        bound_audiences="$AUTH0_CLIENT_ID" \
        allowed_redirect_uris="$VAULT_URL/ui/vault/auth/oidc/oidc/callback" \
        allowed_redirect_uris="$VAULT_URL/oidc/callback" \
        user_claim="sub" \
        policies="secret-reader"
```
The default role is pointed to reader that only have a read-only policy. You can then create two more roles to manage OIDC and the secrets.

```bash
vault write auth/oidc/role/secret-manager \
        bound_audiences="$AUTH0_CLIENT_ID" \
        allowed_redirect_uris="$VAULT_URL/ui/vault/auth/oidc/oidc/callback" \
        allowed_redirect_uris="$VAULT_URL/oidc/callback" \
        user_claim="sub" \
        policies="secret-manager"

vault write auth/oidc/role/oidc-manager \
        bound_audiences="$AUTH0_CLIENT_ID" \
        allowed_redirect_uris="$VAULT_URL/ui/vault/auth/oidc/oidc/callback" \
        allowed_redirect_uris="$VAULT_URL/oidc/callback" \
        user_claim="sub" \
        policies="oidc-manager"
```
#### Vault Secret Pod Injection
```
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com

# Install the vault-operator to the hashicorp namespace
helm upgrade --namespace hashicorp --install vault-operator banzaicloud-stable/vault-operator --wait

# Next, install the mutating webhook with Helm into its own namespace (to bypass the catch-22 situation of self mutation)
helm upgrade --namespace hashicorp --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook --wait

```

## References
> https://banzaicloud.com/blog/inject-secrets-into-pods-vault-revisited/
> https://learn.hashicorp.com/tutorials/vault/agent-kubernetes

## TODO
> https://learn.hashicorp.com/tutorials/vault/pki-engine
