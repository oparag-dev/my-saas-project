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

## Test 2: Cognito App Client Lookup

Command: aws cognito-idp list-user-pool-clients \
  --user-pool-id eu-west-3_2fIhV1uol \
  --region eu-west-3


ClientName: saas-app-client-dev
ClientId: 7rnji12tcad4t6ivfps8rb43m9

## Test 3: Cognito Authentication

Command: TOKEN=$(aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id "$CLIENT_ID" \
  --auth-parameters USERNAME=testuser@example.com,PASSWORD='NewPassword123!' \
  --region eu-west-3 \
  --query "AuthenticationResult.IdToken" \
  --output text)

echo ${#TOKEN}


1097


## Test 4: Authenticated API Request

Command: curl -i \
  -H "Authorization: $TOKEN" \
  https://w65ur4djr1.execute-api.eu-west-3.amazonaws.com/dev


HTTP/2 200

{"tenant_id": "tenant_a", "user_id": "1179502e-4031-704a-0406-3b7e693ea48f", "expenses": []}

## Test 5: Authenticated Proxy Path Request

Command: curl -i \
  -H "Authorization: $TOKEN" \
  https://w65ur4djr1.execute-api.eu-west-3.amazonaws.com/dev/transactions


HTTP/2 200

{"tenant_id": "tenant_a", "user_id": "1179502e-4031-704a-0406-3b7e693ea48f", "expenses": []}

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

## Test 8: S3 Audit Log Check

Command: aws s3 ls s3://saas-audit-logs-dev --recursive

tenant_id=tenant_a/audit-2026-04-27T15:12:22.038336+00:00.json
tenant_id=tenant_a/audit-2026-04-27T15:12:40.501862+00:00.json
tenant_id=tenant_a/audit-2026-04-27T15:12:55.973494+00:00.json
tenant_id=tenant_a/audit-2026-04-27T15:13:59.769825+00:00.json

## Test 9: CloudWatch Lambda Logs

Command: aws logs tail /aws/lambda/multi_tenant_handler_dev \
  --since 30m \
  --region eu-west-3

Result: Lambda invocations completed successfully.
Recent requests returned END and REPORT log entries.
Max memory used: 96 MB.
Configured memory size: 128 MB.

##