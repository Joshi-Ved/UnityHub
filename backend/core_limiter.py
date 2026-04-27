from slowapi import Limiter
from slowapi.util import get_remote_address
from fastapi import Request

def get_wallet_address(request: Request) -> str:
    # Try to get wallet address from custom header or authorization token
    # For simplicity in this demo, we check X-Wallet-Address
    return request.headers.get("X-Wallet-Address", get_remote_address(request))

limiter = Limiter(key_func=get_wallet_address, default_limits=["100/minute"])
