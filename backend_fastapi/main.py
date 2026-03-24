from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from core.config import settings

app = FastAPI(title=settings.PROJECT_NAME, version=settings.VERSION)

# İŞTE BURASI CHROME'UN GÜVENLİK KALKANINI AŞAN KISIM (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,  # Her yerden gelen isteğe izin ver
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Uygulamadan (Frontend) Gelecek Olan Verilerin Taslağı
class UserData(BaseModel):
    currentAge: int
    deathAge: int
    monthlyIncome: float
    monthlyExpense: float
    totalSavings: float
    stockRatio: float
    goldRatio: float
    besRatio: float
    careHomeBudget: float
    legacyTarget: float

@app.post("/calculate")
def calculate_fire(data: UserData):
    # 1. Yıllık Tasarruf ve Hedef Büyüklük (%4 Kuralı)
    annual_savings = (data.monthlyIncome - data.monthlyExpense) * 12
    target_nest_egg = data.monthlyExpense * 12 * 25
    
    # Kullanıcının Miras Hedefi Varsa, Ana Paraya Ekle
    target_nest_egg += data.legacyTarget
    
    # Tasarruf Edemiyorsa Hesaplamayı Kes
    if annual_savings <= 0 and data.totalSavings < target_nest_egg:
        return {"freedomAge": 99, "message": "Gideriniz gelirinizden yüksek."}

    # 2. Döngüsel Gelecek Değer Hesaplaması
    current_savings = data.totalSavings
    years_to_freedom = 0
    annual_return_rate = 0.05 # Şimdilik basit %5 reel getiri
    
    while current_savings < target_nest_egg and years_to_freedom < 60:
        current_savings = (current_savings * (1 + annual_return_rate)) + annual_savings
        years_to_freedom += 1
        
    freedom_age = data.currentAge + years_to_freedom
    
    # Sonuçları Frontend'e Gönder
    return {
        "freedomAge": freedom_age,
        "targetNestEgg": target_nest_egg,
        "finalSavings": current_savings,
        "yearsToFreedom": years_to_freedom
    }