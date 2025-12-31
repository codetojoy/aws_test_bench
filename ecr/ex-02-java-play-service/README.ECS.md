
### Notes

* after publishing image to ECR, here are manual steps for ECS
* create cluster
* create task definition
    * Fargate, 0.5 vCPU, 3 GB
    * use ECR image from above
    * add port mapping for 9000
        * find default security group and add rule for 9000. e.g. 22.224.0.0/16
    * env var APPLICATION_SECRET with strong value from [here](https://jam.dev/utilities/random-string-generator)
* in cluster, create task
    * go to Networking and find public IP address
    * visit http://PUBLIC_IP:9000

### TODO

* consider Secret Manager
* consider Terraform to create infra: basic
* consider Terraform with dedicated VPC, security group, etc
