import boto3
import os
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")

table_name = os.environ["DYNAMODB_TABLE"]

table = dynamodb.Table(table_name)


def get_expenses(tenant_id):

    response = table.query(
        KeyConditionExpression=Key("pk").eq(f"TENANT#{tenant_id}") &
        Key("sk").begins_with("EXPENSE#")
    )

    return response.get("Items", [])