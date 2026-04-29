# Project Narration

I built a cost-aware serverless SaaS backend for a FinTech use case. The main engineering challenge was tenant isolation. I used Cognito for identity, Lambda for business logic, DynamoDB with tenant-scoped partition keys, S3 for audit logs, and Terraform for repeatable infrastructure.

## Problem

Multi-tenant SaaS platforms allow multiple customers to use the same application infrastructure. In a FinTech system, this creates a serious security concern. One tenant must never access another tenant's financial records.

## Architecture

The backend uses API Gateway as the public API entry point. Cognito handles authentication. Lambda runs the business logic. DynamoDB stores tenant-scoped transaction records. S3 stores audit logs. CloudWatch captures logs and operational events. Terraform manages the infrastructure.

## Tenant Isolation Strategy

The backend does not trust tenant_id from the request body. The Lambda function extracts tenant_id from Cognito claims. DynamoDB records use tenant-scoped partition keys.

PK = TENANT#{tenant_id}  
SK = TRANSACTION#{transaction_id}

This ensures every query is scoped to a single tenant partition.

## Security Decisions

The Lambda function uses least-privilege IAM permissions. It can access the required DynamoDB table, write audit logs to S3, and write logs to CloudWatch. It does not receive broad administrative permissions.

## Cost Decisions

The project uses serverless services to reduce startup cost. Lambda, API Gateway, DynamoDB on-demand, S3, Cognito, and CloudWatch allow the backend to start small and scale with usage.

## What I Learned

This project helped me understand tenant isolation beyond theory. Secure SaaS design requires identity, data modeling, IAM, logging, and infrastructure to work together.

## Future Improvements

Future improvements include stronger role-based access control, automated tests, CI/CD deployment, WAF protection, budget alerts, custom domain setup, and separate tenant isolation strategies for high-value tenants.
