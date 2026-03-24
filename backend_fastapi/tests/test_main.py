import pytest
from fastapi.testclient import TestClient

import sys
import os

# Ensure backend_fastapi is in the path to allow direct imports like "from main import app"
# when running from different root directories.
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import app

client = TestClient(app)

def test_calculate_fire_happy_path():
    payload = {
        "currentAge": 30,
        "deathAge": 90,
        "monthlyIncome": 5000.0,
        "monthlyExpense": 3000.0,
        "totalSavings": 10000.0,
        "stockRatio": 0.5,
        "goldRatio": 0.3,
        "besRatio": 0.2,
        "careHomeBudget": 0.0,
        "legacyTarget": 50000.0
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "freedomAge" in data
    assert "targetNestEgg" in data
    assert "finalSavings" in data
    assert "yearsToFreedom" in data

    # targetNestEgg = 3000 * 12 * 25 + 50000 = 900000 + 50000 = 950000
    assert data["targetNestEgg"] == 950000.0
    assert data["freedomAge"] > 30

def test_calculate_fire_negative_cashflow_insufficient_savings():
    payload = {
        "currentAge": 30,
        "deathAge": 90,
        "monthlyIncome": 3000.0,
        "monthlyExpense": 5000.0,
        "totalSavings": 10000.0,
        "stockRatio": 0.5,
        "goldRatio": 0.3,
        "besRatio": 0.2,
        "careHomeBudget": 0.0,
        "legacyTarget": 0.0
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["freedomAge"] == 99
    assert data["message"] == "Gideriniz gelirinizden yüksek."

def test_calculate_fire_already_free():
    payload = {
        "currentAge": 40,
        "deathAge": 90,
        "monthlyIncome": 5000.0,
        "monthlyExpense": 5000.0,
        "totalSavings": 2000000.0,  # > targetNestEgg (5000 * 12 * 25 = 1500000)
        "stockRatio": 0.5,
        "goldRatio": 0.3,
        "besRatio": 0.2,
        "careHomeBudget": 0.0,
        "legacyTarget": 0.0
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["yearsToFreedom"] == 0
    assert data["freedomAge"] == 40
    assert data["targetNestEgg"] == 1500000.0
    assert data["finalSavings"] == 2000000.0

def test_calculate_fire_max_years_limit():
    payload = {
        "currentAge": 20,
        "deathAge": 90,
        "monthlyIncome": 3001.0,
        "monthlyExpense": 3000.0,
        "totalSavings": 0.0,
        "stockRatio": 0.5,
        "goldRatio": 0.3,
        "besRatio": 0.2,
        "careHomeBudget": 0.0,
        "legacyTarget": 0.0
    }
    response = client.post("/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["yearsToFreedom"] == 60
    assert data["freedomAge"] == 80
    assert data["targetNestEgg"] == 900000.0
    assert data["finalSavings"] < 900000.0
