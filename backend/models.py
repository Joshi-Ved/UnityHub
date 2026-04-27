from sqlalchemy import Boolean, Column, DateTime, Float, Integer, String, Text, func
from database import Base


class Task(Base):
    __tablename__ = "tasks"

    id = Column(String(64), primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    ngo_name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(32), nullable=False, default="available")
    token_reward = Column(Integer, nullable=False, default=10)
    distance_km = Column(Float, nullable=False, default=0.0)
    lat = Column(Float, nullable=False, default=0.0)
    lng = Column(Float, nullable=False, default=0.0)
    skills_csv = Column(Text, nullable=True)
    verification_criteria = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class User(Base):
    """
    Stores volunteer / NGO identity metadata.
    Raw Aadhaar is NEVER stored — only the SHA-256 ImpactID hash.
    """
    __tablename__ = "users"

    id = Column(String(64), primary_key=True, index=True)          # Firebase UID
    firebase_uid = Column(String(128), unique=True, nullable=False, index=True)
    impact_id = Column(String(64), nullable=True, index=True)       # SHA-256 hash of Aadhaar — zero PII
    wallet_address = Column(String(42), nullable=True, index=True)  # EVM address
    role = Column(String(32), nullable=False, default="volunteer")   # volunteer | ngo | sponsor
    is_kyc_verified = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)


class ImpactLog(Base):
    """
    Immutable audit trail of every verified volunteer impact event.
    Links the Cloudinary proof image, IPFS metadata URI, and on-chain tx hash.
    """
    __tablename__ = "impact_logs"

    id = Column(String(64), primary_key=True, index=True)          # UUID
    user_address = Column(String(42), nullable=False, index=True)
    task_id = Column(String(64), nullable=True, index=True)
    task_title = Column(String(200), nullable=True)

    # Storage references
    cloudinary_url = Column(Text, nullable=True)                    # Secure Cloudinary image URL
    ipfs_uri = Column(Text, nullable=True)                          # IPFS metadata URI (Pinata)

    # AI verification
    confidence_score = Column(Float, nullable=True)
    gemini_description = Column(Text, nullable=True)

    # Cryptographic proof
    eip712_signature = Column(Text, nullable=True)
    tx_hash = Column(String(66), nullable=True, index=True)         # 0x + 32-byte hex

    # Outcome
    token_reward = Column(Integer, nullable=True, default=10)
    status = Column(String(32), nullable=False, default="verified") # verified | minted | failed

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
