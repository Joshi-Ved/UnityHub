import pytest
from services.gemini_oracle import GeminiOracleService

def test_calculate_cosine_similarity():
    """
    Tests the cosine similarity calculation between two identical vectors.
    Returns 1.0 for perfect matches.
    """
    service = GeminiOracleService()
    vec1 = [1.0, 0.0, 0.0]
    vec2 = [1.0, 0.0, 0.0]
    similarity = service.calculate_cosine_similarity(vec1, vec2)
    assert similarity == 1.0

def test_generate_eip712_signature():
    """
    Tests that a valid hex signature is generated using the EIP-712 typed data standard.
    """
    service = GeminiOracleService()
    signature = service.generate_eip712_signature(
        user_address="0x1234567890123456789012345678901234567890",
        token_id=1,
        amount=10,
        nonce=0,
        ipfs_uri="ipfs://test"
    )
    assert isinstance(signature, str)
    assert signature.startswith("0x")
    assert len(signature) == 132 # 0x + 130 hex chars
