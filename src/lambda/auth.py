def extract_claims(event):

    claims = event["requestContext"]["authorizer"]["claims"]

    if "custom:tenant_id" not in claims:
        raise Exception("tenant_id missing from token")

    return claims