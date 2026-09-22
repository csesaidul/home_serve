from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from pathlib import Path
from sqlalchemy.exc import SQLAlchemyError

from app.routes.auth import router as auth_router
from app.routes.booking import router as booking_router
from app.routes.provider import router as provider_router
from app.routes.profile import router as profile_router
from database import check_database_connection

load_dotenv()

STATIC_DIR = Path(__file__).resolve().parent / "static"
STATIC_DIR.mkdir(exist_ok=True)
ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets"

app = FastAPI(
    title="HomeServe Backend API",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,   # must be False when allow_origins=["*"]
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")
app.mount("/assets", StaticFiles(directory=ASSETS_DIR), name="assets")

app.include_router(auth_router)
app.include_router(provider_router)
app.include_router(profile_router)
app.include_router(booking_router)

@app.get("/")
async def root():
    return {"message": "HomeServe Backend API is running"}

@app.get("/api/health")
async def health():
    """Simple health-check endpoint used by the Flutter app on startup."""
    try:
        check_database_connection()
    except SQLAlchemyError as error:
        return {"status": "error", "database": "unavailable", "detail": str(error)}

    return {"status": "ok", "database": "connected"}

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )