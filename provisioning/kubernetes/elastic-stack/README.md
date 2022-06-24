#ELASTICSEARCH

This is enabled on Gitlab so that the search filter will be available under Operations -> Logs.

#Enabling Elasticsearch

To enable elasticsearch, go to the Gitlab Group you want it enabled. Select Kubernetes -> Select the cluster where you want Elasticsearch enabled. Click the Applications tab and click "Install" on the "Elastic Stack" Application.


To confirm if elasticsearch is enabled you can select a repository under the group you selected. In this case, you can go to whitelabels/mgm. Select Operations -> Logs you should then see a searchbar on the top of the logs.

#KIBANA

Sometimes Elasticsearch is now sufficient for filtering and graphing logs thus we need Kibana for better visualisation of the logs. Kibana will pull logs from Gitlab's Elasticsearch, this means we have to make sure elasticsearch on Gitlab is enabled. Kibana is not part of Gitlab's elastic stack yet for some reason. We can install Gitlab's Kibana using Helm.

#Installing Kibana

You can use the helm chart overrides under provisioning/kubernetes/elastic-stack/src

`helm install --name kibana gitlab/elastic-stack --values provisioning/kubernetes/elastic-stack/src/kibana-values.yaml --namespace gitlab-managed-apps`

Kibana will be installed at the gitlab-managed-apps namespace.

#Kibana Service

You can acces kibana by port forwarding to 5601

`kubectl port-forward svc/kibana-kibana 5601:5601 -n gitlab-managed-apps`

#Kibana Authentication

Kibana will pull logs from all the pods which means it stores sensitive information. This means we need to protect our Kibana and we need to force a login for users who visit the dashboard. We can port forward kibana on our localhost but it has no authentication option. We can use external authentication using OAuth from our google accounts.

First thing is to create a google auth by logging in at https://console.developers.google.com/apis/credentials?pli=1 using the cloudshareadmin@mydomain.com.

Create an Oauth2 Client ID. Application Type is Web Application. Make sure you authorize the domain you will use on the origin and redirect uri will be "https://yourdomain.mydomain.com/oauth2/callback"


Save the "Google Client ID" and "Google Client Secret" and save the values at provisioning/kubernetes/elastic-stack/src/kibana-oauth-values.yaml

Install the oauth2-proxy using helm with the overrides 

`helm install -f provisioning/kubernetes/elastic-stack/kibana-oauth-values.yaml  oauth2 --namespace gitlab-managed-apps stable/oauth2-proxy`

This will there will be an oauth2 pod and service running on port 80

Next is we need the ingress for kibana for this example, modify kibana-ingress.yaml to your preference. Change the domain values of these lines:

```
    nginx.ingress.kubernetes.io/auth-signin: https://yourdomain.mydomain.com/oauth2/start?rd=$escaped_request_uri
    nginx.ingress.kubernetes.io/auth-url: https://yourdomain.mydomain.com/oauth2/auth
...
spec:
  tls:
  - hosts:
    - yourdomain.mydomain.com
    secretName: kibana-tls-secret
  rules:
    - host: yourdomain.mydomain.com
```

You can then apply to create the ingress:

`kubectl apply -f provisioning/kubernetes/elastic-stack/src/kibana-ingress.yaml`

Next is to create the oauth ingress. Modify kibana-oauth-ingress.yaml and change the values accordingly to your want:


```
spec:
  rules:
  - host: yourdomain.mydomain.com
    http:
...
  tls:
  - hosts:
    - yourdomain.mydomain.com
    secretName:  oauth2-noc-tls
```

yourdomain.mydomain.com/oauth2 will then be pointed to the oauth2-proxy so that you can perform oauth.

Apply by: 

`kubectl apply -f provisioning/kubernetes/elastic-stack/src/kibana-oauth-ingress.yaml`
