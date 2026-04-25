import pytest
import asyncio
from main import verify_biometric_jwt
from fastapi import HTTPException

@pytest.mark.asyncio
async def test_verify_biometric_jwt_valid():
    """
    Tests that a valid biometric JWT is accepted by the middleware.
    """
    auth_header = "Bearer mock_biometric_token"
    token = await verify_biometric_jwt(auth_header)
    assert token == "mock_biometric_token"

@pytest.mark.asyncio
async def test_verify_biometric_jwt_invalid():
    """
    Tests that an invalid or non-biometric JWT is rejected with a 403.
    """
    auth_header = "Bearer regular_token"
    with pytest.raises(HTTPException) as exc_info:
        await verify_biometric_jwt(auth_header)
    assert exc_info.value.status_code == 403
