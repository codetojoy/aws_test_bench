
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

### Next

* continue with Udemy video 9x and work-along 

### Brainstorm

* consider migrating foo and bar to Java
* that might have jlink possibilities

