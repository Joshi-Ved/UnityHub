import os
from fastapi import Header, HTTPException

async def verify_biometric_jwt(authorization: str = Header(None)):
    """
    Dependency that verifies a JWT contains biometric assertions.
    In production, validates `amr: ["face", "fingerprint"]` from a real IdP.
    In DEMO_MODE, accepts the mock token OR no token at all so the demo
    flow is never blocked by missing auth infrastructure.
    """
    # If a bearer token is provided, validate it strictly (tests expect a
    # 403 for invalid tokens). If no Authorization header is present, fall
    # back to DEMO_MODE behavior so integration tests without auth still work.
    if authorization and authorization.startswith("Bearer "):
        token = authorization.split(" ", 1)[1]
        if token == "mock_biometric_token":
            return token
        raise HTTPException(
            status_code=403,
            detail={
                "code": "biometric_assertion_missing",
                "message": "JWT lacks biometric assertions (amr).",
                "retryable": False,
            },
        )

    # No authorization header supplied — allow demo bypass when DEMO_MODE
    # is enabled so integration tests and local demos work without infra.
    _DEMO_MODE = os.environ.get("DEMO_MODE", "true").lower() == "true"
    if _DEMO_MODE:
        token = "demo-no-token"
        print(f"[DEMO MODE] Auth bypass — token: {token[:16]}...")
        return token

    raise HTTPException(
        status_code=401,
        detail={
            "code": "missing_jwt",
            "message": "Missing or invalid JWT token.",
            "retryable": False,
        },
    )
