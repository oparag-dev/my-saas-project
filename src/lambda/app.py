import json

from audit import write_audit_event
from auth import extract_claims
from dynamodb_service import create_expense, get_expenses


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body),
    }


def handler(event, context):
    try:
        claims = extract_claims(event)

        tenant_id = claims["custom:tenant_id"]
        user_id = claims["sub"]
        method = event.get("httpMethod", "GET")

        if method == "GET":
            expenses = get_expenses(tenant_id)

            write_audit_event(
                tenant_id=tenant_id,
                user_id=user_id,
                action="GET_EXPENSES",
                details={"count": len(expenses)},
            )

            return response(
                200,
                {
                    "tenant_id": tenant_id,
                    "user_id": user_id,
                    "expenses": expenses,
                },
            )

        if method == "POST":
            body = json.loads(event.get("body") or "{}")

            expense = create_expense(
                tenant_id=tenant_id,
                user_id=user_id,
                data=body,
            )

            write_audit_event(
                tenant_id=tenant_id,
                user_id=user_id,
                action="CREATE_EXPENSE",
                details={"expense_id": expense["expense_id"]},
            )

            return response(
                201,
                {
                    "message": "Expense created",
                    "expense": expense,
                },
            )

        return response(
            405,
            {
                "error": f"Method {method} not allowed",
            },
        )

    except Exception as e:
        return response(
            500,
            {
                "error": str(e),
            },
        )