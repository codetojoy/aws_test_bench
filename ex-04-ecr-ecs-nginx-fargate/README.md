
### Summary

- create ECR repo
- publish simple Docker image to ECR repo
- create ECS service with simple Docker image
- using Fargate, create

### Usage

* see main `README.md` for prerequisites and `my_setvars.sh`
* copy `terraform.tfvars.example` to `terraform.tfvars` and customize
* `./init.sh`
* optional: `. ./plan.sh`
* optional: `. ./state.sh`
* to execute:`./apply.sh`
* when done: `./destroy.sh`

### Confirmation

* use `./get-task-ip.sh` to get IP address for browser
    * this is task only, so it can change
    * also: browse to ECS -> cluster -> tasks -> task instance -> Networking
* in AWS console, browse ECR
* in AWS console, browse ECS

