AWS Serverless Portfolio Website
Live Demo: https://www.muhammadjaved.com

This project is a personal portfolio and resume website built on a completely serverless architecture within AWS. The entire infrastructure is defined as code using Terraform and deployed automatically via a CI/CD pipeline with GitHub Actions. The application is secured with a custom domain, HTTPS, and a Web Application Firewall (WAF).

Key Features
Secure & Production-Ready: Deployed with a custom domain from Route 53, an SSL/TLS certificate from AWS Certificate Manager (ACM) for HTTPS, and protected by AWS WAF to mitigate common web exploits.

Serverless Architecture: Utilizes AWS Lambda, API Gateway, and DynamoDB to create a dynamic backend without managing servers.

Global Content Delivery: Leverages Amazon S3 for static hosting and CloudFront as a CDN for low-latency, secure content delivery worldwide.

Infrastructure as Code (IaC): The entire AWS infrastructure is defined and managed in Terraform, enabling consistent and repeatable deployments.

Automated CI/CD: A GitHub Actions workflow automatically deploys any changes pushed to the main branch, streamlining the development and release process.

### Architecture Diagram

```mermaid
graph TD
    subgraph "User's Browser"
        User("User")
    end

    subgraph "AWS Cloud"
        R53("Route 53<br/>muhammadjaved.com")
        ACM("Certificate Manager<br/>SSL/TLS Certificate")
        WAF("AWS WAF")
        CF("CloudFront Distribution")
        S3("S3 Bucket<br/>Static Files")
        APIGW("API Gateway<br/>POST /visit")
        Lambda("Lambda Function<br/>Visitor Counter Logic")
        DB("DynamoDB Table<br/>Visitor Count")
        IAM("IAM Role<br/>Lambda Permissions")
        CW("CloudWatch<br/>Logs & Metrics")
    end

    %% --- Connections ---
    User -- "1. muhammadjaved.com" --> R53
    R53 -- "2. Resolves to CloudFront" --> CF
    CF -- "3. Protected by WAF" --> WAF
    CF -- "4. Uses SSL Certificate" --> ACM
    CF -- "5. Serves static files" --> S3
    User -- "6. JS makes API call" --> APIGW
    APIGW -- "7. Triggers function" --> Lambda
    Lambda -- "8. Updates item" --> DB
    Lambda -.->|uses| IAM
    Lambda & APIGW -- "Logs & Metrics" --> CW

```
Tech Stack
Cloud & Networking: AWS (S3, CloudFront, Lambda, API Gateway, DynamoDB, IAM, Route 53, ACM, WAF)

Infrastructure as Code (IaC): Terraform

CI/CD: GitHub Actions

Languages: Python, JavaScript, HTML/CSS

This project was built as a practical, hands-on learning experience.
