from io import BytesIO

import pytest
from fastapi.testclient import TestClient
from PIL import Image

from main import app
from routes import impact as impact_route


client = TestClient(app, base_url="http://localhost")


def _make_test_png() -> bytes:
    image = Image.new("RGB", (10, 10), color=(64, 128, 64))
    buffer = BytesIO()
    image.save(buffer, format="PNG")
    return buffer.getvalue()


def _post_verify_impact(ngo_task: str, user_address: str):
    files = {"photo": ("proof.png", _make_test_png(), "image/png")}
    data = {"ngo_task": ngo_task, "user_address": user_address}
    return client.post("/verify-impact", files=files, data=data)


def test_verify_impact_valid_photo_returns_signature(monkeypatch):
    def fake_process_submission(photo_bytes: bytes, ngo_task: str, user_address: str):
        assert photo_bytes
        return {
            "success": True,
            "message": "Verified successfully! Semantic confidence: 0.98",
            "confidence_score": 0.98,
            "signature": "0x" + "ab" * 65,
        }

    monkeypatch.setattr(impact_route.oracle_service, "process_submission", fake_process_submission)

    response = _post_verify_impact(
        ngo_task="Plant 10 native tree saplings near the school boundary.",
        user_address="0x1234567890123456789012345678901234567890",
    )

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is True
    assert body["signature"].startswith("0x")
    assert len(body["signature"]) == 132


def test_verify_impact_unrelated_photo_is_rejected(monkeypatch):
    def fake_process_submission(photo_bytes: bytes, ngo_task: str, user_address: str):
        assert photo_bytes
        return {
            "success": False,
            "message": "Task mismatch. Confidence score 0.22 is below 0.90 threshold.",
            "confidence_score": 0.22,
        }

    monkeypatch.setattr(impact_route.oracle_service, "process_submission", fake_process_submission)

    response = _post_verify_impact(
        ngo_task="Clean plastic waste at the riverbank.",
        user_address="0x1234567890123456789012345678901234567890",
    )

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is False
    assert "Task mismatch" in body["message"]


def test_verify_impact_blurry_photo_returns_handled_error(monkeypatch):
    def fake_process_submission(photo_bytes: bytes, ngo_task: str, user_address: str):
        assert photo_bytes
        return {
            "success": False,
            "message": "Low-quality image. Please upload a clearer photo.",
        }

    monkeypatch.setattr(impact_route.oracle_service, "process_submission", fake_process_submission)

    response = _post_verify_impact(
        ngo_task="Paint and label dustbins in ward 14.",
        user_address="0x1234567890123456789012345678901234567890",
    )

    assert response.status_code == 200
    body = response.json()
    assert body["success"] is False
    assert "Low-quality image" in body["message"]


def test_digilocker_authorize_and_token_mock_flow_and_no_pii_in_logs(caplog):
    caplog.clear()

    auth_response = client.post(
        "/api-setu/authorize",
        json={
            "client_id": "unityhub-mobile",
            "code_challenge": "abc123challenge",
            "code_challenge_method": "S256",
        },
    )
    assert auth_response.status_code == 200
    assert "authorization_code" in auth_response.json()

    token_response = client.post(
        "/api-setu/token",
        json={
            "client_id": "unityhub-mobile",
            "code_verifier": "verifier-xyz",
            "authorization_code": auth_response.json()["authorization_code"],
        },
    )
    assert token_response.status_code == 200
    assert token_response.json().get("access_token") == "mock_biometric_token"

    aadhaar_value = "1234-5678-9012"
    kyc_response = client.post(
        "/api-setu/kyc",
        json={"aadhaar_number": aadhaar_value},
        headers={"X-Client-Cert": "mock-cert"},
    )
    assert kyc_response.status_code == 200
    assert aadhaar_value not in caplog.text
