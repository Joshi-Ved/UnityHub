"""
Lightweight fallback for the heavy `GeminiOracleService` used in production.

In test/dev environments where heavy ML and blockchain deps (numpy, web3,
google-genai, eth-account) aren't installed, this module provides a simple
compatible `GeminiOracleService` implementation so the test-suite can import
and run without requiring large optional dependencies.
"""

from typing import Optional


class GeminiOracleService:
    def __init__(self):
        self.similarity_threshold = 0.9
        self.processed_image_hashes: set[str] = set()

    def get_onchain_nonce(self, user_address: str) -> Optional[int]:
        return 1

    def calculate_cosine_similarity(self, vec1: list[float], vec2: list[float]) -> float:
        # simple dot-product based fallback (no numpy)
        try:
            dot = sum(a * b for a, b in zip(vec1, vec2))
            norm1 = sum(a * a for a in vec1) ** 0.5
            norm2 = sum(b * b for b in vec2) ** 0.5
            if norm1 == 0 or norm2 == 0:
                return 0.0
            return float(dot / (norm1 * norm2))
        except Exception:
            return 0.0

    def generate_eip712_signature(self, user_address: str, token_id: int, amount: int, nonce: int, ipfs_uri: str) -> str:
        return "0x" + "ab" * 65

    async def process_submission(self, photo_bytes: bytes, ngo_task: str, user_address: str, cloudinary_url: str = "") -> dict:
        # Minimal validation and deterministic mock result for tests
        if not photo_bytes:
            return {"success": False, "message": "Invalid image file."}

        image_hash = str(hash(photo_bytes))
        if image_hash in self.processed_image_hashes:
            return {"success": False, "message": "Duplicate submission detected."}

        self.processed_image_hashes.add(image_hash)

        # Approve with a high confidence by default so downstream tests can
        # exercise success paths unless they explicitly monkeypatch behavior.
        signature = self.generate_eip712_signature(user_address, 1, 10, 1, "ipfs://mockcid")
        return {
            "success": True,
            "message": "Verified successfully! Semantic confidence: 0.98",
            "confidence_score": 0.98,
            "signature": signature,
        }

