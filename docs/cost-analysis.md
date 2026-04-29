# Cost Analysis

## Overview

This project uses a serverless AWS architecture to keep startup costs low while supporting future scale.

## Services Used

- API Gateway
- AWS Lambda
- Amazon Cognito
- Amazon DynamoDB
- Amazon S3
- Amazon CloudWatch
- Terraform

## API Gateway

API Gateway charges mainly by request volume. This fits an early SaaS backend because there is no always-on server cost.

## Lambda

Lambda charges by invocation count and execution duration. This keeps compute cost low when traffic is low.

## DynamoDB

DynamoDB on-demand mode supports unpredictable early traffic without capacity planning.

## S3 Audit Logs

S3 provides low-cost audit log storage. Lifecycle rules can move older logs to cheaper storage classes.

## CloudWatch

CloudWatch stores application logs. Log retention should be controlled to avoid unnecessary cost.

## Cognito

Cognito provides managed authentication without building a custom identity system.

## Trade-Offs

This architecture reduces operational overhead and startup cost. The trade-off is that serverless systems require careful design around IAM, observability, cold starts, service limits, and audit logging.

## Future Cost Improvements

- Set strict CloudWatch log retention
- Use S3 lifecycle rules for audit logs
- Add AWS Budgets alerts
- Track API Gateway request volume
- Monitor DynamoDB read and write patterns
