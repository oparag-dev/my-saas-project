# Tenant Isolation

## Overview

This project implements tenant isolation for a multi-tenant FinTech SaaS backend. The goal is to ensure that one tenant cannot access another tenant's financial data.

## Tenant Identity Source

The backend gets tenant identity from Cognito claims. The Lambda function extracts tenant_id from the authenticated user's token.

The API does not trust tenant_id from the request body.

## DynamoDB Isolation Model

DynamoDB records use tenant-scoped partition keys.

PK = TENANT#{tenant_id}  
SK = TRANSACTION#{transaction_id}

This keeps reads and writes scoped to the authenticated tenant.

## Request Handling

For each request, the Lambda function:

1. Extracts user identity from Cognito claims.
2. Extracts tenant_id from the identity context.
3. Rejects requests without tenant context.
4. Uses tenant_id when reading or writing DynamoDB records.
5. Writes audit logs for sensitive actions.

## Audit Logging

Audit logs are written to S3 using tenant-aware prefixes.

Example:

audit-logs/tenant_id=tenant-a/year=2026/month=04/day=24/request-id.json

## Controls

- Cognito authentication
- Tenant ID from trusted identity claims
- Tenant-scoped DynamoDB partition keys
- Least-privilege Lambda IAM role
- S3 audit logging
- CloudWatch logs
- Terraform-managed infrastructure

## Known Limitations

This project demonstrates startup-stage tenant isolation. It does not implement separate AWS accounts, separate databases per tenant, or dedicated tenant infrastructure.

## Future Improvements

- Role-based access control
- Automated tenant isolation tests
- AWS WAF protection
- Per-tenant encryption strategy
- CI/CD pipeline
- Dedicated isolation model for high-risk tenants
