from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
import logging, random, os, math
import google.generativeai as genai

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyCdzJRRJSJ-5Q3dKuEtKiQ3o8972hTOvsw")
if GEMINI_API_KEY != "API_ANAHTARINIZI_BURAYA_GIRIN":
    genai.configure(api_key=GEMINI_API_KEY)

# AKTÜERYAL MOTOR YAPILANDIRMASI
CONFIG = {
    "MAX_ITERATION_YEARS": 60,
    "FIRE_MULTIPLIER": 25,
    "MONTE_CARLO_SIMULATIONS": 10000,
    # 3 Rejim: 0=Normal (Disinflasyon), 1=Yüksek Enflasyon, 2=Stagflasyon
    # Geçiş Olasılık Matrisi (Markov Chain)
    "MARKOV_TRANSITION": [
        [0.65, 0.22, 0.13], # Normalden diğerlerine geçiş
        [0.38, 0.55, 0.07], # Yüksek enflasyondan diğerlerine geçiş
        [0.25, 0.25, 0.50]  # Stagflasyondan diğerlerine geçiş
    ]
}

app = FastAPI(title="SananeLazim Kurumsal API")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

# YENİ VERİ MODELLERİ (FAZ 3 ARAYÜZÜNE TAM UYUMLU)
class UserData(BaseModel):
    tier: str="basic"
    country: str="Türkiye"
    currentAge: int=35
    deathAge: int=78
    monthlyIncome: float=0
    monthlyExpense: float=0 # Köprü uyumluluğu (Eski arayüzler için fallback)
    baseExpense: float=0
    rentExpense: float=0
    debtExpense: float=0
    debtYears: int=0
    funMoney: float=0
    totalSavings: float=0
    stockRatio: float=0
    goldRatio: float=0
    besRatio: float=0
    careHomeBudget: float=0
    legacyTarget: float=0
    healthFund: float=0
    bucketListCost: float=0

class ReverseUserData(BaseModel):
    tier: str="basic"
    country: str="Türkiye"
    currentAge: int=35
    targetRetirementAge: int=55
    targetMonthlyIncome: float=50000
    totalSavings: float=0
    stockRatio: float=0
    goldRatio: float=0
    besRatio: float=0
    careHomeBudget: float=0
    legacyTarget: float=0
    healthFund: float=0
    bucketListCost: float=0

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(status_code=422, content={"detail": exc.errors()})

async def generate_ai_advisor_report(data: UserData, target_nest_egg: float, p50_age: int, p10_age: int, p90_age: int) -> str:
    if GEMINI_API_KEY == "API_ANAHTARINIZI_BURAYA_GIRIN": return "### ⚠️ Yapay Zeka Bağlantısı Bekleniyor\nLütfen Backend (main.py) dosyasına Gemini API anahtarınızı girin."
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        prompt = f"Sen acımasız ve elit bir finansal danışmansın. Yaş: {data.currentAge}, Ülke: {data.country}, Hedef Net Değer: {target_nest_egg:,.0f} TL. Markov-Switching Monte Carlo Özgürlük Yaşları: En iyi ihtimalle {p10_age}, Olası {p50_age}, Kötü (Stagflasyon) {p90_age}. Verilerine dayanarak 3 maddelik, aksiyon odaklı, net ve vurucu bir finansal tavsiye raporu yaz. Metni Markdown formatında (başlıklar, kalın yazılar ve listeler) kullanarak hazırla."
        return model.generate_content(prompt).text
    except Exception as e:
        logger.error(f"AI Hatası: {e}")
        return "### ⚠️ Danışman Şu An Meşgul\nYapay zeka sunucularında geçici bir yoğunluk var. Sistem defansif modda çalışmaya devam ediyor."

# MARKOV REJİM BAZLI GETİRİ MOTORU
def get_regime_return(regime: int, stock_ratio: float, gold_ratio: float, bes_ratio: float) -> tuple:
    # Dönüş: (Ağırlıklı Reel Getiri, Ağırlıklı Volatilite)
    tr = stock_ratio + gold_ratio + bes_ratio
    if tr <= 0: return 0.0, 0.0
    sr, gr, br = stock_ratio/tr, gold_ratio/tr, bes_ratio/tr
    
    if regime == 0: # Normal (Disinflasyon)
        r = (sr*0.08) + (gr*0.03) + (br*0.04)
        v = (sr*0.14) + (gr*0.10) + (br*0.05)
    elif regime == 1: # Yüksek Enflasyon (Altın koruması, Hisse volatilitesi)
        r = (sr*0.02) + (gr*0.06) + (br*0.01)
        v = (sr*0.28) + (gr*0.15) + (br*0.08)
    else: # Stagflasyon (Hisse çöküşü)
        r = (sr*-0.03) + (gr*0.09) + (br*-0.02)
        v = (sr*0.34) + (gr*0.20) + (br*0.05)
    return r, v

# RETIREMENT SMILE (YAŞA GÖRE HARCAMA EĞRİSİ)
def get_smile_multiplier(age: int) -> float:
    if age < 55: return 1.15 # Go-Go Years (Aktif/Seyahat Dönemi)
    elif age <= 70: return 0.85 # Slow-Go Years (Sakinleme Dönemi)
    else: return 1.0 # No-Go Years (Bakım bütçesi ayrıca eklenecek)

def calculate_time_to_target(current_savings, target_nest_egg, annual_savings, debt_payment, debt_years, annual_return_rate, max_years):
    # O(1) Zaman Karmaşıklığı: Kapalı Formül (Logaritmik Çözüm)
    if current_savings >= target_nest_egg:
        return 0
    
    def solve_n(FV, P, PMT, r):
        if r == 0: return float('inf') if PMT <= 0 else (FV - P) / PMT
        num, den = FV + (PMT / r), P + (PMT / r)
        return float('inf') if den <= 0 or num <= 0 else math.log(num / den) / math.log(1 + r)

    def get_fv(P, PMT, r, n):
        if r == 0: return P + PMT * n
        r_plus_1_n = (1 + r)**n
        return P * r_plus_1_n + PMT * ((r_plus_1_n - 1) / r)

    if debt_years > 0:
        n1 = solve_n(target_nest_egg, current_savings, annual_savings, annual_return_rate)
        if n1 <= debt_years:
            yrs = math.ceil(n1)
            return min(yrs, max_years)
        
        current_savings = get_fv(current_savings, annual_savings, annual_return_rate, debt_years)
        years_passed = debt_years
    else:
        years_passed = 0

    new_annual_savings = annual_savings + debt_payment
    n2 = solve_n(target_nest_egg, current_savings, new_annual_savings, annual_return_rate)
    
    total_years = years_passed + math.ceil(n2) if n2 != float('inf') else float('inf')
    return int(min(total_years, max_years))

@app.post("/calculate")
async def calculate_fire(data: UserData):
    try:
        # KÖPRÜ (BRIDGE) UYUMLULUĞU: Arayüzden detaylı veri gelmezse eskisini kullan
        eff_base = data.baseExpense if data.baseExpense > 0 else data.monthlyExpense
        eff_rent = data.rentExpense
        eff_debt = data.debtExpense
        eff_fun = data.funMoney

        # Güncel Yıllık Tasarruf Gücü
        annual_savings = (data.monthlyIncome - (eff_base + eff_rent + eff_debt + eff_fun)) * 12

        # AKTÜERYAL HEDEF HESAPLAMASI (Kategori C & D Entegrasyonu)
        base_annual_need = (eff_base + eff_rent + eff_fun) * 12
        target_nest_egg = (base_annual_need * CONFIG["FIRE_MULTIPLIER"]) + data.legacyTarget + data.bucketListCost + data.healthFund

        # AGRESİF DECUMULATION (No-Bequest Zırhı)
        if data.legacyTarget <= 0 and data.deathAge > 75:
            # Miras bırakılmayacaksa, portföyü sıfırlamak üzere hedef %15 küçültülür
            target_nest_egg = target_nest_egg * 0.85

        if annual_savings <= 0 and data.totalSavings < target_nest_egg:
            return {"freedomAge": 99, "targetNestEgg": target_nest_egg, "tierProcessed": data.tier}

        # Yaşam beklentisi sınırı (Sabit 60 yıl yerine Joint-Mortality mantığı)
        max_years = data.deathAge - data.currentAge
        if max_years <= 0: max_years = 1

        if data.tier.lower() in ["pro", "advisor"]:
            sims = []
            for _ in range(CONFIG["MONTE_CARLO_SIMULATIONS"]):
                savings, yrs = data.totalSavings, 0
                regime = 0 # Simülasyonlar Normal rejimle başlar

                while savings < target_nest_egg and yrs < max_years:
                    # 1. Markov Rejim Geçişi Zar Atımı
                    rand_val = random.random()
                    probs = CONFIG["MARKOV_TRANSITION"][regime]
                    if rand_val < probs[0]: regime = 0
                    elif rand_val < probs[0] + probs[1]: regime = 1
                    else: regime = 2

                    w_ret, w_vol = get_regime_return(regime, data.stockRatio, data.goldRatio, data.besRatio)
                    real_return = random.gauss(w_ret, w_vol)

                    # 2. Guyton-Klinger Guardrail (Piyasa Çökerse Tasarruf Artırılır)
                    current_savings_boost = annual_savings
                    if real_return < -0.20:
                        current_savings_boost = annual_savings * 1.10 # %10 Kemer Sıkma

                    # 3. Borç Düşümü Mantığı (Borç bittiği an taksitler birikime döner)
                    if yrs >= data.debtYears and data.debtYears > 0:
                        current_savings_boost += (eff_debt * 12)

                    savings = (savings * (1 + real_return)) + current_savings_boost
                    yrs += 1

                sims.append(yrs)
            sims.sort()

            # P10 (Harika), P50 (Medyan), P90 (Kötü) Dağılımları
            p10, p50, p90 = sims[1000], sims[5000], sims[9000]

            ai_report = await generate_ai_advisor_report(data, target_nest_egg, data.currentAge+p50, data.currentAge+p10, data.currentAge+p90) if data.tier.lower() == "advisor" else None
            return {
                "freedomAge": data.currentAge+p50,
                "targetNestEgg": target_nest_egg,
                "tierProcessed": data.tier,
                "monteCarlo": {"bestCaseAge": data.currentAge+p10, "medianCaseAge": data.currentAge+p50, "worstCaseAge": data.currentAge+p90},
                "advisorReport": ai_report
            }
        else:
            # Basic Katman (Sadece Normal Rejimle Dümdüz Hesaplama)
            # Performans Optimizasyonu: O(N) Döngüsü O(1) Kapalı Formüle (Logaritma) Dönüştürüldü
            w_ret, _ = get_regime_return(0, data.stockRatio, data.goldRatio, data.besRatio)
            yrs = calculate_time_to_target(
                data.totalSavings,
                target_nest_egg,
                annual_savings,
                eff_debt * 12,
                data.debtYears,
                w_ret,
                max_years
            )
            return {"freedomAge": data.currentAge+yrs if yrs < max_years else 99, "targetNestEgg": target_nest_egg, "tierProcessed": data.tier}

    except Exception as e:
        logger.error(f"Hesaplama Hatası: {e}")
        raise HTTPException(status_code=500, detail="Backend error")

@app.post("/calculate-reverse")
async def calculate_reverse_fire(data: ReverseUserData):
    try:
        years = data.targetRetirementAge - data.currentAge
        if years <= 0: return {"requiredMonthlySavings": 0, "targetNestEgg": 0, "gap":0, "futureValueOfCurrentSavings":0}

        # Tersine Mühendislikte Agresif Hedef
        target_nest_egg = (data.targetMonthlyIncome * 12 * 25) + data.legacyTarget + data.bucketListCost + data.healthFund
        if data.legacyTarget <= 0 and data.targetRetirementAge < 75:
             target_nest_egg = target_nest_egg * 0.85

        w_ret, _ = get_regime_return(0, data.stockRatio, data.goldRatio, data.besRatio)
        fv = data.totalSavings * ((1 + w_ret) ** years)
        gap = target_nest_egg - fv
        req_m = (gap * (w_ret / (((1 + w_ret) ** years) - 1))) / 12 if gap > 0 and w_ret > 0 else (gap / years)/12 if gap > 0 else 0

        return {"requiredMonthlySavings": req_m, "targetNestEgg": target_nest_egg, "gap": gap, "futureValueOfCurrentSavings": fv, "tierProcessed": data.tier}
    except Exception as e:
        logger.error(f"Reverse Hesabı Hatası: {e}")
        raise HTTPException(status_code=500, detail="Reverse error")
