AWS DevOps Project – Terraform, Docker & Nginx

Project Overview

This project demonstrates AWS infrastructure provisioning using Terraform and containerization using Docker and Nginx.

Technologies Used

* AWS
* Terraform
* Docker
* Nginx
* AWS EC2
* VPC
* Application Load Balancer
* Auto Scaling Group

AWS Infrastructure

* Created a custom VPC.
* Configured 2 public subnets and 2 private subnets.
* Created Internet Gateway and route tables.
* Provisioned EC2 instances using Terraform.
* Configured an Application Load Balancer.
* Created an Auto Scaling Group using a Launch Template.

Docker Implementation

* Created a Dockerfile using Nginx.
* Created a custom HTML webpage.
* Built a Docker image.
* Ran an Nginx container.
* Tested the application locally on port 8083.

Docker Commands

Build Docker image:

docker build -t my-nginx-app .

Run container:

docker run -d -p 8083:80 --name my-nginx my-nginx-app

Check running containers:

docker ps

Application Testing

Open your browser:

http://localhost:8083

Future Improvements

* Push Docker image to AWS ECR.
* Deploy Docker containers on AWS EC2 through Auto Scaling.
* Integrate Docker with Application Load Balancer.
* Implement CI/CD using Jenkins.