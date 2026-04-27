import os
import uuid
from datetime import datetime, timezone

import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
table_name = os.environ["DYNAMODB_TABLE"]
table = dynamodb.Table(table_name)


def get_expenses(tenant_id):
    response = table.query(
        KeyConditionExpression=Key("pk").eq(f"TENANT#{tenant_id}")
        & Key("sk").begins_with("EXPENSE#")
    )

    return response.get("Items", [])


def create_expense(tenant_id, user_id, data):
    expense_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc).isoformat()

    item = {
        "pk": f"TENANT#{tenant_id}",
        "sk": f"EXPENSE#{expense_id}",
        "expense_id": expense_id,
        "tenant_id": tenant_id,
        "user_id": user_id,
        "amount": str(data.get("amount")),
        "category": data.get("category", "uncategorized"),
        "description": data.get("description", ""),
        "created_at": created_at,
    }

    table.put_item(Item=item)

    return item