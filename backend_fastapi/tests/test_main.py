from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_calculate_fire_happy_path():
    payload = {
        "currentAge": 30,
        "deathAge": 90,
        "monthlyIncome": 10000,
        "monthlyExpense": 5000,
        "totalSavings": 10000,
        "stockRatio": 0.5,
        "goldRatio": 0.2,
        "besRatio": 0.3,
        "careHomeBudget": 0,
        "legacyTarget": 0
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "freedomAge" in data
    assert "targetNestEgg" in data
    assert "finalSavings" in data
    assert "yearsToFreedom" in data

    # 5000 * 12 * 25 = 1,500,000
    assert data["targetNestEgg"] == 1500000
    # Annual savings = 5000 * 12 = 60000
    # Requires loop to find exact yearsToFreedom
    assert data["yearsToFreedom"] > 0
    assert data["finalSavings"] >= data["targetNestEgg"]

def test_calculate_fire_negative_savings():
    payload = {
        "currentAge": 30,
        "deathAge": 90,
        "monthlyIncome": 5000,
        "monthlyExpense": 6000,
        "totalSavings": 10000,
        "stockRatio": 0.5,
        "goldRatio": 0.2,
        "besRatio": 0.3,
        "careHomeBudget": 0,
        "legacyTarget": 0
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["freedomAge"] == 99
    assert data["message"] == "Gideriniz gelirinizden yüksek."

def test_calculate_fire_with_legacy():
    payload = {
        "currentAge": 30,
        "deathAge": 90,
        "monthlyIncome": 10000,
        "monthlyExpense": 5000,
        "totalSavings": 10000,
        "stockRatio": 0.5,
        "goldRatio": 0.2,
        "besRatio": 0.3,
        "careHomeBudget": 0,
        "legacyTarget": 500000
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()

    # 5000 * 12 * 25 = 1,500,000 + 500,000 = 2,000,000
    assert data["targetNestEgg"] == 2000000

def test_calculate_fire_already_reached():
    payload = {
        "currentAge": 30,
        "deathAge": 90,
        "monthlyIncome": 10000,
        "monthlyExpense": 5000,
        "totalSavings": 2000000,  # Zaten hedefi (1,500,000) aşmış
        "stockRatio": 0.5,
        "goldRatio": 0.2,
        "besRatio": 0.3,
        "careHomeBudget": 0,
        "legacyTarget": 0
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()

    assert data["yearsToFreedom"] == 0
    assert data["freedomAge"] == 30
    assert data["finalSavings"] == 2000000
