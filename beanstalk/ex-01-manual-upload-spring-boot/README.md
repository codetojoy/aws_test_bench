
### Summary

* Manual creation of Beanstalk application in console.
* Simple Spring Boot app.

### Usage

* `./build-for-deploy.sh`
    - will include `Procfile` with fat jar
* in AWS Console
    - Beanstalk
    - Create Application
    - Left Nav: Applications
    - Create Application (again!)
    - Create Environment
        - web server
        - Java 21
        - upload file
    - Configure service
    - default VPC
    - default security group  
    - basic monitoring
    - disable managed platform updates 


