# Mission 1

Mission 1 and Mission 2 might contain duplicate screenshots as Kubernetes Cluster and RDS are created using Terraform Script

# To Run :

terraform fmt
terraform init
terraform validate
terraform apply

On the first apply process, there will be a failure because the kubernetes config is initialize at the previous config. Therefore, please RETRY by running

terraform apply

again, and on the second run the kubernetes config will be correctly initialize with the current config and kubernetes secrets will be successful.

DO NOT terraform destroy !
