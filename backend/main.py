from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from routes.impact import router as impact_router
from routes.digilocker import router as digilocker_router
from routes.tasks import router as tasks_router
from core_limiter import limiter
from database import engine
from models import Base

app = FastAPI(
    title="UnityHub Secure Backend",
    description="Backend AI Oracle with OWASP 2026 Middlewares",
    version="1.0.0"
)

class AppError(Exception):
    def __init__(self, status_code: int, code: str, message: str, retryable: bool = False):
        self.status_code = status_code
        self.code = code
        self.message = message
        self.retryable = retryable
        super().__init__(message)


# --- Rate Limiting (SlowAPI) ---
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "retryable": exc.retryable,
            }
        },
    )

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    detail = exc.detail
    default_message = "Request failed."
    error_code = "http_error"
    retryable = exc.status_code >= 500

    if isinstance(detail, dict):
        error_code = detail.get("code", error_code)
        default_message = detail.get("message", default_message)
        retryable = detail.get("retryable", retryable)
    elif isinstance(detail, str):
        default_message = detail

    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": error_code,
                "message": default_message,
                "retryable": retryable,
            }
        },
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={
            "error": {
                "code": "validation_error",
                "message": "Request validation failed.",
                "retryable": False,
                "details": exc.errors(),
            }
        },
    )

# --- OWASP 2026 Middleware Security Best Practices ---

# 1. CORS: Strictly allow only frontend origins
# In DEMO_MODE, additional localhost origins are allowed so browser demos work on any port
_CORS_ORIGINS = [
    "https://unityhub.app",
    "http://localhost:3000",
    "http://localhost:8080",  # Flutter web default
    "http://localhost:8081",
    "http://127.0.0.1:8080",
    "http://127.0.0.1:3000",
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=_CORS_ORIGINS,
    allow_origin_regex=r"http://localhost:\d+",  # Allow any localhost port for demo
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

# 2. Trusted Host: Prevent Host Header Injection
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["unityhub.app", "*.unityhub.app", "localhost", "127.0.0.1"]
)

# 3. Secure HTTP Headers Middleware
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    # HSTS
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
    # Prevent MIME Sniffing
    response.headers["X-Content-Type-Options"] = "nosniff"
    # Clickjacking protection
    response.headers["X-Frame-Options"] = "DENY"
    # Content Security Policy
    response.headers["Content-Security-Policy"] = "default-src 'self'; frame-ancestors 'none'"
    # XSS Protection
    response.headers["X-XSS-Protection"] = "1; mode=block"
    # Referrer Policy
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    if os.environ.get("DEMO_MODE", "true").lower() == "true":
        response.headers["X-Demo-Mode"] = "true"
    return response

# Register API Routers
app.include_router(impact_router)
app.include_router(digilocker_router)
app.include_router(tasks_router)


@app.on_event("startup")
async def startup_event():
    # PostgreSQL-backed source-of-truth tables.
    # In production, use migrations (Alembic) instead of create_all.
    Base.metadata.create_all(bind=engine)

@app.get("/")
@limiter.limit("5/minute")
async def health_check(request: Request):
    return {"status": "Secure AI Oracle is running."}


@app.get("/nonces/{address}")
async def get_nonce(address: str, request: Request):
    """
    Proxy endpoint: fetches the current on-chain nonce for a volunteer address.
    Lets the Flutter frontend pre-fetch the nonce without a direct RPC dependency.
    Raises meaningful errors so mobile clients can handle failures predictably.
    """
    from routes.impact import oracle_service
    if not address.startswith("0x"):
        raise AppError(status_code=400, code="invalid_address", message="Invalid Ethereum address format")

    nonce = oracle_service.get_onchain_nonce(address)
    if nonce is None:
        raise AppError(
            status_code=502,
            code="nonce_unavailable",
            message="Could not fetch on-chain nonce right now.",
            retryable=True,
        )
    return {"address": address, "nonce": nonce}
