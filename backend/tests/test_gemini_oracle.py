import pytest
from unittest.mock import patch, MagicMock


@pytest.fixture(autouse=True)
def mock_external_services():
    """
    Patches GCP Secret Manager and Web3 HTTPProvider so GeminiOracleService
    can be instantiated in tests without any network calls.
    """
    mock_secret_client = MagicMock()
    mock_secret_client.access_secret_version.return_value.payload.data.decode.return_value = (
        "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
    )
    mock_contract = MagicMock()
    mock_contract.functions.nonces.return_value.call.return_value = 0

    with patch("google.cloud.secretmanager.SecretManagerServiceClient", return_value=mock_secret_client), \
         patch("web3.Web3.HTTPProvider", return_value=MagicMock()), \
         patch("web3.Web3.eth") as mock_eth:
        mock_eth.contract.return_value = mock_contract
        yield


def test_calculate_cosine_similarity(mock_external_services):
    """
    Tests the cosine similarity calculation between two identical vectors.
    Returns 1.0 for perfect matches.
    """
    from services.gemini_oracle import GeminiOracleService
    service = GeminiOracleService()
    vec1 = [1.0, 0.0, 0.0]
    vec2 = [1.0, 0.0, 0.0]
    similarity = service.calculate_cosine_similarity(vec1, vec2)
    assert similarity == 1.0


def test_generate_eip712_signature(mock_external_services):
    """
    Tests that a valid hex signature is generated using the EIP-712 typed data standard.
    """
    from services.gemini_oracle import GeminiOracleService
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
    assert len(signature) in (130, 132)  # 0x + 128 or 130 hex chars (sig format varies)
