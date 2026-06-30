from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()

app = FastAPI(
    title="HomeServe Backend API",
    docs_url="./docs",
    redoc_url="./redoc",
    openapi_url="./openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,   # must be False when allow_origins=["*"]
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "HomeServe Backend API is running"}

@app.get("/api/health")
async def health():
    """Simple health-check endpoint used by the Flutter app on startup."""
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )