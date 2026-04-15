This project is a serverless To-Do application built using AWS and Terraform

Users can :
Add tasks
View tasks
Update tasks
Delete tasks

Live Demo : 
http://todo-app-pravanjana-123.s3-website-us-east-1.amazonaws.com/

Architecture:

S3(Frontend Hosting)
|
API Gateway(HTTP API)
|
AWS Lambda(Python)
|
DynamoDB (NoSQL Database)


Tech Stack:
->Frontend: HTML,JavaScript
->Backend: AWS Lambda(Python)
->API: API Gateway
->Database: DynamoDB 
->Infrastructure: Terraform
->Hosting: Amazon S3

Setup Instructions

1.Clone repo

git clone https://github.com/pravanjana/todo-app-aws-terraform.git
cd todo-app-aws-terraform

2.Deploy infrastructure

cd terraform
terraform init
terraform apply

3.Deploy Lambda

cd ../lambda
zip -r todohandler.zip todohandler.py

4.Run frontend locally

cd ..
python3 -m http.server 8000

Open: http://localhost:8000


Key Learnings-----

-CORS handling in API Gateway
-Lambda + DynamoDB integration
-Terraform for infrastructure
-Debugging cloud applications

Future Improvements---
Add authentication (Cognito)
Improve UI/UX
Add task completion feature
CI/CD pipeline


Author
P.Pravanjana Rout




