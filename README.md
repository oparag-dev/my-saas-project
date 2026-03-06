# my-saas-project
Multi-Tenant FinTech SaaS with Strict Data Isolation

## Project Overview

This project sets up the infrastructure for a multi-tenant SaaS backend using AWS and Terraform.

The goal is to build a secure, scalable backend that works well for an early-stage startup. The design focuses on keeping costs low during the early phase while still allowing the system to scale as the product grows.

The infrastructure uses a serverless architecture to reduce operational overhead and avoid running servers that sit idle.

The system runs in the AWS region **eu-west-3 (Paris)**.

---

## Architecture Summary

The backend uses several managed AWS services working together.

Client → API Gateway → Lambda → DynamoDB

Authentication happens before the request reaches the application through Cognito.
Operational logs and monitoring are handled through CloudWatch, while audit records are stored in S3.

---

## Core Infrastructure Components

### API Layer

API endpoints are exposed using **Amazon API Gateway**.

API Gateway receives incoming requests and forwards them to the Lambda backend.
The API currently runs in a development stage.

API endpoint:

```
https://2qzsujofb2.execute-api.eu-west-3.amazonaws.com/dev
```

---

### Authentication

User authentication is handled by **Amazon Cognito**.

Cognito manages:

* user login
* token generation
* identity verification

Every authenticated request carries a JWT token that the backend uses to identify the user and tenant.

User Pool ID:

```
eu-west-3_TnnWVXpE1
```

---

### Application Logic

Application logic runs inside **AWS Lambda**.

The Lambda function processes incoming requests from API Gateway and performs actions such as:

* reading and writing data
* enforcing tenant boundaries
* validating user roles
* logging audit events

Lambda function name:

```
multi_tenant_handler_dev
```

---

### Data Storage

Application data is stored in **Amazon DynamoDB**.

The project uses a shared table design for multiple tenants.
Each record is partitioned using the tenant identifier.

Table name:

```
saas_transactions_dev
```

Example key structure:

```
pk = TENANT#<tenant_id>
sk = ENTITY#<details>
```

This structure keeps queries tenant-scoped and supports scalable access patterns.

---

### Audit Logging

Audit logs are stored in **Amazon S3**.

These logs track sensitive actions such as data changes and administrative operations.

Bucket name:

```
saas-audit-logs-dev
```

Lifecycle policies automatically move older logs to cheaper storage.

---

### Monitoring

Operational monitoring is handled using **Amazon CloudWatch**.

Basic alarms are configured to detect:

* Lambda errors
* API Gateway server errors
* DynamoDB throttling

These alarms help identify issues early.

---

## Terraform Project Structure

The infrastructure is organized into Terraform modules so that each service is managed independently.

```
terraform/
│
├── root
│   ├── main.tf
│   ├── backend.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── modules
│   ├── api_gateway
│   ├── lambda
│   ├── dynamodb
│   ├── cognito
│   ├── s3
│   └── cloudwatch
│
└── envs
    └── dev.tfvars
```

This structure keeps the infrastructure easier to maintain and extend.

---

## Security Approach

Several security practices were applied while building this architecture.

* Cognito handles authentication
* JWT tokens identify users and tenants
* Lambda uses least-privilege IAM roles
* S3 buckets block public access
* infrastructure state is stored securely
* DynamoDB data is partitioned by tenant

Tenant identity comes from authenticated tokens rather than client input.

---

## Cost Awareness

The architecture is designed with cost control in mind.

Decisions that keep costs low include:

* serverless compute through Lambda
* DynamoDB on-demand billing
* lifecycle rules for S3 storage
* minimal monitoring alarms

During development, this infrastructure usually costs under **$10–$20 per month**.

---

## Deploying the Infrastructure

Terraform manages all infrastructure provisioning.

Initialize Terraform:

```
terraform init
```

Preview the deployment:

```
terraform plan -var-file="../envs/dev.tfvars"
```

Deploy the infrastructure:

```
terraform apply -var-file="../envs/dev.tfvars"
```

---

## Current Status

Infrastructure deployment is complete.

Provisioned components include:

* API Gateway
* Lambda
* DynamoDB
* Cognito
* S3 audit logging
* CloudWatch monitoring

The next phase focuses on implementing the application logic inside Lambda.

---

## Next Steps

Planned work includes:

* building the expense management API
* enforcing tenant-aware authorization
* expanding monitoring and alerting
* implementing structured audit events

---

## What This Project Demonstrates

This project shows practical experience with:

* Terraform infrastructure as code
* serverless backend design
* multi-tenant SaaS architecture
* AWS security practices
* cost-aware infrastructure planning
