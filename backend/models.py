from sqlalchemy import Column, DateTime, Float, Integer, String, Text, func
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
