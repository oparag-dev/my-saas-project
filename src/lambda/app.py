import json
from auth import extract_claims
from dynamodb_service import get_expenses

def handler(event, context):

    try:
        claims = extract_claims(event)

        tenant_id = claims["custom:tenant_id"]
        user_id = claims["sub"]

        expenses = get_expenses(tenant_id)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "tenant_id": tenant_id,
                "user_id": user_id,
                "expenses": expenses
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }