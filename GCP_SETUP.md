# Setup

https://github.com/kubernetes/kops/blob/master/docs/tutorial/gce.md

[Quickstart](https://cloud.google.com/sdk/docs/quickstart-macos)

Install gcloud from the links.

`gcloud init`

pick your project.

generate a key.

create a bucket
`gsutil mb gs://kubernetes-clusters-yopp-kops-devops/`

enable compute engine API
`gcloud services enable --project $PROJECT compute.googleapis.com`

verify https://console.developers.google.com/apis/library/compute.googleapis.com?project=kops-orkestra&authuser=1

https://cloud.google.com/container-registry/docs/quickstart

`gcloud auth configure-docker`

### setting up a service account for k8s to pull from GCR
`export GCR_ACCOUNT=gcr-viewer`
`export GCR_CREDS_FILE=gcr-creds.json`
`gcloud iam service-accounts create $GCR_ACCOUNT`

`gcloud projects add-iam-policy-binding $PROJECT --member "serviceAccount:$GCR_ACCOUNT@$PROJECT.iam.gserviceaccount.com" --role "roles/owner"`

`gcloud iam service-accounts keys create $GCR_CREDS_FILE --iam-account $GCR_ACCOUNT@$PROJECT.iam.gserviceaccount.com`

