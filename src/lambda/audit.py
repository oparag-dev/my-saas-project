import json
import os
from datetime import datetime, timezone

import boto3

s3 = boto3.client("s3")
audit_bucket = os.environ["AUDIT_BUCKET"]


def write_audit_event(tenant_id, user_id, action, details):
    timestamp = datetime.now(timezone.utc).isoformat()

    event = {
        "tenant_id": tenant_id,
        "user_id": user_id,
        "action": action,
        "details": details,
        "timestamp": timestamp,
    }

    key = f"tenant_id={tenant_id}/audit-{timestamp}.json"

    s3.put_object(
        Bucket=audit_bucket,
        Key=key,
        Body=json.dumps(event),
        ContentType="application/json",
    )

    return key