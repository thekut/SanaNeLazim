import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/providers/user_data_provider.dart';

void main() {
  group('UserDataProvider Tests', () {
    late UserDataProvider provider;

    setUp(() {
      provider = UserDataProvider();
    });

    test('initial state is correct', () {
      expect(provider.country, 'Türkiye');
      expect(provider.currentAge, 35);
      expect(provider.deathAge, 90);
      expect(provider.monthlyIncome, 50000);
      expect(provider.monthlyExpense, 30000);
      expect(provider.totalSavings, 0);
      expect(provider.stockRatio, 40);
      expect(provider.goldRatio, 30);
      expect(provider.besRatio, 30);
      expect(provider.careHomeBudget, 200000);
      expect(provider.legacyTarget, 0);
    });

    test('updateAge updates state and notifies listeners', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.updateAge(40, 85);

      expect(provider.currentAge, 40);
      expect(provider.deathAge, 85);
      expect(notified, isTrue);
    });

    test('updateFinancials updates state and notifies listeners', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.updateFinancials(60000, 35000);

      expect(provider.monthlyIncome, 60000);
      expect(provider.monthlyExpense, 35000);
      expect(notified, isTrue);
    });

    test('updatePortfolio updates state and notifies listeners', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.updatePortfolio(100000, 50, 25, 25);

      expect(provider.totalSavings, 100000);
      expect(provider.stockRatio, 50);
      expect(provider.goldRatio, 25);
      expect(provider.besRatio, 25);
      expect(notified, isTrue);
    });

    test('updateGoals updates state and notifies listeners', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.updateGoals(250000, 50000);

      expect(provider.careHomeBudget, 250000);
      expect(provider.legacyTarget, 50000);
      expect(notified, isTrue);
    });
  });
}
