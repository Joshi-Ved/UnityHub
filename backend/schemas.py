from pydantic import BaseModel, Field
from typing import Optional, List

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
    ipfs_uri: Optional[str] = None
    nonce: Optional[int] = None


class TaskCreateRequest(BaseModel):
    title: str
    ngo_name: str = "Admin Created"
    description: Optional[str] = ""
    token_reward: int = 20
    verification_criteria: Optional[str] = ""
    skills: List[str] = []
    lat: float = 19.0760
    lng: float = 72.8777


class TaskResponse(BaseModel):
    id: str
    title: str
    ngo_name: str
    distance_km: float
    skills: List[str]
    token_reward: int
    lat: float
    lng: float
    status: str

    class Config:
        from_attributes = True
