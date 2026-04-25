import pytest
from routes.digilocker import generate_impact_id, verify_mtls_cert
from fastapi import Request, HTTPException

def test_generate_impact_id():
    """
    Tests the Zero-Knowledge wrapper to ensure Aadhaar numbers are deterministically hashed.
    """
    aadhaar1 = "1234-5678-9012"
    aadhaar2 = "1234-5678-9012"
    aadhaar3 = "9999-9999-9999"
    
    hash1 = generate_impact_id(aadhaar1)
    hash2 = generate_impact_id(aadhaar2)
    hash3 = generate_impact_id(aadhaar3)
    
    assert hash1 == hash2
    assert hash1 != hash3

@pytest.mark.asyncio
async def test_verify_mtls_cert_missing():
    """
    Tests that requests lacking the X-Client-Cert header raise a 403 Forbidden.
    """
    scope = {"type": "http", "headers": []}
    request = Request(scope)
    
    with pytest.raises(HTTPException) as exc_info:
        verify_mtls_cert(request)
    assert exc_info.value.status_code == 403
