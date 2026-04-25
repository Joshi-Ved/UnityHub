from fastapi import FastAPI, Request, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from routes.impact import router as impact_router
from routes.digilocker import router as digilocker_router
from core_limiter import limiter

app = FastAPI(
    title="UnityHub Secure Backend",
    description="Backend AI Oracle with OWASP 2026 Middlewares",
    version="1.0.0"
)

async def verify_biometric_jwt(authorization: str = Header(None)):
    """
    Mock dependency that verifies a JWT contains biometric assertions.
    In production, validates `amr: ["face", "fingerprint"]`.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid JWT token.")
    token = authorization.split(" ")[1]
    # Simulate a check: token must equal "mock_biometric_token"
    if token != "mock_biometric_token":
        raise HTTPException(status_code=403, detail="JWT lacks biometric assertions (amr).")
    return token

# --- Rate Limiting (SlowAPI) ---
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# --- OWASP 2026 Middleware Security Best Practices ---

# 1. CORS: Strictly allow only frontend origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://unityhub.app", "http://localhost:3000"],
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
    return response

# Register API Routers
app.include_router(impact_router)
app.include_router(digilocker_router)

@app.get("/")
@limiter.limit("5/minute")
async def health_check(request: Request):
    return {"status": "Secure AI Oracle is running."}
