from fastapi import APIRouter, Request, HTTPException, Depends
from pydantic import BaseModel
import sys
import os
import hashlib

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core_limiter import limiter

router = APIRouter(prefix="/api-setu", tags=["DigiLocker"])

class KYCRequest(BaseModel):
    aadhaar_number: str

class KYCResponse(BaseModel):
    success: bool
    verified: bool
    message: str

class PKCEAuthRequest(BaseModel):
    client_id: str
    code_challenge: str
    code_challenge_method: str = "S256"

class TokenExchangeRequest(BaseModel):
    client_id: str
    code_verifier: str
    authorization_code: str

def verify_mtls_cert(request: Request):
    """
    Simulates mTLS verification. 
    In production, the ingress controller (e.g., NGINX) terminates the mTLS connection
    and passes the client certificate info via headers (like X-Client-Cert).
    """
    client_cert = request.headers.get("X-Client-Cert")
    if not client_cert:
        raise HTTPException(
            status_code=403, 
            detail="Forbidden: Mutual TLS (mTLS) client certificate is required for API Setu access."
        )
    return client_cert

def generate_impact_id(aadhaar: str) -> str:
    """
    Zero-Knowledge Wrapper: 
    Hashes Aadhaar data into a unique ImpactID without storing PII.
    """
    salt = os.environ.get("AADHAAR_SALT", "super_secret_unity_salt")
    return hashlib.sha256(f"{aadhaar}:{salt}".encode()).hexdigest()

@router.post("/authorize")
async def authorize_pkce(payload: PKCEAuthRequest):
    """
    Step 1 of DigiLocker OAuth 2.0 PKCE flow.
    """
    # Mock generating an authorization code
    return {"authorization_code": "mock_auth_code_123"}

@router.post("/token")
async def token_exchange(payload: TokenExchangeRequest):
    """
    Step 2 of PKCE: Exchange code for token using code_verifier.
    """
    # Simulate PKCE verification
    return {"access_token": "mock_biometric_token", "token_type": "bearer"}

@router.post("/kyc", response_model=KYCResponse)
@limiter.limit("5/minute")
async def verify_kyc(
    request: Request,
    payload: KYCRequest, 
    cert: str = Depends(verify_mtls_cert)
):
    """
    API Setu (DigiLocker) integration endpoint.
    Protected by mTLS and Rate Limiting.
    """
    impact_id = generate_impact_id(payload.aadhaar_number)
    # The raw Aadhaar is discarded, only ImpactID is returned
    return KYCResponse(
        success=True,
        verified=True,
        message=f"KYC verified successfully. ImpactID generated: {impact_id}"
    )
