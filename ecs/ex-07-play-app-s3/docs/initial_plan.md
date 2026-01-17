
### Background

This is a simple webapp with Play Framework (in Java). It can be built for the following:

* local development via Java
* local development via Docker
* published to AWS ECR and AWS ECS (as a Fargate service) via Terraform
    * support for ALB and multiple replicas
    * see `main.tf`,  `outputs.tf`, `variables.tf`, etc in the main folder
* support for a simple S3 demo was completed in Phase 1
* next up is Phase 2 (below)

### Goals: Phase 1 [COMPLETE]

* We want to augment this simple example with another aspect of AWS.
* In this case, we want to illustrate usage of AWS S3.
* [COMPLETE] TODO 1: create a dedicated S3 bucket in Terraform
* [COMPLETE] TODO 2: add a new controller, `FileController` with an endpoint `listFiles()`
* [COMPLETE] TODO 3: add a new service, `FileService` with a method `listFiles()`
* [COMPLETE] TODO 4: `FileService.listFiles()` should use the AWS SDK to read the contents of the S3 bucket: e.g. file size, file upload date, and simple meta-data
* [COMPLETE] TODO 5: add a new route from `/files` to `FileController.listFiles()`
* [COMPLETE] TODO 6: add a new view, `app/views/files.scala.html` that lists the file info from `FileService.listFiles()`

### Goals: Phase 2

* We want to augment this simple example with another aspect of AWS.
* In this case, we want to illustrate usage of AWS Simple Secrets Manager (SSM).
* TODO 1: support a new secret name in Terraform, with key `test-bench-ex-07-secret`
* TODO 2: add a new controller, `SecretController` with an endpoint `getSecretValues()`
    * it should get the key-prefix from the environment, with a default of `test-bench`
* TODO 3: add a new service, `SecretService` with a method `getSecretValues(String keyPrefix)`
* TODO 4: `SecretService.getSecretValues()` should use the AWS SDK to read the secrets with keys who match the prefix
* TODO 5: add a new route from `/secrets` to `SecretController.getSecretValues()`
* TODO 6: add a new view, `app/views/secrets.scala.html` that lists secret info from `SecretService.getValues()`
