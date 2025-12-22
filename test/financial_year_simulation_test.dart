import 'package:flutter_test/flutter_test.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/services/financial_insights_service.dart';

void main() {
  /// --- YARDIMCI METOTLAR (Data Factories) ---
  Transaction _tx(String id, double amount, String cat, DateTime date, {bool isExpense = true}) {
    return Transaction(
      id: id,
      userId: 'user_can',
      amount: amount,
      categoryId: cat.toLowerCase(),
      categoryName: cat,
      categoryEmoji: '🏷️',
      date: date,
      isExpense: isExpense,
    );
  }

  Subscription _sub(String id, String name, double amount, DateTime date) {
    return Subscription(
      id: id,
      userId: 'user_can',
      name: name,
      amount: amount,
      currency: 'TRY',
      frequency: RecurrenceFrequency.monthly,
      category: SubscriptionCategory.streaming,
      nextBillingDate: date,
    );
  }

  group('🦁 THE GRAND LION TEST: 12-Month Dynamic Life Scenario (Zero Error Edition)', () {
    // SENARYO DEĞİŞKENLERİ (STATE)
    const userId = 'user_can';
    const year = 2025;
    double currentBalance = 5000.0; // Yıla 5000 TL ile başlıyor
    double? lastMonthExpenses;

    // Sabit Giderler
    const rentAmount = 4000.0;

    // Simülasyon Motoru
    MonthlySummary runMonth({
      required int month,
      required double income,
      required List<Transaction> expenses,
      required List<Subscription> subs,
    }) {
      final summary = FinancialInsightsService.generateMonthlySummary(
        userId: userId,
        year: year,
        month: month,
        totalIncome: income,
        transactions: expenses,
        subscriptions: subs,
        previousMonthExpenses: lastMonthExpenses,
      );

      // State Güncellemesi (Bakiye ve Trend Hafızası)
      currentBalance += summary.leftoverAmount;
      lastMonthExpenses = summary.totalExpenses;

      return summary;
    }

    test('Simulates Salary Changes, Add Funds, Pay Cycles and Savings without errors', () {

      // --- Q1: DEĞİŞİM RÜZGARLARI (Maaş Zammı & Ek Gelir) ---

      // OCAK: Standart Başlangıç
      // Gelir: 8000
      // Gider: 4000(Kira) + 1500(Market) + 100(Sub) = 5600.
      // Oran: 5600 / 8000 = 0.70 (Tam %70)
      // Kural: < 0.7 Good, < 0.9 Fair. 0.7 sayısı Fair'e düşer.
      final janSubs = [_sub('s1', 'Netflix', 100, DateTime(year, 1, 15))];
      final janTxs = [
        _tx('j1', rentAmount, 'Rent', DateTime(year, 1, 1)),
        _tx('j2', 1500, 'Groceries', DateTime(year, 1, 5)),
      ];

      final jan = runMonth(month: 1, income: 8000, expenses: janTxs, subs: janSubs);
      expect(jan.totalExpenses, 5600);
      expect(jan.healthStatus, FinancialHealth.fair, reason: "Oran tam 0.70 olduğu için 'Fair' olmalı.");
      expect(jan.leftoverAmount, 2400);
      // Bakiye: 5000 + 2400 = 7400

      // ŞUBAT: "ADD FUNDS" (Ek Gelir) Testi
      // Maaş (8000) + Satış (2000) = 10000 Gelir.
      // Gider hala 5600 (Çünkü satış gider değil).
      // Oran: 5600 / 10000 = 0.56 (%56).
      // Kural: < 0.5 Excellent, < 0.7 Good. %56 -> GOOD.
      final febTxs = [
        _tx('f1', rentAmount, 'Rent', DateTime(year, 2, 1)),
        _tx('f2', 1500, 'Groceries', DateTime(year, 2, 5)),
        _tx('f3_fund', 2000, 'Sold Phone', DateTime(year, 2, 10), isExpense: false), // Gelir işlemi
      ];

      final feb = runMonth(month: 2, income: 10000, expenses: febTxs, subs: janSubs);

      expect(feb.totalExpenses, 5600);
      expect(feb.expensesByCategory.containsKey('Sold Phone'), isFalse);
      expect(feb.healthStatus, FinancialHealth.good, reason: "Harcama oranı %56 olduğu için durum 'Good' olmalıdır.");
      expect(feb.leftoverAmount, 4400);
      // Bakiye: 7400 + 4400 = 11800

      // MART: MAAŞ DEĞİŞİKLİĞİ (Promotion)
      // Gelir: 12000.
      // Gider: 4000 + 2000(Market arttı) + 100(Sub) = 6100.
      // Oran: 6100 / 12000 = 0.508 (%50.8).
      // Kural: < 0.7 Good.
      final marTxs = [
        _tx('m1', rentAmount, 'Rent', DateTime(year, 3, 1)),
        _tx('m2', 2000, 'Groceries', DateTime(year, 3, 5)),
      ];

      final mar = runMonth(month: 3, income: 12000, expenses: marTxs, subs: janSubs);

      expect(mar.totalIncome, 12000);
      expect(mar.healthStatus, FinancialHealth.good);
      expect(mar.leftoverAmount, 5900);
      // Bakiye: 11800 + 5900 = 17700

      // --- Q2: ÖDEME DÖNGÜSÜ VE TASARRUF ---

      // NİSAN: SAVINGS (Tasarruf Hedefine Para Atma)
      // Gider: 6100 + 5000(Save) = 11100.
      // Gelir: 12000.
      // Oran: 11100 / 12000 = 0.925 (%92.5).
      // Kural: < 0.9 Fair, <= 1.0 Poor. %92.5 -> POOR.
      final aprTxs = [
        _tx('a1', rentAmount, 'Rent', DateTime(year, 4, 1)),
        _tx('a2', 2000, 'Groceries', DateTime(year, 4, 5)),
        _tx('a3_save', 5000, 'Savings Deposit', DateTime(year, 4, 10), isExpense: true),
      ];

      final apr = runMonth(month: 4, income: 12000, expenses: aprTxs, subs: janSubs);

      expect(apr.totalExpenses, 11100);
      expect(apr.healthStatus, FinancialHealth.poor, reason: "Harcama oranı %90'ı geçtiği için 'Poor' olmalı.");
      expect(apr.leftoverAmount, 900);
      // Bakiye: 17700 + 900 = 18600

      // MAYIS: PAY CYCLE CHANGE (3 Maaşlı Ay)
      // Gelir: 18000.
      // Gider: 6100.
      // Oran: 6100 / 18000 = 0.338 (%33.8).
      // Kural: < 0.5 Excellent.
      final mayTxs = [
        _tx('my1', rentAmount, 'Rent', DateTime(year, 5, 1)),
        _tx('my2', 2000, 'Groceries', DateTime(year, 5, 5)),
      ];

      final may = runMonth(month: 5, income: 18000, expenses: mayTxs, subs: janSubs);

      expect(may.totalIncome, 18000);
      expect(may.healthStatus, FinancialHealth.excellent);
      expect(may.leftoverAmount, 11900);
      // Bakiye: 18600 + 11900 = 30500

      // HAZİRAN: RECENT / ADD EXPENSE (Acil Durum)
      // Gelir: 12000.
      // Gider: 6100 + 15000(Araba) = 21100.
      // Oran: 21100 / 12000 = 1.75 (%175).
      // Kural: > 1.0 Critical.
      final junTxs = [
        _tx('jn1', rentAmount, 'Rent', DateTime(year, 6, 1)),
        _tx('jn2', 2000, 'Groceries', DateTime(year, 6, 5)),
        _tx('jn3_crash', 15000, 'Car Repair', DateTime(year, 6, 15)),
      ];

      final jun = runMonth(month: 6, income: 12000, expenses: junTxs, subs: janSubs);

      expect(jun.totalExpenses, 21100);
      expect(jun.healthStatus, FinancialHealth.critical);
      expect(jun.leftoverAmount, -9100);
      // Bakiye: 30500 - 9100 = 21400

      // --- Q3: ABONELİK YÖNETİMİ ---

      // TEMMUZ: Yeni Abonelik Ekleme
      // Sub: 100(Netflix) + 400(Gym) = 500.
      // Gider: 4000 + 2000 + 500 = 6500.
      // Gelir: 12000.
      // Oran: 6500 / 12000 = 0.54 (%54). -> Good.
      final julSubs = [...janSubs, _sub('s2', 'Gym', 400, DateTime(year, 7, 1))];
      final julTxs = [
        _tx('jl1', rentAmount, 'Rent', DateTime(year, 7, 1)),
        _tx('jl2', 2000, 'Groceries', DateTime(year, 7, 5)),
      ];

      final jul = runMonth(month: 7, income: 12000, expenses: julTxs, subs: julSubs);

      expect(jul.totalSubscriptions, 500);
      expect(jul.totalExpenses, 6500);
      expect(jul.healthStatus, FinancialHealth.good);
      // Bakiye: 21400 + 5500 = 26900

      // AĞUSTOS: Abonelik İptali
      // Sadece Gym kaldı (400).
      // Gider: 4000 + 2000 + 400 = 6400.
      // Kalan: 5600.
      final augSubs = [_sub('s2', 'Gym', 400, DateTime(year, 8, 1))];
      final aug = runMonth(month: 8, income: 12000, expenses: julTxs, subs: augSubs);

      expect(aug.totalSubscriptions, 400);
      expect(aug.totalExpenses, 6400);
      // Bakiye: 26900 + 5600 = 32500

      // --- Q4: YIL SONU KAPANIŞI ---

      // EYLÜL - ARALIK: Stabil Dönem
      // Her ay 5600 ekleniyor.
      // 4 ay x 5600 = 22400.
      for (int m = 9; m <= 12; m++) {
        runMonth(month: m, income: 12000, expenses: julTxs, subs: augSubs);
      }

      // SONUÇ KONTROLLERİ
      // Bakiye: 32500 + 22400 = 54900
      expect(currentBalance, closeTo(54900, 1.0));

      print("✅ GRAND LION TEST SUCCESS: User survived logic changes. Final Balance: ${currentBalance.toStringAsFixed(2)}");
    });
  });
}