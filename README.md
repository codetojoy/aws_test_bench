### aws_test_bench

Some examples of using Terraform to create examples in AWS.

These examples are simple and modest, but not guaranteed to be in the free tier of AWS. Please review all examples thoroughly. Some examples may require a subscription to AMI (e.g. nginx).

NOTE: The spirit of the examples is [SSCCE](https://sscce.org/). For experimentation only, and not recommended for production.

### Prerequisites

* `terraform` via Homebrew
* `awscli` via Homebrew
* root AWS account

### Usage: Setup

* create IAM user in AWS
* generate access keys
* copy `setvars.sh` to `my_setvars.sh`
* edit `my_setvars.sh`
* `chmod +x my_setvars.sh`
* `. ./my_setvars.sh`
* test with `./test_keys.sh`
* never commit `my_setvars.sh` (it is in `.gitignore`)

### Usage per example

* see local `README.md`
* in a given example project:
* to initialize: `./init.sh`
* to plan (dry-run): `./plan.sh`
* to list state: `./state.sh`
* to apply changes to AWS: `./apply.sh`
* to tear down the example: `./destroy.sh`

### index of examples

* the best examples, as of 01-JAN-2026
* `ecr/ex-01-two-services`	
    * two services: Foo and Bar
    * tiny apps in Node JS
    * Foo runs on port 3000 and calls Bar on port 5150
    * publishes to ECR
    * useful for manual practice re: [3] especially re: Service Connect (near video 100)
* `ecr/ex-02-java-play-service`
    * Play Framework
    * tiny webpage with IP address, timestamp, etc 
    * useful for manual practice re: [3] especially services (or tasks)
    * see section 7
* `ecs/ex-06-ecr-ecs-java-play-one-service`
    * this is the ECS version of `ecr/ex-02...`
    * Terraform for both ECR and ECS: the full-meal deal

### Credit

* [1] - [Claude](https://claude.ai)
* [2] - [this Udemy course](https://www.udemy.com/course/mastering-terraform-beginner-to-expert), "Terraform: The Complete Guide from Beginner to Expert" by Lauro Fialho Müller
* [3] - [this Udemy course](https://www.udemy.com/course/elastic-container-service-ecs-aws-devops-docker-2025/?couponCode=2021PM20) "Amazon Elastic Container Service (ECS)| DevOps| Docker |2025" by Karan Gupta
