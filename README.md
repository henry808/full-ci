# Full CI

This project is to create a CI solution using Terraform, Circle-CI, Ansible, AWS, Docker, etc.

## Intro
An automated way to deploy a webapp. Currently it uses or more EC2 instances interfaced from a load balancer.

Http only at the moment, but https coming later.


# Current workflow
1. Create ec2 instances and load balancer using terraform:
```bash
cd tf
terraform plan -var-file="prod.tfvars"
```
    1. Can create test or dev environments by makeing a dev.tfvars and test.tfvars and running terraform using them.
    2. Can use as many instances as you want.
    3. public DNS for instances and load balancers are output when you run the terraform launcher. Instance DNS' are output for debugging.

2. Ansible scripts for installing docker and then for installing the webapp via docker.

> First Set hosts in playbook to environment: prod_webservers, test_webservers, or dev_webservers

```bash
cd ansible
ansible-playbook -i inventory/hosts.yaml playbooks/install_docker.yaml
ansible-playbook -i inventory/hosts.yaml playbooks/install_docker_webapp.yaml
```
3. Navigate to http://<LB public DNS>//:8080

## Developing for this project.
```
cd existing_repo
git remote add origin https://gitlab.com/henry808v21/projects/full-ci.git
git branch -M main
git push -uf origin main
```

## Develop Docker locally

### Build
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


### To copy files from docker container to local 
```bash
docker cp da681f7a7b0d:/home/ubuntu/ /home/henry808/temp/webapp/
```

### Attach
```bash
docker attach webapp
docker exec -it webapp bash
```


### Build and push to registry for ec2 use:
```bash
docker build -t henry808/webapp:latest .
docker push henry808/webapp:latest
```

## Possible additions
1. Add ASG
2. Support for Private Docker Images
3. https


## Author
Henry Grantham
