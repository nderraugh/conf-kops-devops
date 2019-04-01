# Setup

https://github.com/kubernetes/kops/blob/master/docs/tutorial/gce.md

[Quickstart](https://cloud.google.com/sdk/docs/quickstart-macos)

Install gcloud from the links.

`gcloud init`

pick your project.

generate a key.

creaet a bucket
`gsutil mb gs://kubernetes-clusters-yopp-kops-devops/`

enable compute engine API
`gcloud services enable --project $PROJECT compute.googleapis.com`

verify https://console.developers.google.com/apis/library/compute.googleapis.com?project=kops-orkestra&authuser=1

https://cloud.google.com/container-registry/docs/quickstart

`gcloud auth configure-docker`
