
### Usage: localdev

* copy `setvars.sh` to `my_setvars.sh`
* edit `my_setvars.sh`
* `chmod +x my_setvars.sh`
* `. ./my_setvars.sh`
* `./run.sh`

### Usage: localdev Docker

* copy `setvars.sh` to `my_setvars.sh`
* edit `my_setvars.sh`
* `chmod +x my_setvars.sh`
* `. ./my_setvars.sh`
* `./docker-build.sh`
* `./docker-run.sh`

### Usage: ECS

* copy `setvars.sh` to `my_setvars.sh`
* edit `my_setvars.sh`
* `chmod +x my_setvars.sh`
* copy `terraform.tfvars.example` to `terraform.tfvars`
* edit `terraform.tfvars`
* `. ./my_setvars.sh`
* `./build-fat-jar.sh`
* `./tf-init.sh`
* `./tf-plan.sh`
* `./tf-apply.sh`
    * this can take several iterations for the container to start
    * often errors between ECS and ECR, but it even happens when done manually  
* go to EC2 -> Load Balancers and look for DNS name (A record)
    * browse to http://DNS_NAME (no port necessary)
    * refresh to see private IP change as various instances are reached

* tear-down is `./tf-destroy.sh`
    * this will fail at ECR repo level, requiring images to be deleted

### Summary

* Completed Goals:
    * 0. [COMPLETE] read an example env-var and include in HTML page
    * 1. [COMPLETE] test existing deployment of Docker image to ECR with Terraform
    * 2. [COMPLETE] refactor ECR Terraform to prepare for ECS Terraform
        * Claude and I decided this wasn't necessary
    * 3. [COMPLETE] build ECS architecture by Terraform configuration
        * observe that we already have: Docker image can be created and pushed to ECR
        * for the following actions (later), note: 
            * use default VPC
            * use default Security Group
        * create ECS cluster
        * create ECS task definition
            * launch-type: Fargate
            * instance size: 0.5 vCPU, 3 GB
            * use ECR image from this project
            * add port mapping for 9000 on HTTP
            * define environment varable `APPLICATION_SECRET` with value of `default`
            * define environment variable `MY_FOOBAR` with value of `default`
            * disable log collection
    * 3.1 [COMPLETE] tweaks to Goal 3
        * set environment variable `APPLICATION_SECRET` to a value from the local machine
        * set environment variable `MY_FOOBAR` to a value from the local machine
* Current Goal:
    * TBD
* Backlog:
    * 4. read a secret from Secret Manager
* Notes
    * this project was spawned from ~/ecr/ex-02-java-play-service

