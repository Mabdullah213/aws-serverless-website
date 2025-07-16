AWS Serverless Portfolio Website
Live Demo: https://d1ibk6q0hov7af.cloudfront.net

This project is a personal portfolio and resume website built on a completely serverless architecture within AWS. The entire infrastructure is defined as code using Terraform and deployed automatically via a CI/CD pipeline with GitHub Actions.

Key Features
Serverless Architecture: Utilizes AWS Lambda, API Gateway, and DynamoDB to create a dynamic backend without managing servers.

Global Content Delivery: Leverages Amazon S3 for static hosting and CloudFront as a CDN for low-latency, secure content delivery worldwide.

Infrastructure as Code (IaC): The entire AWS infrastructure is defined and managed in Terraform, enabling consistent and repeatable deployments.

Automated CI/CD: A GitHub Actions workflow automatically deploys any changes pushed to the main branch, streamlining the development and release process.
### **Architecture Diagram**
```mermaid
graph TD
    subgraph "User's Browser"
        User(fa:fa-user User)
    end

    subgraph "AWS Cloud"
        CF(fa:fa-globe CloudFront Distribution)
        S3(fa:fa-database S3 Bucket<br/>- index.html<br/>- style.css<br/>- script.js)
        APIGW(fa:fa-server API Gateway<br/>- POST /visit)
        Lambda(fa:fa-code Lambda Function<br/>- Visitor Counter Logic)
        DB(fa:fa-table DynamoDB Table<br/>- Visitor Count Item)
        IAM(fa:fa-key-plus IAM Role<br/>- Lambda Permissions)
        CW(fa:fa-chart-line CloudWatch<br/>- Logs & Metrics)
    end

    %% --- Connections ---
    User -- "1. Requests resume website" --> CF
    CF -- "2. Securely serves static files" --> S3
    User -- "3. JS makes API call" --> APIGW
    APIGW -- "4. Triggers function" --> Lambda
    Lambda -- "5. Gets/Updates item" --> DB
    Lambda -.->|uses| IAM
    Lambda -- "Logs/Metrics" --> CW
    APIGW -- "Logs/Metrics" --> CW
```

Tech Stack
Cloud: AWS (S3, CloudFront, Lambda, API Gateway, DynamoDB, IAM)

Infrastructure as Code (IaC): Terraform

CI/CD: GitHub Actions

Languages: Python, JavaScript, HTML/CSS
---
*This project was built as a practical, hands-on learning experience.*
## Final Update
