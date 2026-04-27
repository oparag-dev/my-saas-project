# Dev API Test Results

## Environment

Environment: dev  
Region: eu-west-3  

## Terraform Outputs

API Gateway URL: https://w65ur4djr1.execute-api.eu-west-3.amazonaws.com/dev  
Cognito User Pool ID: eu-west-3_2fIhV1uol  
DynamoDB Table: saas_transactions_dev  
Lambda Function: multi_tenant_handler_dev  
S3 Audit Bucket: saas-audit-logs-dev  


## Test 1: Unauthenticated API Request

Command: ```bash
curl -i https://jpc0e9j1mc.execute-api.eu-west-3.amazonaws.com/dev

HTTP/2 401
{"message":"Unauthorized"}






## Test 6: Create Tenant-Scoped Expense

Command: ```bash
curl -i \
  -X POST \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amount":2500,"category":"cloud","description":"AWS test expense"}' \
  https://w65ur4djr1.execute-api.eu-west-3.amazonaws.com/dev/transactions

HTTP/2 201

{"message": "Expense created", "expense": {"pk": "TENANT#tenant_a", "sk": "EXPENSE#<uuid>", "tenant_id": "tenant_a", "amount": "2500", "category": "cloud"}}

## Test 7: DynamoDB Persistence Check

Command: ```bash
aws dynamodb scan \
  --table-name saas_transactions_dev \
  --region eu-west-3

The table returned expense records for tenant_a.

Example item:
pk: TENANT#tenant_a
sk: EXPENSE#716c3b5d-6e9c-4656-b66f-614ac2cfa536
tenant_id: tenant_a
category: cloud
amount: 2500
description: AWS test expense

##