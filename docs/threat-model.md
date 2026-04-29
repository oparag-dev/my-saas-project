# Threat Model

## Scope

This threat model covers the serverless backend for a multi-tenant FinTech SaaS application.

## Key Assets

- Tenant transaction records
- User identity data
- Audit logs
- API endpoints
- Terraform state

## Threat: Cross-Tenant Data Access

A user from Tenant A could try to access Tenant B's data.

Control:

The Lambda function gets tenant_id from Cognito claims. DynamoDB records use tenant-scoped partition keys. Queries use the authenticated tenant_id.

## Threat: Fake Tenant ID in Request Body

A user could submit another tenant_id in the request body.

Control:

The backend ignores tenant_id from the request body. Tenant context comes from Cognito claims only.

## Threat: Over-Permissive IAM Role

A Lambda role with broad permissions increases blast radius.

Control:

The Lambda execution role uses least-privilege permissions for DynamoDB, S3 audit logging, and CloudWatch logs.

## Threat: Missing Audit Trail

Sensitive actions could happen without traceability.

Control:

The backend writes audit logs to S3 for important actions.

## Threat: Infrastructure Drift

Manual changes could make the environment inconsistent.

Control:

Terraform manages the infrastructure. Deploy and destroy commands are documented.

## Threat: Cost Growth

Serverless costs can grow with traffic, logs, and retained data.

Control:

The project uses DynamoDB on-demand mode, Lambda, API Gateway, S3 lifecycle planning, and CloudWatch log retention.

## Summary

The main security focus is tenant isolation. The backend combines identity claims, tenant-scoped data modeling, IAM controls, audit logging, and repeatable infrastructure.
