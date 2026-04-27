import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# .env uses "Neon_db" as the key name — read both variants so local and
# production environments both work without touching the .env file.
DATABASE_URL = (
    os.environ.get("Neon_db")
    or os.environ.get("DATABASE_URL")
    or "postgresql+psycopg2://postgres:postgres@localhost:5432/unityhub"
)

# NeonDB requires SSL; psycopg2 picks up sslmode from the URL query string.
# For local postgres the connect_args are safely ignored.
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_size=5,
    max_overflow=10,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
