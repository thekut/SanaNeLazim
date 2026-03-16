import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  // Varsayılan Değerler
  String country = 'Türkiye';
  int currentAge = 35;
  int deathAge = 90;
  double monthlyIncome = 50000;
  double monthlyExpense = 30000;
  
  double totalSavings = 0;
  double stockRatio = 40;
  double goldRatio = 30;
  double besRatio = 30;
  
  double careHomeBudget = 200000;
  double legacyTarget = 0;

  // Veri Güncelleme Fonksiyonları
  void updateAge(int current, int death) {
    currentAge = current;
    deathAge = death;
    notifyListeners();
  }

  void updateFinancials(double income, double expense) {
    monthlyIncome = income;
    monthlyExpense = expense;
    notifyListeners();
  }

  void updatePortfolio(double total, double stock, double gold, double bes) {
    totalSavings = total;
    stockRatio = stock;
    goldRatio = gold;
    besRatio = bes;
    notifyListeners();
  }

  void updateGoals(double careHome, double legacy) {
    careHomeBudget = careHome;
    legacyTarget = legacy;
    notifyListeners();
  }
}