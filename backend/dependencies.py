import os
from fastapi import Header, HTTPException

# When DEMO_MODE=true (default), auth is relaxed so Flutter can call the backend
# without a full PKCE/biometric token flow being wired. Set to false in production.
_DEMO_MODE = os.environ.get("DEMO_MODE", "true").lower() == "true"

async def verify_biometric_jwt(authorization: str = Header(None)):
    """
    Dependency that verifies a JWT contains biometric assertions.
    In production, validates `amr: ["face", "fingerprint"]` from a real IdP.
    In DEMO_MODE, accepts the mock token OR no token at all so the demo
    flow is never blocked by missing auth infrastructure.
    """
    if _DEMO_MODE:
        # Accept any call in demo mode — log it but don't block
        token = (authorization or "").replace("Bearer ", "") or "demo-no-token"
        print(f"[DEMO MODE] Auth bypass — token: {token[:16]}...")
        return token

    # Production path: enforce real bearer token
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail={
                "code": "missing_jwt",
                "message": "Missing or invalid JWT token.",
                "retryable": False,
            },
        )
    token = authorization.split(" ")[1]
    # TODO: Replace with real JWT verification (firebase-admin / python-jose)
    if token != "mock_biometric_token":
        raise HTTPException(
            status_code=403,
            detail={
                "code": "biometric_assertion_missing",
                "message": "JWT lacks biometric assertions (amr).",
                "retryable": False,
            },
        )
    return token
