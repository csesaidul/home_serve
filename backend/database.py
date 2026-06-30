from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os


load_dotenv()

database_url = os.environ["DATABASE_URL"]
engine = create_engine(database_url, echo=False, future=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future= True)
Base = declarative_base()

async def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()