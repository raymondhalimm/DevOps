# Mission 2

Mission 1 and Mission2 might contain duplicate screenshots as RDS and Kubernetes Clusters are created using Terraform Script

# Custom Blockscout Helm Chart

Deploy the Blockscout Helm chart using custom values provided in myvalues.yaml.

This approach uses a custom myvalues.yaml file to override specific deployment settings.

The original chart can be found at the following GitHub repository: https://github.com/blockscout/helm-charts/tree/main/charts/blockscout-stack

# How to Use

## Pre-requisites

Run Mission 1 Terraform script to ensure the RDS and Kubernetes cluster is created. Any troubleshooting refer to Mission 1 README

## To use this customized Helm chart, run the following command:

helm install -f ./myvalues.yaml my-blockscout blockscout/blockscout-stack 

### To access the frontend and backend url

kubectl get svc

There will be an external IP for each service

### To connect frontend to backend

Open myvalues.yaml and navigate to the frontend section

Find the "env" section

Replace NEXT_PUBLIC_API_HOST value with backend url and NEXT_PUBLIC_APP_HOST value with frontend url

Upgrade after replacing the configuration in myvalues.yaml

helm upgrade my-blockscout blockscout/blockscout-stack -f myvalues.yaml

### To Enable HPA

Comment out the replicasCount field to ensure no conflict when using hpa to dynamically scale your pods

Find the HPA field under blockscout in myvalues.yaml and set enabled to true

Then apply these commands

kubectl apply -f hpa.yaml

helm upgrade my-blockscout blockscout/blockscout-stack -f myvalues.yaml 
