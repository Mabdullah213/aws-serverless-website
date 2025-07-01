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

    %% Path 1: User requests the static website content
    User -- "1. Requests resume website" --> CF
    CF -- "2. Securely serves static files" --> S3

    %% Path 2: JavaScript on the website calls the API to count the visit
    User -- "3. JavaScript POST request" --> APIGW
    APIGW -- "4. Triggers function" --> Lambda

    %% Path 3: Backend logic and permissions
    Lambda -- "5. Gets/Updates item" --> DB
    Lambda -.->|uses| IAM

    %% Path 4: Monitoring for all services
    Lambda -- "Logs/Metrics" --> CW
    APIGW -- "Logs/Metrics" --> CW
    CF -- "Logs" --> CW
