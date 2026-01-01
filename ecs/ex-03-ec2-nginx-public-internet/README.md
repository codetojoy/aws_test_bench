
### Summary

- create VPC with public (and private) subnet
- associate VPC to Internet Gateway
- use route table to Internet Gateway
- deploy EC2 instance in subnet 
    - AMI from [1]
    - Nginx from [2] via AMI marketplace
- associate public IP and Security Group that allows public ingress 

### Usage

* see main `README.md` for prerequisites and `my_setvars.sh`
* `./init.sh`
* optional: `. ./plan.sh`
* optional: `. ./state.sh`
* to execute:`./apply.sh`
* check AWS Console
    * navigate to EC2 dashboard
    * navigate to 'instances running' in your region
    * look for public IP address and navigate
    * observe Nginx homepage
* when done: `./destroy.sh`

### Resources

* [1] - AMI locator [here](https://cloud-images.ubuntu.com/locator/ec2/)
* [2] - Nginx Bitami [here](https://aws.amazon.com/marketplace/pp/prodview-lzep7hqg45g7k)
