from fastapi.responses import JSONResponse


class Limiter:
    def __init__(self, key_func=None, default_limits=None):
        self.key_func = key_func
        self.default_limits = default_limits

    def limit(self, rule):
        def decorator(func):
            return func

        return decorator


async def _rate_limit_exceeded_handler(request, exc):
    return JSONResponse(status_code=429, content={"detail": "rate limit exceeded"})
