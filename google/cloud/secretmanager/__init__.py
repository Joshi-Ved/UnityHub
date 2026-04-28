"""Stub for google.cloud.secretmanager used in tests."""

class SecretManagerServiceClient:
    def __init__(self, *args, **kwargs):
        pass

    def access_secret_version(self, request=None):
        class Payload:
            def __init__(self):
                self.data = b""

        class Response:
            def __init__(self):
                self.payload = Payload()

        return Response()
