from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from schemas import ImpactVerificationResponse
from dependencies import verify_biometric_jwt
import os
import sys

# Add parent directory to path so we can import services
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from services.gemini_oracle import GeminiOracleService

router = APIRouter()
oracle_service = GeminiOracleService()

@router.post("/verify-impact", response_model=ImpactVerificationResponse)
async def verify_impact(
    photo: UploadFile = File(...),
    ngo_task: str = Form(...),
    user_address: str = Form(...),
    _user: str = Depends(verify_biometric_jwt)
):
    """
    Evaluates a field photo against an NGO task using Gemini Agentic Reasoning and Embeddings.
    If verified (confidence > 0.90), returns an EIP-712 signature.
    """
    if not user_address.startswith("0x"):
        raise HTTPException(
            status_code=400,
            detail={"code": "invalid_address", "message": "Invalid Ethereum address format", "retryable": False},
        )

    photo_bytes = await photo.read()
    
    result = await oracle_service.process_submission(photo_bytes, ngo_task, user_address)
    if not result.get("success", False):
        message = result.get("message", "Impact verification failed.")
        lowered = message.lower()
        status_code = 422
        error_code = "verification_failed"

        if "duplicate" in lowered:
            status_code = 409
            error_code = "duplicate_submission"
        elif "invalid image" in lowered:
            status_code = 422
            error_code = "invalid_image"
        elif "fraud" in lowered:
            status_code = 403
            error_code = "fraud_detected"
        elif "mismatch" in lowered:
            status_code = 422
            error_code = "task_mismatch"

        raise HTTPException(
            status_code=status_code,
            detail={"code": error_code, "message": message, "retryable": status_code >= 500},
        )

    return ImpactVerificationResponse(**result)
