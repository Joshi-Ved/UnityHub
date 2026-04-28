import os
from dotenv import load_dotenv
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
# If psycopg2 is not installed (e.g., in CI or lightweight dev environments),
# fall back to an in-memory SQLite DB so tests and local runs still work.
try:
    import psycopg2  # type: ignore
    _db_url = DATABASE_URL
except Exception:
    if DATABASE_URL.startswith("postgres"):
        _db_url = "sqlite:///:memory:"
    else:
        _db_url = DATABASE_URL
if _db_url.startswith("sqlite"):
    # Use a thread-safe in-memory SQLite setup for tests and dev where
    # the DB driver isn't available. StaticPool + check_same_thread=False
    # lets multiple threads access the same in-memory DB used by the app
    # and test client.
    from sqlalchemy.pool import StaticPool

    engine = create_engine(
        _db_url,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        pool_pre_ping=True,
    )
else:
    engine = create_engine(
        _db_url,
        pool_pre_ping=True,
    )
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
