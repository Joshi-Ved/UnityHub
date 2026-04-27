import httpx
import os
import asyncio

class IPFSService:
    def __init__(self):
        self.pinata_jwt = os.environ.get("PINATA_JWT", "mock_jwt")
        self.base_url = "https://api.pinata.cloud/pinning"
        self.timeout = httpx.Timeout(20.0, connect=10.0)

    async def upload_to_ipfs(self, image_bytes: bytes, metadata: dict) -> str:
        """
        Uploads image and metadata to Pinata IPFS.
        Returns the IPFS URI (ipfs://CID).
        """
        if self.pinata_jwt == "mock_jwt":
            return f"ipfs://placeholder_cid_for_demo"

        async with httpx.AsyncClient(timeout=self.timeout) as client:
            headers = {"Authorization": f"Bearer {self.pinata_jwt}"}
            
            # 1. Upload image
            files = {"file": ("proof.jpg", image_bytes, "image/jpeg")}
            resp = await self._post_with_retry(
                client,
                f"{self.base_url}/pinFileToIPFS",
                headers=headers,
                files=files,
            )
            resp.raise_for_status()
            image_cid = resp.json()["IpfsHash"]
            
            # 2. Upload metadata JSON
            metadata_content = {
                "pinataContent": {
                    **metadata,
                    "image": f"ipfs://{image_cid}",
                    "external_url": "https://unityhub.app"
                }
            }
            meta_resp = await self._post_with_retry(
                client,
                f"{self.base_url}/pinJSONToIPFS",
                headers=headers,
                json=metadata_content,
            )
            meta_resp.raise_for_status()
            return f"ipfs://{meta_resp.json()['IpfsHash']}"

    async def _post_with_retry(self, client: httpx.AsyncClient, url: str, **kwargs) -> httpx.Response:
        attempts = 3
        for attempt in range(1, attempts + 1):
            try:
                response = await client.post(url, **kwargs)
                response.raise_for_status()
                return response
            except (httpx.TimeoutException, httpx.HTTPStatusError) as exc:
                if attempt == attempts:
                    raise exc
                await asyncio.sleep(0.4 * attempt)
