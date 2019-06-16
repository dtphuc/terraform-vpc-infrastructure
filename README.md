# A Practical Example

This guide will show you how to create Dcore Node and the whole infrastructure with Terraform. The system will have 4 subnets (2 public subnets and 2 private subnets) to span across 2 AZs to archive HA in case of one AZ is failed. I recommend you need to have at least 2 AZs when deploying application. You can refer the image which I also attached here.

I will use Application Load Balancer in the public subnet to handle the traffic to Dcore (ALB support Web Socket). The Dcore Node will be on the private subnet and it will only be accessible through the ALB. This mean that we won’t have direct access to make connections (for example, SSH) on the server. In order to access via SSH an instance on a private subnet, we have a bastion host (We will run Ansible playbooks in Bastion also). Thus, we will create the bastion host on the public subnet.

Following Immutable Server Pattern, I use Packer and Ansible to bake 2 AMIs for Bastion and Dcore Node

* The Bastion AMI will be baked with most common tools (netcat, jq, wget,curl, so on) and Ansible to be able to run Playbooks from here.

* The Dcore AMI will be baked with most common tools like Bastion and also install Docker to be able to spin up service from Docker image.

Because we have sensitive data there so that I use KMS to encrypt all the EBS volumes to protect the data inside every EC2 instances.

## Directory Structure

I have "infrastructure" directory which contains code to create VPC/Network ACL and have different directory for every environments (dev, prod, uat, etc). Each of this directory contains code to use shared modules and create a different architecture for each environment. This is my personal approach using Terraform. The structure is like below:

```sh
infrastructure/
    dev/
      main.tf     # main file contains the VPC modules need to be run
      output.tf   # output of VPC resources
      vars.tf     # contains variable for VPC resources
      backend.tf  # store the terraform state for infrastructure. 
    prod/
      main.tf     # main file contains the VPC modules need to be run
      output.tf   # output of VPC resources
      vars.tf     # contains variable for VPC resources
      backend.tf  # store the terraform state for infrastructure. 
environment/
    dev/          # provision AWS resources for DEV environment
      main.tf     # main file contains all the necessary modules need to be run
      output.tf   # output of every resources
      vars.tf     # contains variable for every resources
      backend.tf  # store the terraform state for application.
    prod/         # provision AWS resources for Prod environment
      main.tf     # main file contains all the necessary modules need to be run
      output.tf   # output of every resources
      vars.tf     # contains variable for every resources
      backend.tf  # store the terraform state for application.
keys/
      dev_keypair.pub  # public key import to AWS Keypair in Dev 
      prod_keypair.pub # public key import to AWS Keypair in Prod
modules/
      bastion/          # Bastion template modules
      cloudwatch-logs/  # CloudWatch-Logs template module
      alb/              # ALB template module
      asg/              # ASG template module
      iam_role/         # IAM Role template module
      iam_user_groups/  # IAM User/Group template module
      s3bucket/         # S3 Bucket template module
      network-acl       # Network ACL module
      vpc/              # VPC template module
templates/         
      bastion-userdata.sh.tpl  # Userdata to run in bastion host
      dcore-userdata.sh.tpl    # userdata to run in ASG Dcore Nodes.
      dev_policy.json          # IAM Policy for Group Dev
      tester_policy.json       # IAM Policy for Group Tester
      ec2_policy               # IAM Policy for EC2 Instance Profile Role
```

## Note

Because I don't have the data to mount and a genesis file to run Dcore Node. Therefore, I just start docker from nginx image without data mount point to test and make sure that we can spin up Docker from userdata. To be able to run Dcore image with bind mount, I also configured Terraform to read the data mount point and retrieve that value in userdata. Here is what I follow:

1. Userdata script

```sh
#!/usr/bin/bash

systemctl start docker

# Configure ${mount_dir} as a variable
# docker run --rm --name DCore -d \
#         -p 8090:8090 \
#         -p 40000:40000 \
#         --mount type=bind,src=${mount_dir},dst=/root/.decent/data \
#         decentnetwork/dcore.ubuntu

# This is just used to test to make sure port 8090 work well.
docker run --rm --name Nginx -d \
        -p 8090:8080 \
        bitnami/nginx:latest
```

2. Terraform template file

As you can see, We will define variable "mount_dir" in Terraform.
The /opt/dcore is already baked within AMI with Packer.

```sh
data "template_file" "configure_app" {
  	template = "${file("${path.module}/../../templates/dcore-userdata.sh.tpl")}"
  	vars {
		mount_dir = "/opt/dcore"
	}
}
```

## Prerequisites

1. [Packer](https://www.packer.io/downloads.html)
2. [Terraform](https://www.terraform.io/downloads.html)
3. [Configure AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

Example of AWS Credentials after configuration
```
[default]
aws_access_key_id = <your_access_key>
aws_secret_access_key = <your_secret_access_key>
region = eu-west-1
```

## Setup

1.Checkout the source code

```sh
$ git clone https://github.com/dtphuc/terraform-dcore.git
```

2.Create a DynamoDB table "terraform-locking" with Primary key (LockID). This will be useful when you have many members working in same tfstate.

3.Create S3 bucket with two folders (infrastructure, environment) to store Terraform state and then configure Terraform like below:

environment/dev/backend.tf

```sh
terraform {
    backend "s3" {
        bucket         = "awslabs-tfstate-123"
        key            = "environment/dev_dcore.tfstate"
        region         = "ap-southeast-1"
        encrypt        = "true"
        dynamodb_table = "terraform-locking"
    }
}

data "terraform_remote_state" "dev_vpc" {
  backend = "s3"
  config {
    bucket         = "awslabs-tfstate-123"
    key            = "infrastructure/env_dev_dcore.tfstate"
    region         = "ap-southeast-1"
    encrypt        = "true"
    dynamodb_table = "terraform-locking"
  }
}

```

infrastructure/dev/backend.tf

```sh
terraform {
    backend "s3" {
        bucket         = "awslabs-tfstate-123"
        key            = "infrastructure/env_dev_dcore.tfstate"
        region         = "ap-southeast-1"
        encrypt        = "true"
        dynamodb_table = "terraform-locking"
    }
}
```


## Configure

All these values that you may need to change it. 

* bastion_amd_id: you can change to your AMI when built out from Packer
* aws_image_id: Dcore Node AMI.
* custom_security_group: You can change to your IP to be able to access ALB.

```sh
variable "bastion_ami_id" {
  description = "AMI of Bastion Host"
  default     = "ami-0310794100e4f4d59"
}
variable "aws_image_id" {
  description = "AWS AMI to be used for Dcore Node"
  default     = "ami-09ca247aaaa584bca"
}
variable "custom_security_group" {
  description = "List of IP Address can be allowed to access ALB"
  default = ["1.54.5.245/32", "42.114.143.216/32"]
}
```

### First Module: Create VPC and Networking

We will create the VPC firstly. This will be responsible for creating the networking pieces of our infrastructure, like VPC, subnets, routing table, NAT Gateway and NACL.

* Initializing

```sh
$ cd terraform-dcore
$ terraform init terraform/infrastructure/dev

Initializing modules...- module.dev_vpc
- module.dev_vpc_nacl

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

* Planning

After initializing , we will produce a plan for changing resources to match the current configuration to have a human operator review the plan, to ensure it is acceptable.

```sh
$ terraform plan terraform/infrastructure/dev

Acquiring state lock. This may take a few moments...
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + module.dev_vpc.aws_eip.eip_nat_gateway[0]
      id:                                          <computed>
      allocation_id:                               <computed>
      association_id:                              <computed>
............
............
............
Plan: 27 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

Releasing state lock. This may take a few moments...
```

* Deploying

After planning, you can review the infrastructure before running "terraform apply" to make changes. To make changes happen, we will run the command:

```sh

$ terraform apply -auto-approve terraform/infrastructure/dev  
```

After applied, you can see the output like below:

```sh
Apply complete! Resources: 27 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

private_subnet_cidr_blocks = [
    10.0.11.0/24,
    10.0.12.0/24
]
private_subnet_ids = [
    subnet-0cea55f8c155e6890,
    subnet-052892c3f6bb772e9
]
public_subnet_cidr_blocks = [
    10.0.11.0/24,
    10.0.12.0/24
]
public_subnet_ids = [
    subnet-00dc28e648117a56f,
    subnet-014ec7c471b746f78
]
vpc_cidr_block = 10.0.0.0/16
vpc_id = vpc-0b40cf31401ec17d0
vpc_name = Dev-Dcore
vpc_route_tables = [
    rtb-0eea6183a377ee70c,
    rtb-05154f776eb34572b,
    rtb-0b41b086822a0c8bf
]
```

## Second Module: Dcore App

After the VPC is setup, we will go next step to create our application there. That will include Bastion Host, ALB, ASG for DCore Node, IAM User/Group/Role, S3 Bucket, so on.

* Initializing

```sh
$ terraform init terraform/environment/dev

Initializing modules...
- module.bastion
- module.dcore-s3
- module.dcore-cloudwatch-logs
- module.dcore-iam
- module.dcore-group-devs
- module.dcore-group-testers
- module.dcore-alb
- module.dcore-asg

Initializing the backend...
Backend configuration changed!

Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.
```

You will be asked something like
```sh
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "s3" backend to the
  newly configured "s3" backend. An existing non-empty state already exists in
  the new backend. The two states have been saved to temporary files that will be
  removed after responding to this query.
  
  Previous (type "s3"): /var/folders/9n/jc70fh5d5lj0tb58mxmt9wlc0000gn/T/terraform667596685/1-s3.tfstate
  New      (type "s3"): /var/folders/9n/jc70fh5d5lj0tb58mxmt9wlc0000gn/T/terraform667596685/2-s3.tfstate
  
  Do you want to overwrite the state in the new backend with the previous state?
  Enter "yes" to copy and "no" to start with the existing state in the newly
  configured "s3" backend.

  Enter a value: 
```
The reason is because we just use "default" workspace when we initialized "infrastructure" tfstate when setup VPC in the last command. Now Terraform detects there is an existing state and ask us to overwrite it or not. We will enter value "no" to let terraform configure new backend "s3".

* Planning

After successfully initializing, you will run "terraform plan" to see what changes

```sh
$ terraform plan terraform/environment/dev     

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.template_file.configure_app: Refreshing state...
data.terraform_remote_state.vpc: Refreshing state...
data.terraform_remote_state.dev_vpc: Refreshing state...
data.aws_availability_zones.available: Refreshing state...
data.aws_availability_zones.available: Refreshing state...
data.aws_subnet_ids.private_subnet_ids: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:
......
......
......
Plan: 27 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

* Deploying

```sh
$ terraform apply -auto-approve terraform/environment/dev
```

You will see something like below after applied
```sh
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

bastion_public_ip = 18.139.55.43
cloudwatch_logs_arn = arn:aws:logs:ap-southeast-1:243773237814:log-group:awslabs-dcore-logs:*
dev_group = devs
dev_username = developer1
lb_dns_name = dev-Dcore-Nodes-1915572024.ap-southeast-1.elb.amazonaws.com
lb_zone_id = Z1LMS91P8CMLE5
s3_bucket_arn = arn:aws:s3:::awslabs-dcore
target_group_name = Dcore-Nodes-f988e48121893b2b-86
tester_group = testers
tester_username = tester1
```

## Contact

If you have any trouble when deploying it, please feel free to contact me dangphuc1302@gmail.com