# Mission 2

Mission 1 and Mission2 might contain duplicate screenshots as RDS and Kubernetes Clusters are created using Terraform Script

# Custom Blockscout Helm Chart

Deploy the Blockscout Helm chart using custom values provided in myvalues.yaml.
This approach uses a custom myvalues.yaml file to override specific deployment settings.
The original chart can be found at the following GitHub repository: https://github.com/blockscout/helm-charts/tree/main/charts/blockscout-stack

## How to Use

To use this customized Helm chart, run the following command:

helm install -f ./myvalues.yaml my-blockscout blockscout/blockscout-stack 
