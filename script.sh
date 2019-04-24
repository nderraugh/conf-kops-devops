#!/bin/zsh

set -v

export START_TIME=$(date)

export GCR_ACCOUNT=gcr-viewer
export GCR_CREDS_FILE=gcr-creds.json
export PROJECT=$(gcloud config get-value project)
export SERVICE_ACCOUNT_NAME=yoppworks-k8s-service-account
export KEY_FILE=~/.gcloud/kops-orkestra-53724d2ee5a8.json
export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export EDITOR=/usr/bin/nano
export KOPS_STATE_STORE=gs://kubernetes-clusters-yopp-kops-devops/

if [[ $(gem list -i spicy-proton) == false ]]; then gem install spicy-proton; fi

CLUSTER_NAME=$(ruby << EE
  require 'spicy-proton'
  puts Spicy::Proton.pair
EE
);

echo $CLUSTER_NAME

kops create cluster $CLUSTER_NAME.k8s.local --zones us-west1-b \
  --state $KOPS_STATE_STORE --project=$PROJECT \
  --kubernetes-version 1.12.7

kops update cluster $CLUSTER_NAME.k8s.local --yes

until sleep 5 && kops validate cluster
do
done

kubectl create serviceaccount dashboard -n default

kubectl create clusterrolebinding  dashboard-admin --clusterrole=cluster-admin --serviceaccount=default:dashboard

echo $(kubectl get secret -n default $(kubectl get serviceaccount -n default dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode)

echo

kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.10.1.yaml

kubectl create secret docker-registry gcr-json-key \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat ~/$GCR_CREDS_FILE)" \
  --docker-email=neil.derraugh@yoppworks.com

kubectl patch serviceaccount default \
  -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'

#kubectl proxy

echo http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade

export END_TIME=$(date)
echo started_at $START_TIME
echo ended_at   $END_TIME

