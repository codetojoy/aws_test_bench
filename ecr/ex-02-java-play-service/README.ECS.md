
### Notes

* after publishing image to ECR, here are manual steps for ECS
    * this has been automated in ~/ecs/ex-06
* create cluster
* create task definition
    * Fargate, 0.5 vCPU, 3 GB
    * use ECR image from above
    * add port mapping for 9000
        * find default security group and add rule for 9000. e.g. 22.224.0.0/16
    * env var APPLICATION_SECRET with strong value from [here](https://jam.dev/utilities/random-string-generator)
    * env var MY_FOOBAR for a test value 
* in cluster, create task
    * go to Networking and find public IP address
    * visit http://PUBLIC_IP:9000

### TODO

* consider Secret Manager
* consider Terraform to create infra: basic
    * this has been automated in ~/ecs/ex-06
* consider Terraform with dedicated VPC, security group, etc
