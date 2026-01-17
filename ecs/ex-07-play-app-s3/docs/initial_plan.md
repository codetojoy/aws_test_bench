
### Background

This is a simple webapp with Play Framework (in Java). It can be built for the following:

* local development via Java
* local development via Docker
* published to AWS ECR and AWS ECS (as a Fargate service) via Terraform
    * support for ALB and multiple replicas
    * see `main.tf`,  `outputs.tf`, `variables.tf`, etc in the main folder

### Goal

* We want to augment this simple example with another aspect of AWS.
* In this case, we want to illustrate usage of AWS S3.
* TODO 1: create a dedicated S3 bucket in Terraform
* TODO 2: add a new controller, `FileController` with an endpoint `listFiles()`
* TODO 3: add a new service, `FileService` with a method `listFiles()`
* TODO 4: `FileService.listFiles()` should use the AWS SDK to read the contents of the S3 bucket: e.g. file size, file upload date, and simple meta-data
* TODO 5: add a new route from `/files` to `FileController.listFiles()`
* TODO 6: add a new view, `app/views/files.scala.html` that lists the file info from `FileService.listFiles()`
