import 'package:flutter_test/flutter_test.dart';
import 'package:payday/core/models/monthly_summary.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/services/financial_insights_service.dart';

void main() {
  group('FinancialInsightsService monthly forward simulation', () {
    test('simulates one month ahead with preset balances and recurring costs', () {
      const userId = 'user_123';
      const year = 2025;
      const month = 5;
      const monthlyIncome = 6000.0; // yeni maaş dönemi
      const startingBalance = 1000.0; // mevcut bakiye

      // Hazır veri seti: bir abonelik, birikime giden gider, ek fon (gelir) ve günlük giderler
      final transactions = <Transaction>[
        Transaction(
          id: 't1',
          userId: userId,
          amount: 2000,
          categoryId: 'rent',
          categoryName: 'Rent',
          categoryEmoji: '🏠',
          date: DateTime(year, month, 1),
          isExpense: true,
        ),
        Transaction(
          id: 't2',
          userId: userId,
          amount: 800,
          categoryId: 'groceries',
          categoryName: 'Groceries',
          categoryEmoji: '🛒',
          date: DateTime(year, month, 5),
          isExpense: true,
        ),
        Transaction(
          id: 't3',
          userId: userId,
          amount: 400,
          categoryId: 'savings',
          categoryName: 'Savings Transfer',
          categoryEmoji: '💰',
          date: DateTime(year, month, 10),
          isExpense: true,
          relatedGoalId: 'goal_1',
        ),
        // Fon ekleme (gelir) test verisi: isExpense=false olduğu için toplam giderlere yansımaz
        Transaction(
          id: 't4',
          userId: userId,
          amount: 300,
          categoryId: 'add_fund',
          categoryName: 'Add Fund',
          categoryEmoji: '➕',
          date: DateTime(year, month, 12),
          isExpense: false,
        ),
      ];

      final subscriptions = <Subscription>[
        Subscription(
          id: 's1',
          userId: userId,
          name: 'Music',
          amount: 15,
          currency: 'USD',
          frequency: RecurrenceFrequency.monthly,
          category: SubscriptionCategory.streaming,
          nextBillingDate: DateTime(year, month, 28),
        ),
      ];

      // Önceki ay harcaması: artan harcamayı yakalamak için trend testi
      const previousMonthExpenses = 4000.0;

      final summary = FinancialInsightsService.generateMonthlySummary(
        userId: userId,
        year: year,
        month: month,
        totalIncome: monthlyIncome,
        transactions: transactions,
        subscriptions: subscriptions,
        previousMonthExpenses: previousMonthExpenses,
      );

      const expectedTotalExpenses = 2000 + 800 + 400; // yalnızca gider bayraklı işlemler
      const expectedSubscriptions = 15.0;
      const expectedLeftover = monthlyIncome - expectedTotalExpenses - expectedSubscriptions;

      expect(summary.totalExpenses, expectedTotalExpenses + expectedSubscriptions);
      expect(summary.totalSubscriptions, expectedSubscriptions);
      expect(summary.leftoverAmount, expectedLeftover);
      expect(summary.healthStatus, FinancialHealth.good);
      expect(summary.trend, SpendingTrend.decreasing);
      expect(summary.expensesByCategory['Rent'], 2000);
      expect(summary.expensesByCategory['Subscriptions'], expectedSubscriptions);

      // Fon ekleme (gelir) giderlere eklenmez
      expect(summary.expensesByCategory.containsKey('Add Fund'), isFalse);

      // Beklenen içgörü ve öneri sayıları: yüksek tasarruf oranı, en büyük kategori, azalan harcama, kalan para
      expect(summary.insights.length, 4);
      expect(summary.leftoverSuggestions.length, 4);

      // Bakiye simülasyonu: ay sonu beklenen bakiye
      final closingBalance = startingBalance + summary.leftoverAmount;
      expect(closingBalance, startingBalance + expectedLeftover);
    });

    test('simulates three consecutive months with carried balances and trends', () {
      const userId = 'user_456';
      const year = 2025;
      const monthlyIncome = 6000.0;
      const startingBalance = 1000.0;

      final subscriptions = <Subscription>[
        Subscription(
          id: 's1',
          userId: userId,
          name: 'Music',
          amount: 15,
          currency: 'USD',
          frequency: RecurrenceFrequency.monthly,
          category: SubscriptionCategory.streaming,
          nextBillingDate: DateTime(year, 5, 28),
        ),
      ];

      final monthExpenses = {
        5: <Transaction>[
          Transaction(
            id: 'm1_rent',
            userId: userId,
            amount: 2000,
            categoryId: 'rent',
            categoryName: 'Rent',
            categoryEmoji: '🏠',
            date: DateTime(year, 5, 1),
            isExpense: true,
          ),
          Transaction(
            id: 'm1_groceries',
            userId: userId,
            amount: 900,
            categoryId: 'groceries',
            categoryName: 'Groceries',
            categoryEmoji: '🛒',
            date: DateTime(year, 5, 5),
            isExpense: true,
          ),
          Transaction(
            id: 'm1_savings',
            userId: userId,
            amount: 600,
            categoryId: 'savings',
            categoryName: 'Savings Transfer',
            categoryEmoji: '💰',
            date: DateTime(year, 5, 10),
            isExpense: true,
            relatedGoalId: 'goal_1',
          ),
          Transaction(
            id: 'm1_travel',
            userId: userId,
            amount: 800,
            categoryId: 'travel',
            categoryName: 'Travel',
            categoryEmoji: '✈️',
            date: DateTime(year, 5, 18),
            isExpense: true,
          ),
        ],
        6: <Transaction>[
          Transaction(
            id: 'm2_rent',
            userId: userId,
            amount: 2000,
            categoryId: 'rent',
            categoryName: 'Rent',
            categoryEmoji: '🏠',
            date: DateTime(year, 6, 1),
            isExpense: true,
          ),
          Transaction(
            id: 'm2_groceries',
            userId: userId,
            amount: 700,
            categoryId: 'groceries',
            categoryName: 'Groceries',
            categoryEmoji: '🛒',
            date: DateTime(year, 6, 6),
            isExpense: true,
          ),
          Transaction(
            id: 'm2_savings',
            userId: userId,
            amount: 400,
            categoryId: 'savings',
            categoryName: 'Savings Transfer',
            categoryEmoji: '💰',
            date: DateTime(year, 6, 10),
            isExpense: true,
            relatedGoalId: 'goal_1',
          ),
          Transaction(
            id: 'm2_fun',
            userId: userId,
            amount: 300,
            categoryId: 'entertainment',
            categoryName: 'Entertainment',
            categoryEmoji: '🎉',
            date: DateTime(year, 6, 20),
            isExpense: true,
          ),
        ],
        7: <Transaction>[
          Transaction(
            id: 'm3_rent',
            userId: userId,
            amount: 2000,
            categoryId: 'rent',
            categoryName: 'Rent',
            categoryEmoji: '🏠',
            date: DateTime(year, 7, 1),
            isExpense: true,
          ),
          Transaction(
            id: 'm3_groceries',
            userId: userId,
            amount: 850,
            categoryId: 'groceries',
            categoryName: 'Groceries',
            categoryEmoji: '🛒',
            date: DateTime(year, 7, 5),
            isExpense: true,
          ),
          Transaction(
            id: 'm3_savings',
            userId: userId,
            amount: 400,
            categoryId: 'savings',
            categoryName: 'Savings Transfer',
            categoryEmoji: '💰',
            date: DateTime(year, 7, 10),
            isExpense: true,
            relatedGoalId: 'goal_1',
          ),
          Transaction(
            id: 'm3_car',
            userId: userId,
            amount: 500,
            categoryId: 'car',
            categoryName: 'Car',
            categoryEmoji: '🚗',
            date: DateTime(year, 7, 22),
            isExpense: true,
          ),
        ],
      };

      double balance = startingBalance;
      double? previousExpenses;

      MonthlySummary runMonth(int month, List<Transaction> tx) {
        final summary = FinancialInsightsService.generateMonthlySummary(
          userId: userId,
          year: year,
          month: month,
          totalIncome: monthlyIncome,
          transactions: tx,
          subscriptions: subscriptions,
          previousMonthExpenses: previousExpenses,
        );
        balance += summary.leftoverAmount;
        previousExpenses = tx.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);
        return summary;
      }

      final m1 = runMonth(5, monthExpenses[5]!);
      expect(m1.totalExpenses, 4300 + 15);
      expect(m1.leftoverAmount, 6000 - 4300 - 15);
      expect(m1.healthStatus, FinancialHealth.fair);
      expect(m1.trend, SpendingTrend.stable);
      expect(balance, startingBalance + m1.leftoverAmount);

      final m2 = runMonth(6, monthExpenses[6]!);
      expect(m2.totalExpenses, 3400 + 15);
      expect(m2.leftoverAmount, 6000 - 3400 - 15);
      expect(m2.healthStatus, FinancialHealth.good);
      expect(m2.trend, SpendingTrend.decreasing);
      expect(balance, startingBalance + m1.leftoverAmount + m2.leftoverAmount);

      final m3 = runMonth(7, monthExpenses[7]!);
      expect(m3.totalExpenses, 3750 + 15);
      expect(m3.leftoverAmount, 6000 - 3750 - 15);
      expect(m3.healthStatus, FinancialHealth.good);
      expect(m3.trend, SpendingTrend.increasing);
      expect(balance, startingBalance + m1.leftoverAmount + m2.leftoverAmount + m3.leftoverAmount);

      expect(m1.expensesByCategory['Rent'], 2000);
      expect(m2.expensesByCategory['Rent'], 2000);
      expect(m3.expensesByCategory['Rent'], 2000);
      expect(m3.expensesByCategory['Subscriptions'], 15);
    });
  });
}
