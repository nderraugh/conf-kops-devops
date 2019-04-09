# creating a cluster

```
export PROJECT=$(gcloud config get-value project)
export SERVICE_ACCOUNT_NAME=yoppworks-k8s-service-account
export KEY_FILE=~/.gcloud/kops-orkestra-53724d2ee5a8.json
export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export EDITOR=/usr/bin/nano
export KOPS_STATE_STORE=gs://kubernetes-clusters-yopp-kops-devops/
```

```
if [[ $(gem list -i spicy-proton) == false ]]; then gem install spicy-proton; fi

CLUSTER_NAME=$(ruby << EE
  require 'spicy-proton'
  puts Spicy::Proton.pair
EE
);

kops create cluster $CLUSTER_NAME.k8s.local --zones us-east1-b \
  --state $KOPS_STATE_STORE --project=$PROJECT \
  --master-size n1-standard-4 --node-size n1-standard-4 \
  --kubernetes-version 1.12.7
```

# setting up gcr credentials

`kubectl create secret docker-registry gcr-json-key \
--docker-server=gcr.io \
--docker-username=_json_key \
--docker-password="$(cat ~/$GCR_CREDS_FILE)" \
--docker-email=neil.derraugh@yoppworks.com`

```
kubectl patch serviceaccount default \
-p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'
```

# deleting a cluster

`kops delete cluster --name=$CLUSTER_NAME.k8s.local --state $KOPS_STATE_STORE --yes`

# creating coredns entries with kops

`kops edit cluster $CLUSTER_NAME.k8s.local`

Add the following to the config yaml:

```
spec:
  kubeDNS:
    provider: CoreDNS
```

```
kops update cluster $CLUSTER_NAME.k8s.local

kops update cluster $CLUSTER_NAME.k8s.local --yes


until sleep 5 && kops validate cluster
do
done
```

```
kubectl create serviceaccount dashboard -n default

kubectl create clusterrolebinding  dashboard-admin --clusterrole=cluster-admin --serviceaccount=default:dashboard

echo
kubectl get secret -n default $(kubectl get serviceaccount -n default dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode


kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.10.1.yaml

kubectl proxy

open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
