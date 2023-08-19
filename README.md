# Full CI

This project is for completing everything [here](https://gitlab.com/theuberlab/tutorials/terraform-circle-ci-aws-tutorial) and create a CI solution using Terraform, Circle-CI, Ansible, AWS, Docker, etc.



## Connect to this file:
```
cd existing_repo
git remote add origin https://gitlab.com/henry808v21/projects/full-ci.git
git branch -M main
git push -uf origin main
```

## Develop Docker locally

## Build
```bash
cd docker/app
docker build -t webapp .
docker build -t webapp_private:latest .
```

## Run
```bash
docker run -dp 8080:8080 webapp
```

## Navigate to [http://localhost:8080/](http://localhost:8080)

## Attach
```bash
docker attach webapp
docker exec -it webapp bash
```



## Author
Henry Grantham
