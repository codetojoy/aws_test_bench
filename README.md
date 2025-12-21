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

* in a given example project:
* to initialize: `./init.sh`
* to plan (dry-run): `./plan.sh`
* to list state: `./state.sh`
* to apply changes to AWS: `./apply.sh`
* to tear down the example: `./destroy.sh`

### Credit

* [Claude](https://claude.ai)
* [this Udemy course](https://www.udemy.com/course/mastering-terraform-beginner-to-expert), "Terraform: The Complete Guide from Beginner to Expert" by Lauro Fialho Müller
