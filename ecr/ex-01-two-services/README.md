
### Summary

An example of using two services in Docker, where Foo service calls Bar service.

The goals:
* 1: test locally using Node JS
* 2: Dockerize and test locally
* 3: publish to AWS ECR
* 4: configure ECS to use these services

The current goal is goal 3.

### Usage: Goal 2

* in this folder, `./docker-network.sh`
* in `bar-service`, `./docker-build.sh` and `./docker-run.sh`
    * test with [this link](http://localhost:5150/api/message)
* in `foo-service`, `./docker-build.sh` and `./docker-run.sh`
    * test with [this link](http://localhost:3000)
    * observe simple HTML page that has info from Foo and Bar

### Usage: Goal 3

* in `./bar-service`:
    * `cp terraform.tfvars.example terraform.tfvars` and edit
    * `./init.sh`
    * `./plan.sh`
    * `./apply.sh`
* in `./foo-service`:
    * `cp terraform.tfvars.example terraform.tfvars` and edit
    * `./init.sh`
    * `./plan.sh`
    * `./apply.sh`

### Usage: Side Quest

* note that AMD64 is X84_64 in terms of Linux platforms
* goal: in AWS Console, create a task definition and ECS task that exercises `bar`
    * create cluster
        * Fargate, be careful about platform
    * create task definition
        * be sure to use role/profile that has perms for ECR
        * populate ECR image
    * create task in cluster 
    * ensure default security-group is open for 5150 (restricted by IP)
    * test: `curl http://PUBLIC_IP:5150/api/message`
        * where `PUBLIC_IP` is from EC2 instance
    * gotchas
        * huge cross-up between arm64 and amd64 (X86_64)
        * my TF wasn't updating the image in ECR
* goal: in AWS Console, create a task definition and ECS task that exercises `foo`
    * it did start, but didn't work, and now it won't start ? 

### Usage: Goal 4

* see video 102 in KG udemy course
* bar
    * publish Docker image to ECR
    * create task def
    * create cluster
    * create service 
        * use Service Connect and create namespace
            * client/server
            * port mapping: 5150
            * DNS name: `bar-service` (MEGA for later)
* foo
    * publish Docker image to ECR
    * create task def
    * create cluster
    * create service 
        * use Service Connect with previous namespace
            * client
            * port mapping: 3000
        * env var: `http://bar-service:5150`
* in EC2 -> Load Balancers create target group
    * register target for port 3000
* create ALB
    * listener/rule to forward 80 to target group
* configure foo to use ALB
* go to ALB and get domain name
* visit http://domain.amazon.com 

### Next

* consider scripting ECS assets with Terraform

### Brainstorm

* consider migrating foo and bar to Java
* that might have jlink possibilities

