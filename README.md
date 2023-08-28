# Full CI

This project is to create a CI solution using Terraform, Circle-CI, Ansible, AWS, and Docker

# Intro
An automated way to deploy a webapp. Currently it uses or more EC2 instances interfaced from a load balancer.

It can accomodate multiple environments

#  Design
s3 buckets are used for storing the terraform state files. One per environment. All s3 buckets are managed in one terraform workspace

## AWS resources for one environment:
Each environment is in AWS and contains:
1. instances
2. Security group for instances
3. target group
4. load balancer and listener
5. Security group for load balancer

## Instances
Each instance has local packages and docker. The webapp is running in a docker container on the instance.

Each environment can have as many instances as you want. They will round robin through the subnets.

## Docker file
The webapp is in a local python file and built to an image.

## Docker Image
Stored on dockerhub
(Todo: Create versioning for docker image)

## Workspaces/Environments
Each environment is managed using a terraform workspace. The statefile is stored in the s3 bucket for that environment. 
> To avoid a circular dependancy problem, s3 buckets are part of a seperate terraform workspace called s3bucket

Any number of environments can be created, but it is recommended to create:
1. dev
2. test
3. prod
4. feature or stage as needed. Destroy them when done.

Environments each need an `<env>.tfvars` file to store their configs. Make sure to specify this file when running terraform.

# Setup Overview

## Prerequisites
Install these into your dev environment:
1. terminal (I used _wsl_ and _wt_ on windows)
2. GIT
2. terraform
2. awscli
3. ansible
4. docker
6. IDE (I used VSC)

## Set up s3 buckets
These need to exist before any other infrastructure because terraform's state is stored in them.

## Set up of an environment

To create a new environment:
 1. create a workspace 
 2. create s3 bucket using s3 workspace
 3. select environment workspace
 3. init terraform for environment
 4. apply terriform to build instances and load balancer
 5. for each instance, run ansible playbook to install docker.
 6. for each instance, run ansible playbook to pull and run webapp docker image.
 7. test each instacne by navigating to public DNS.
 8. navigate to load balancer public DNS to test.

# Setup of S3 Buckets
Only need to do this once at the beginning. This will set up _dev_, _test_, and _prod_ environments. If more are needed, add to main.tf before setting up.
> Warning: Do not do this except at creation because it could delete statefiles for environments if done after those environments are set up.
## Setup procedure
1. Create workspace
```bash
cd tf/s3bucket
terraform workspace new s3bucket
```
2. Verify in s3bucket workspace
```bash
terraform workspace list
```
3. Add more environments into list in _main.tf_ in this file if needed.
4. Run terraform
```bash
terraform init
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

# Setup Full Instructions per Environment
## 1. Setup s3 bucket
Instructions for setting up the initial configs stored in variables and s3 bucket for a new environment
1. Select the workspace and verify it is selected:
```bash
cd tf
terraform workspace select s3bucket
terraform workspace list
```
2. In the `tf` directory, create a `<env>.tfvars` file (example: `dev.tfvars`) in `tf` directory for your new environment. 
> See `example.tfvars.bak` for usage
```bash
cd tf
cp example.tfvars.bak prod.tfvars
```
3. Modify file and configurations.
3. Change directory into the s3bucket dirctory and create the symlink to them variables in the main directory.
```bash
cd s3bucket
ln -s ../dev.tfvars prod.tfvars
```
4. Verify: cat to make sure it shows your variables
```bash
cat prod.tfvars
```
5. From the s3bucket directory initialize terriform
```bash
terraform init
```
6. Create s3bucket:
```bash
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```


> The bucket will need to be rebuilt if a policy or IAM role is added. For example if you want to add a new dev.
> cd tf/s3bucket
> terrafrom init 
> 1. `terraform plan -var-file="prod.tfvars`
> 2. `terraform apply -var-file="prod.tfvars`

## 2. Create Workspace

1. Create new workspace
```bash
terraform workspace new prod
```

## 3 Setup AWS Environment
1. Select and verify the workspace
```bash
terraform workspace select prod
terraform workspace list
```
2. Initialize the terraform. The environment needs to match the workspace. This will create the statefile in the bucket
```bash
cd tf
terraform init -migrate-state \
  -backend-config="bucket=<your-bucket-name>" \
  -backend-config="key=<path/state/terraform.tfstate>" \
  -backend-config="region=us-west-2"
```

> When you are creating for the first time, use `terraform -migrate-state \` as first line, but answer no when it asks if you want to migrate the state.

Example:
```bash
terraform init -migrate-state \
  -backend-config="bucket=henry808-webserver-s3bucket-prod" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=us-west-2"
```

3. Create ec2 instances and load balancer using terraform:
```bash
terraform plan -var-file="prod.tfvars"
```

 > public DNS for instances and load balancers are output when you run the terraform launcher. Instance DNS' are output for debugging.

4. Ansible scripts for installing docker and then for installing the webapp via docker.

> First Set all hosts in playbook to environment: prod_webservers, test_webservers, or dev_webservers

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/install_docker.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/install_docker_webapp.yaml
```
5. Navigate to http://<LB public DNS>//:8080

# Developing the Webapp

## App Dev Workflow Overview
1. Edit Python file
2. build the docker image
3. run the docker image locally and test it
4. push image to dockerhub
5. (Optional) create a feature environment
6. deploy to a dev environment or feature environment using ansible script.
7. Test on web browser.

## Full Develop Webapp Steps

### Docker 
For Developing the Webapp

### Build locally
```bash
cd docker/app
docker build -t henry808/webapp .
```

### Run locally
```bash
docker run -d -e ENV=test -p 8080:8080 henry808/webapp
```

### Test locally:
Navigate to [http://localhost:8080/](http://localhost:8080)

### Build and push to registry for ec2 use:
```bash
docker build -t henry808/webapp:latest .
docker push henry808/webapp:latest
```

### Run ansible script to download published docker image to e2 containers
```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/install_docker_webapp.yaml
```

## Troubleshooting the docker container

### To copy files from docker container to local 
Needed for troubleshooting
```bash
docker cp da681f7a7b0d:/home/ubuntu/ /home/henry808/temp/webapp/
```

### Attach
```bash
docker attach webapp
docker exec -it webapp bash
```

## Possible additions
1. Add ASG
2. Support for Private Docker Images
3. https
4. Lock ansible docker pull script to a version and remove force pull.
5. Use IAM Role
6. Create VPC and subnets (Maybe in another repo but use them here)
7. Add feature envs (very easy, just add a feature to s3 key and to localvars and add new tfvars for each)
8. 

# Workspaces
Current workspaces:

## State files are stored (todo: Change to table)
1. s3bucket - local workspace for managing s3 buckets
2. dev - on dev bucket
3. prod - on prod bucket

> Create more for each environment, but manage buckets with the s3bucket workspace

### To create
1. Create new workspace
```bash
terraform workspace new prod
```

### To select
```bash
terraform workspace select prod
```

### To list or verify
```bash
terraform workspace list
```


## Switch workspaces
This need to be done so you use the right state file for each.

```bash
terraform workspace select dev
terraform workspace select prod
```



## Author
Henry Grantham
