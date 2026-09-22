from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os


load_dotenv()

database_url = os.getenv(
    "DATABASE_URL",
    "mysql+mysqlconnector://root:@localhost:3306/homeserve_db",
)
engine = create_engine(database_url, echo=False, future=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future= True)
Base = declarative_base()


def check_database_connection():
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))

async def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()