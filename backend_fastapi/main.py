from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "SananeLazim Kurumsal API Sistemleri Aktif.",
        "status": "Production-Ready",
        "tiers_supported": ["Basic", "Pro", "Advisor"]
    }

@app.get("/health-check")
async def health_check():
    return {"status": "ok", "version": settings.VERSION}
