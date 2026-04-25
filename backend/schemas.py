from pydantic import BaseModel, Field
from typing import Optional

class ForensicAnalysisResult(BaseModel):
    image_description: str = Field(description="A highly detailed description of what is happening in the photo.")
    is_fraud: bool = Field(description="True if the image appears to be a screenshot, AI-generated, or maliciously manipulated. False if it looks like an authentic camera capture.")
    fraud_reason: str = Field(description="If is_fraud is true, provide the forensic reasoning. Otherwise, leave empty or say 'Looks authentic'.")

class ImpactVerificationResponse(BaseModel):
    success: bool
    message: str
    confidence_score: Optional[float] = None
    tx_hash: Optional[str] = None
    signature: Optional[str] = None
