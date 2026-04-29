# Multi-Tenant FinTech SaaS Backend

A cost-aware serverless SaaS backend for a FinTech use case, built with AWS Lambda, API Gateway, Cognito, DynamoDB, S3, CloudWatch, and Terraform.

The main engineering focus is strict tenant isolation. Each tenant uses the same backend infrastructure, but tenant data must remain isolated.

---

## Project Overview

This project demonstrates how to design and deploy a multi-tenant SaaS backend on AWS.

The system is designed for an early-stage FinTech SaaS company that needs:

- Secure tenant-aware request handling
- Low startup infrastructure cost
- Serverless scalability
- Repeatable Terraform deployment
- Audit logging for sensitive actions
- Clear infrastructure teardown flow

The system runs in:

```text
AWS Region: eu-west-3, Paris
```

---

## Architecture

```text
Client
  |
  v
Amazon API Gateway
  |
  v
Amazon Cognito Authorizer
  |
  v
AWS Lambda
  |
  |-- Amazon DynamoDB, tenant-scoped transaction data
  |-- Amazon S3, audit logs
  |-- Amazon CloudWatch, logs and alarms
```

Terraform manages the full infrastructure.

---

## AWS Services Used

| Service | Purpose |
|---|---|
| API Gateway | Public API entry point |
| Cognito | Authentication and JWT-based identity |
| Lambda | Backend application logic |
| DynamoDB | Tenant-scoped transaction storage |
| S3 | Audit log storage |
| CloudWatch | Logs and monitoring alarms |
| Terraform | Infrastructure as code |

---

## Deployed Development Resources

Latest development deployment output:

```text
API Gateway URL: https://yhf4lt9i5f.execute-api.eu-west-3.amazonaws.com/dev
Cognito User Pool ID: eu-west-3_OAgduXGZ0
DynamoDB Table: saas_transactions_dev
Lambda Function: multi_tenant_handler_dev
S3 Audit Bucket: saas-audit-logs-dev
```

---

## Tenant Isolation Model

The project uses a shared-table multi-tenant model.

Tenant identity comes from Cognito JWT claims. The backend does not trust `tenant_id` from the request body.

Expected Cognito claim:

```text
custom:tenant_id
```

The Lambda function extracts the tenant ID from the authenticated user's claims and uses it when reading or writing data.

DynamoDB key structure:

```text
pk = TENANT#<tenant_id>
sk = TRANSACTION#<transaction_id>
```

Example:

```text
pk = TENANT#tenant-a
sk = TRANSACTION#txn-001
```

This design keeps each query scoped to the authenticated tenant.

---

## Why Tenant Isolation Matters

In a FinTech SaaS platform, multiple companies can use the same backend. Each company is a tenant.

A design mistake could expose one tenant's financial data to another tenant.

This project addresses that risk through:

- Cognito authentication
- JWT-based tenant identity
- Tenant-scoped DynamoDB partition keys
- Lambda-level tenant enforcement
- Least-privilege IAM permissions
- S3 audit logging
- Terraform-managed infrastructure

---

## API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/health` | Check API health |
| POST | `/transactions` | Create a transaction |
| GET | `/transactions` | List transactions for the authenticated tenant |
| GET | `/transactions/{transaction_id}` | Get one transaction for the authenticated tenant |

---

## JWT and Authentication

API Gateway is configured with a Cognito User Pool authorizer.

Authenticated requests must include a Cognito JWT in the `Authorization` header.

```text
Authorization: Bearer <JWT_TOKEN>
```

The JWT must include tenant context through the Cognito custom attribute:

```text
custom:tenant_id
```

Important:

Terraform creates the Cognito infrastructure and API Gateway authorizer. End-to-end authentication is only proven when:

1. A Cognito user exists.
2. The user has `custom:tenant_id`.
3. The user signs in and receives a valid JWT.
4. API Gateway accepts the JWT.
5. Lambda receives the claims.
6. Lambda uses the tenant claim to scope DynamoDB access.

---

## Audit Logging

Sensitive actions are logged to S3.

Audit logs use tenant-aware prefixes:

```text
audit-logs/tenant_id=<tenant_id>/year=<year>/month=<month>/day=<day>/<request_id>.json
```

Example audit event:

```json
{
  "tenant_id": "tenant-a",
  "user_id": "user-001",
  "action": "CREATE_TRANSACTION",
  "status": "SUCCESS",
  "request_id": "request-001"
}
```

This supports traceability for tenant activity.

---

## Monitoring

CloudWatch is used for logs and alarms.

Configured monitoring includes:

- Lambda error alarm
- API Gateway 5XX alarm
- DynamoDB throttling alarm
- Lambda log group with retention

---

## Terraform Structure

```text
terraform/
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
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

The project uses modular Terraform so each AWS service is managed separately.

---

## Lambda Structure

```text
src/lambda/
├── app.py
├── audit.py
├── auth.py
├── dynamodb_service.py
└── requirements.txt
```

Main responsibilities:

| File | Purpose |
|---|---|
| `app.py` | Lambda handler and route handling |
| `auth.py` | Extracts identity and tenant context |
| `dynamodb_service.py` | Reads and writes tenant-scoped records |
| `audit.py` | Writes audit events to S3 |

---

## Deployment

From the Terraform root directory:

```bash
cd terraform/root
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file="../envs/dev.tfvars"
terraform apply -var-file="../envs/dev.tfvars"
```

Expected result:

```text
Apply complete.
```

Example latest deployment:

```text
Resources: 26 added, 0 changed, 0 destroyed.
```

---

## Terraform Outputs

After deployment, run:

```bash
terraform output
```

Expected outputs include:

```text
api_gateway_url
cognito_user_pool_id
dynamodb_table_name
lambda_arn
s3_audit_bucket
```

---

## Testing Strategy

The purpose of testing is not only to prove that AWS resources exist.

The tests must prove tenant isolation.

Minimum proof required:

1. API rejects unauthenticated requests.
2. Cognito user with `custom:tenant_id` receives a JWT.
3. Authenticated requests reach Lambda.
4. Lambda extracts tenant ID from JWT claims.
5. Lambda ignores `tenant_id` from the request body.
6. DynamoDB records are stored under `TENANT#<tenant_id>`.
7. Tenant B cannot read Tenant A records.
8. S3 audit logs are created for sensitive actions.

The strongest test is:

```text
Tenant A creates a transaction.
Tenant B tries to read it.
The request fails.
```

That proves the backend supports the main purpose of the project.

---

## Documentation

Additional documentation:

```text
docs/data-model.md
docs/tenant-isolation.md
docs/threat-model.md
docs/cost-analysis.md
docs/project-narration.md
docs/test-results/dev-api-test.md
```

---

## Cost Awareness

This project uses serverless services to reduce startup cost.

Cost-conscious decisions include:

- Lambda instead of always-on compute
- API Gateway pay-per-request model
- DynamoDB on-demand billing
- S3 lifecycle rules for audit logs
- CloudWatch log retention
- Modular Terraform for controlled environments

This design supports a startup-stage SaaS backend without paying for idle servers.

---

## Security Approach

Security controls include:

- Cognito-based authentication
- JWT-based tenant identity
- Tenant-scoped DynamoDB partition keys
- Least-privilege Lambda IAM role
- S3 public access blocking
- S3 server-side encryption
- CloudWatch monitoring
- Terraform-managed infrastructure

Known limitation:

This project demonstrates shared-infrastructure tenant isolation. It does not implement separate AWS accounts, separate databases per tenant, or dedicated infrastructure per tenant.

---

## Cleaning Up the Infrastructure

To remove the dev environment:

```bash
cd terraform/root
terraform plan -destroy -var-file="../envs/dev.tfvars"
terraform destroy -var-file="../envs/dev.tfvars"
```

If using the destroy script:

```bash
./scripts/destroy.sh dev
```

The audit bucket has S3 versioning enabled. The destroy script should empty current objects, object versions, and delete markers before running Terraform destroy.

Some resources created manually, such as remote state buckets or Lambda package buckets, may need manual cleanup.

---

## What This Project Demonstrates

This project demonstrates practical experience with:

- Serverless backend design
- Multi-tenant SaaS architecture
- Terraform infrastructure as code
- Cognito authentication
- JWT-based tenant context
- DynamoDB access patterns
- S3 audit logging
- CloudWatch monitoring
- Cost-aware AWS architecture
- Security-focused backend design

---

## Project Narration

I built a cost-aware serverless SaaS backend for a FinTech use case. The main engineering challenge was tenant isolation. I used Cognito for identity, Lambda for business logic, DynamoDB with tenant-scoped partition keys, S3 for audit logs, and Terraform for repeatable infrastructure.

---

## Current Status

Sprint 1 is complete at the infrastructure and documentation level.

Completed:

- Terraform deployment
- API Gateway
- Cognito User Pool
- Lambda backend
- DynamoDB table
- S3 audit bucket
- CloudWatch logs and alarms
- Tenant isolation design
- Documentation
- Destroy flow

Security validation still requires full Tenant A vs Tenant B JWT testing before making strong production-grade claims.

---

## Future Improvements

Planned improvements:

- Full Cognito JWT tenant-isolation test evidence
- Automated integration tests
- CI/CD pipeline
- Role-based access control
- AWS WAF protection
- Custom domain
- AWS Budgets alerts
- Stronger per-tenant isolation for enterprise tenants