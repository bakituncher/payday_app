import 'package:flutter_test/flutter_test.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/services/financial_insights_service.dart';

void main() {
  /// Test verilerini temiz tutmak için yardımcı veri üreticileri (Helpers)
  Transaction _createTx({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    bool isExpense = true,
  }) {
    return Transaction(
      id: id,
      userId: 'test_user',
      amount: amount,
      categoryId: category.toLowerCase(),
      categoryName: category,
      categoryEmoji: '🏷️',
      date: date,
      isExpense: isExpense,
    );
  }

  Subscription _createSub({
    required String name,
    required double amount,
    required DateTime nextBilling,
  }) {
    return Subscription(
      id: 'sub_${name.toLowerCase()}',
      userId: 'test_user',
      name: name,
      amount: amount,
      currency: 'USD',
      frequency: RecurrenceFrequency.monthly,
      category: SubscriptionCategory.streaming,
      nextBillingDate: nextBilling,
    );
  }

  group('💰 FinancialInsightsService - Stability & Integrity Suite', () {
    const userId = 'user_enterprise_test';
    const year = 2025;

    test('SCENARIO: Precise calculation checks (Floating Point Safety)', () {
      // GIVEN: Küsuratlı harcamalar içeren bir veri seti
      final transactions = [
        _createTx(id: 't1', amount: 100.55, category: 'Food', date: DateTime(year, 5, 1)),
        _createTx(id: 't2', amount: 200.20, category: 'Transport', date: DateTime(year, 5, 2)),
        // Gider olmayan işlem (Income/Transfer) - Hesaplamaya dahil edilmemeli
        _createTx(id: 't3', amount: 5000.00, category: 'Deposit', date: DateTime(year, 5, 3), isExpense: false),
      ];

      // WHEN: Servis çalıştırıldığında
      final summary = FinancialInsightsService.generateMonthlySummary(
        userId: userId,
        year: year,
        month: 5,
        totalIncome: 1000.0,
        transactions: transactions,
        subscriptions: [],
        previousMonthExpenses: 0,
      );

      // THEN: Toplamlar kuruşu kuruşuna (delta: 0.001) doğru olmalı
      expect(summary.totalExpenses, closeTo(300.75, 0.001), reason: "Harcamalar ondalık hassasiyetle toplanmalıdır.");
      expect(summary.expensesByCategory.containsKey('Deposit'), isFalse, reason: "Gider olmayan işlemler harcama kategorilerine girmemelidir.");
      expect(summary.expensesByCategory['Food'], closeTo(100.55, 0.001));
    });

    test('SCENARIO: Multi-Month Simulation with Trend & Balance Carry-over', () {
      // Bu test, kullanıcının 3 aylık mali yolculuğunun simülasyonudur.
      // Bakiye devri ve harcama trendlerinin (Artan/Azalan) doğru tespiti kritiktir.

      const monthlyIncome = 6000.0;
      double currentBalance = 1000.0; // Başlangıç Bakiyesi
      double? lastMonthExpenses;

      // Simülasyon Runner Fonksiyonu
      MonthlySummary runSimulationMonth(int month, List<Transaction> txs, List<Subscription> subs) {
        final summary = FinancialInsightsService.generateMonthlySummary(
          userId: userId,
          year: year,
          month: month,
          totalIncome: monthlyIncome,
          transactions: txs,
          subscriptions: subs,
          previousMonthExpenses: lastMonthExpenses,
        );

        // State Update (Gerçek uygulamadaki Provider mantığı)
        currentBalance += summary.leftoverAmount;
        lastMonthExpenses = summary.totalExpenses;

        return summary;
      }

      // --- AY 1: Yüksek Harcama (High Expense) ---
      final m1Txs = [
        _createTx(id: 'm1_1', amount: 3000, category: 'Rent', date: DateTime(year, 5, 1)),
        _createTx(id: 'm1_2', amount: 1500, category: 'Lifestyle', date: DateTime(year, 5, 10)),
      ];
      final m1 = runSimulationMonth(5, m1Txs, []);

      expect(m1.healthStatus, isNot(FinancialHealth.good), reason: "Yüksek harcama durumunda sağlık 'Good' olmamalıdır.");
      expect(m1.trend, SpendingTrend.stable, reason: "İlk ay karşılaştırma verisi olmadığı için trend stabil olmalıdır.");
      expect(currentBalance, closeTo(1000 + (6000 - 4500), 0.01));

      // --- AY 2: Tasarruf Dönemi (Decreasing Trend) ---
      final m2Txs = [
        _createTx(id: 'm2_1', amount: 3000, category: 'Rent', date: DateTime(year, 6, 1)),
        _createTx(id: 'm2_2', amount: 500, category: 'Lifestyle', date: DateTime(year, 6, 10)), // Harcama düştü
      ];
      final m2 = runSimulationMonth(6, m2Txs, []);

      expect(m2.totalExpenses, 3500);
      expect(m2.trend, SpendingTrend.decreasing, reason: "Önceki aya göre harcama düştüğü için trend 'Decreasing' olmalı.");
      expect(m2.healthStatus, FinancialHealth.good);

      // Bakiye kümülatif olarak artmalı
      // Bakiye = (Başlangıç) + (Ay 1 Kalan) + (Ay 2 Kalan)
      // 1000 + 1500 + 2500 = 5000
      expect(currentBalance, closeTo(5000, 0.01), reason: "Bakiye kümülatif olarak doğru taşınmalıdır.");

      // --- AY 3: Aboneliklerin Devreye Girmesi & Harcama Artışı ---
      final m3Txs = [
        _createTx(id: 'm3_1', amount: 3000, category: 'Rent', date: DateTime(year, 7, 1)),
        _createTx(id: 'm3_2', amount: 1000, category: 'Travel', date: DateTime(year, 7, 15)),
      ];
      final m3Subs = [
        _createSub(name: 'Netflix', amount: 200, nextBilling: DateTime(year, 7, 20)),
      ];

      final m3 = runSimulationMonth(7, m3Txs, m3Subs);

      expect(m3.totalExpenses, 4000 + 200); // Tx + Subs
      expect(m3.totalSubscriptions, 200);
      expect(m3.trend, SpendingTrend.increasing, reason: "3500'den 4200'e çıkış olduğu için trend artış göstermeli.");

      // Son Bakiye Kontrolü: 5000 + (6000 - 4200) = 6800
      expect(currentBalance, closeTo(6800, 0.01));
    });

    test('SCENARIO: Edge Case - Zero Transactions & Full Saving', () {
      // GIVEN: Hiç harcama yok
      final summary = FinancialInsightsService.generateMonthlySummary(
        userId: userId,
        year: year,
        month: 8,
        totalIncome: 5000.0,
        transactions: [],
        subscriptions: [],
        previousMonthExpenses: 2000.0,
      );

      // THEN
      expect(summary.totalExpenses, 0);
      expect(summary.leftoverAmount, 5000);
      expect(summary.trend, SpendingTrend.decreasing); // 2000 -> 0
      expect(summary.expensesByCategory, isEmpty);
      // Bu durumda sistemin "Mükemmel Tasarruf" gibi bir insight üretmesi beklenebilir
      expect(summary.insights.length, greaterThan(0), reason: "Sıfır harcama durumunda bile kullanıcıya insight verilmelidir.");
    });
  });
}