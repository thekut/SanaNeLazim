from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_calculate():
    response = client.post(
        "/calculate",
        json={
            "tier": "basic",
            "country": "Türkiye",
            "currentAge": 35,
            "deathAge": 95,
            "monthlyIncome": 50000,
            "baseExpense": 20000,
            "rentExpense": 0,
            "debtExpense": 5000,
            "debtYears": 5,
            "funMoney": 5000,
            "totalSavings": 100000,
            "stockRatio": 0.5,
            "goldRatio": 0.3,
            "besRatio": 0.2,
            "legacyTarget": 1000000
        }
    )
    assert response.status_code == 200
    data = response.json()
    print("Test Response:", data)
    assert "freedomAge" in data
    assert "targetNestEgg" in data

test_calculate()
