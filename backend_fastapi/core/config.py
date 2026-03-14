from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    PROJECT_NAME: str = "SananeLazim API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"

    BACKEND_CORS_ORIGINS: list[str] = ["*"]

    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""
    GEMINI_API_KEY: str = ""

    MAX_MONTE_CARLO_ITERATIONS: int = 10000

    class Config:
        env_file = ".env"
        case_sensitive = True

@lru_cache()
def get_settings():
    return Settings()

settings = get_settings()
