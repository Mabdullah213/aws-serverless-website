# AWS Serverless Portfolio Website

This project is a personal portfolio and resume website built on a completely serverless architecture within AWS. The entire infrastructure is defined as code using Terraform and deployed automatically via a CI/CD pipeline with GitHub Actions.

**Live Demo**: [https://www.muhammadjaved.com](https://www.muhammadjaved.com)

***

## Key Features

* **Secure & Production-Ready**: Deployed with a custom domain from Route 53, an SSL/TLS certificate from AWS Certificate Manager (ACM) for HTTPS, and protected by AWS WAF to mitigate common web exploits.
* **Globally Distributed & Low-Latency**: Leverages Amazon S3 for static hosting and CloudFront as a CDN for fast, secure content delivery to users worldwide.
* **Dynamic & Serverless Backend**: Utilizes AWS Lambda, API Gateway, and DynamoDB to create a dynamic backend without managing servers.
* **Infrastructure as Code (IaC)**: The entire AWS infrastructure is defined and managed in Terraform, enabling consistent, repeatable, and version-controlled deployments.
* **Fully Automated CI/CD**: A GitHub Actions workflow automatically builds and deploys any changes pushed to the main branch, creating a seamless development and release process.

***

## Architecture

The architecture is designed for high availability, security, and performance by separating static content delivery from dynamic API calls.

```mermaid
graph TD
    subgraph "User"
        User["fa:fa-user User's Browser"]
    end

    subgraph "AWS Edge & DNS"
        Route53["fa:fa-globe Route 53<br/>Custom Domain"]
        CloudFront["fa:fa-cloud CloudFront Distribution<br/>CDN & Cache"]
        WAF["fa:fa-shield-alt AWS WAF"]
    end

    subgraph "Application Backend (Serverless)"
        S3["fa:fa-archive Amazon S3<br/>Static Website Hosting"]
        APIGW["fa:fa-server API Gateway<br/>REST API"]
        Lambda["fa:fa-bolt AWS Lambda<br/>Backend Logic"]
        DynamoDB["fa:fa-database DynamoDB<br/>NoSQL Database"]
    end

    User -- "HTTPS Request" --> Route53
    Route53 -- "Resolves Domain" --> CloudFront
    CloudFront -- "Protected by" --> WAF
    WAF -- "Serves Static Content" --> S3
    WAF -- "Forwards API Requests" --> APIGW
    APIGW -- "Triggers" --> Lambda
    Lambda -- "Reads/Writes Data" --> DynamoDB
