def get_remote_address(request):
    # best-effort remote address extraction for tests
    try:
        client = getattr(request, "client", None)
        if client and getattr(client, "host", None):
            return client.host
    except Exception:
        pass
    return request.headers.get("X-Forwarded-For", request.headers.get("x-forwarded-for", "127.0.0.1"))
