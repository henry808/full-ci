# Full CI

This project is to create a CI solution using Terraform, Circle-CI, Ansible, AWS, Docker, etc.

## Intro
An automated way to deploy a webapp. Currently it uses or more EC2 instances interfaced from a load balancer.

s3 bucket is used for storing the terraform state file. Use the setup instructions to do a one time setup of the s3 bucket. You will have to use these setup instructions to create new environments and to edit or add policies or IAM when adding new people to the project.

Http only at the moment, but https coming later.

# Infrastructure Workflow
> Also for creating new modules and fir changing state
1. Initialize the terraform.
```bash
cd tf
terraform init \
  -backend-config="bucket=<your-bucket-name>" \
  -backend-config="key=<path/state/terraform.tfstate>" \
  -backend-config="region=us-west-2"
```

Example:
```bash
terraform init \
  -backend-config="bucket=henry808-webserver-s3bucket-prod" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=us-west-2"
```

2. Create ec2 instances and load balancer using terraform:
```bash
terraform plan -var-file="prod.tfvars"
```
    1. Can create test or dev environments by makeing a dev.tfvars and test.tfvars and running terraform using them.
    2. Can use as many instances as you want.
    3. public DNS for instances and load balancers are output when you run the terraform launcher. Instance DNS' are output for debugging.

2. Ansible scripts for installing docker and then for installing the webapp via docker.

> First Set all hosts in playbook to environment: prod_webservers, test_webservers, or dev_webservers

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/install_docker.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/install_docker_webapp.yaml
```
3. Navigate to http://<LB public DNS>//:8080

## To Develop the Webapp Workflow
Write in Python and run the docker file locally to make sure it works, then deploy to a dev environment using terraform. You can create a feature version of the infrastructure, but remember to destroy it when done.

## Develop Docker locally
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


## Author
Henry Grantham
