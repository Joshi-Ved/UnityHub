"""
Cloudinary storage service for UnityHub.

Reads CLOUDINARY_URL from the environment in the standard Cloudinary SDK format:
  cloudinary://API_KEY:API_SECRET@CLOUD_NAME

The angle-bracket wrappers that may appear in the .env file are stripped
automatically so copy-paste artefacts don't cause auth failures.
"""
import os
import re
import base64
import hashlib
import asyncio
import httpx
from typing import Optional


def _parse_cloudinary_url() -> Optional[dict]:
    """
    Parses CLOUDINARY_URL into its components.
    Handles the copy-paste variant with < > wrappers around credentials.
    """
    url = os.environ.get("CLOUDINARY_URL", "")
    if not url.startswith("cloudinary://"):
        return None

    # Strip angle brackets that sometimes appear from copy-paste
    url = url.replace("<", "").replace(">", "")

    pattern = r"cloudinary://([^:]+):([^@]+)@(.+)"
    match = re.match(pattern, url)
    if not match:
        return None

    return {
        "api_key": match.group(1).strip(),
        "api_secret": match.group(2).strip(),
        "cloud_name": match.group(3).strip(),
    }


_CREDS = _parse_cloudinary_url()


class CloudinaryService:
    """
    Async Cloudinary upload service using the REST Upload API.
    Falls back gracefully to None when credentials are absent (demo/test mode).
    """

    def __init__(self):
        self._creds = _CREDS
        self._timeout = httpx.Timeout(30.0, connect=10.0)

    @property
    def is_configured(self) -> bool:
        return self._creds is not None

    def _sign_params(self, params: dict) -> str:
        """Generate SHA-1 signature required by Cloudinary's authenticated upload API."""
        sorted_params = "&".join(
            f"{k}={v}" for k, v in sorted(params.items())
        )
        payload = sorted_params + self._creds["api_secret"]  # type: ignore[index]
        return hashlib.sha1(payload.encode()).hexdigest()

    async def upload_image(
        self,
        image_bytes: bytes,
        *,
        folder: str = "unityhub/impact_proofs",
        public_id: Optional[str] = None,
    ) -> Optional[str]:
        """
        Uploads image bytes to Cloudinary.

        Returns:
            The secure HTTPS URL of the uploaded image, or None on failure.
        """
        if not self.is_configured:
            return None

        cloud_name = self._creds["cloud_name"]  # type: ignore[index]
        api_key = self._creds["api_key"]  # type: ignore[index]
        upload_url = f"https://api.cloudinary.com/v1_1/{cloud_name}/image/upload"

        # Build signed params (timestamp is mandatory)
        import time
        timestamp = int(time.time())
        sign_params: dict = {"folder": folder, "timestamp": timestamp}
        if public_id:
            sign_params["public_id"] = public_id

        signature = self._sign_params(sign_params)

        # Encode image as base64 data URI
        b64 = base64.b64encode(image_bytes).decode()
        data_uri = f"data:image/jpeg;base64,{b64}"

        form_data = {
            "file": data_uri,
            "api_key": api_key,
            "timestamp": str(timestamp),
            "folder": folder,
            "signature": signature,
        }
        if public_id:
            form_data["public_id"] = public_id

        try:
            async with httpx.AsyncClient(timeout=self._timeout) as client:
                response = await client.post(upload_url, data=form_data)
                response.raise_for_status()
                result = response.json()
                return result.get("secure_url")
        except Exception as exc:
            print(f"[Cloudinary] Upload failed: {exc}")
            return None


# Module-level singleton
cloudinary_service = CloudinaryService()
