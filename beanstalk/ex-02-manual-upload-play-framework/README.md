
### Summary

* Manual creation of Beanstalk application in console.
* Simple Play app.

### Usage

* `./build-fat-jar.sh`
* in AWS Console
    - Beanstalk
    - Create Application
    - Left Nav: Applications
    - Create Application (again!)
    - Create Environment
        - web server
        - Java 21
        - upload file
        - define APPLICATION_SECRET with 256 chars
            - [1] e.g. with https://jam.dev/utilities/random-string-generator
    - Configure service
    - default VPC
    - default security group  
    - basic monitoring
    - disable managed platform updates 


