from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from schemas import ImpactVerificationResponse
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
    user_address: str = Form(...)
):
    """
    Evaluates a field photo against an NGO task using Gemini Agentic Reasoning and Embeddings.
    If verified (confidence > 0.90), returns an EIP-712 signature.
    """
    if not user_address.startswith("0x"):
        raise HTTPException(status_code=400, detail="Invalid Ethereum address format")

    photo_bytes = await photo.read()
    
    result = oracle_service.process_submission(photo_bytes, ngo_task, user_address)
    
    return ImpactVerificationResponse(**result)
