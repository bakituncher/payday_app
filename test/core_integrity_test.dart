
import 'package:flutter_test/flutter_test.dart';
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/services/date_cycle_service.dart';

void main() {
  group('🛡️ CORE INTEGRITY SUITE: Data & Time Logic Verification', () {

    // =========================================================================
    // 1. TRANSACTION MODEL TESTLERİ (Veri Bütünlüğü)
    // =========================================================================
    group('💸 Transaction Logic Tests', () {
      test('Calculates monthly equivalent correctly for recurring payments', () {
        final weeklyTx = Transaction(
          id: 't1',
          userId: 'user',
          amount: 100,
          categoryId: 'kids',
          categoryName: 'Allowance',
          categoryEmoji: '🧸',
          date: DateTime.now(),
          isRecurring: true,
          frequency: TransactionFrequency.weekly,
        );

        // Beklenen: 100 * 4.33 = 433.0
        expect(weeklyTx.monthlyEquivalent, 433.0, reason: "Haftalık harcamalar 4.33 katsayısıyla aya çevrilmeli.");

        final biweeklyTx = weeklyTx.copyWith(
          amount: 200,
          frequency: TransactionFrequency.biweekly,
        );
        // Beklenen: 200 * 2.17 = 434.0
        expect(biweeklyTx.monthlyEquivalent, 434.0, reason: "Bi-weekly harcamalar 2.17 katsayısıyla hesaplanmalı.");

        final yearlyTx = weeklyTx.copyWith(
          amount: 1200,
          frequency: TransactionFrequency.yearly,
        );
        // Beklenen: 1200 / 12 = 100.0
        expect(yearlyTx.monthlyEquivalent, 100.0, reason: "Yıllık harcama aya tam bölünmeli.");
      });

      test('JSON Serialization preserves critical data', () {
        final original = Transaction(
          id: 't_json',
          userId: 'u1',
          amount: 50.55,
          categoryId: 'food',
          categoryName: 'Food',
          categoryEmoji: '🍔',
          date: DateTime(2025, 5, 20),
          frequency: TransactionFrequency.monthly,
          isRecurring: true,
        );

        final json = original.toJson();
        final recovered = Transaction.fromJson(json);

        expect(recovered.amount, 50.55);
        expect(recovered.frequency, TransactionFrequency.monthly);
        expect(recovered.date, original.date);
      });
    });

    // =========================================================================
    // 2. SUBSCRIPTION MODEL TESTLERİ (Abonelik Mantığı)
    // =========================================================================
    group('🔄 Subscription Logic Tests', () {
      test('Calculates yearly and monthly costs accurately', () {
        final monthlySub = Subscription(
          id: 's1',
          userId: 'u1',
          name: 'Netflix',
          amount: 100,
          currency: 'TRY',
          frequency: RecurrenceFrequency.monthly,
          category: SubscriptionCategory.streaming,
          nextBillingDate: DateTime.now(),
        );

        expect(monthlySub.yearlyCost, 1200, reason: "Aylık 100 TL, yılda 1200 TL etmeli.");

        final yearlySub = monthlySub.copyWith(
          name: 'Prime',
          amount: 1200,
          frequency: RecurrenceFrequency.yearly,
        );

        expect(yearlySub.monthlyCost, 100, reason: "Yıllık 1200 TL, aya vurunca 100 TL etmeli.");
      });

      test('Smart Due Date Detection (Reminder Logic)', () {
        final today = DateTime.now();
        final dueTomorrow = today.add(const Duration(days: 1));
        final dueInWeek = today.add(const Duration(days: 7));

        final subTomorrow = Subscription(
          id: 's2',
          userId: 'u1',
          name: 'Urgent',
          amount: 10,
          currency: 'USD',
          frequency: RecurrenceFrequency.monthly,
          category: SubscriptionCategory.utilities,
          nextBillingDate: dueTomorrow,
        );

        expect(subTomorrow.isDueSoon(3), isTrue, reason: "Yarınki ödeme 'Yaklaşıyor' olarak işaretlenmeli.");

        final subNextWeek = subTomorrow.copyWith(nextBillingDate: dueInWeek);
        expect(subNextWeek.isDueSoon(3), isFalse, reason: "Haftaya olan ödeme acil değil.");
      });
    });

    // =========================================================================
    // 3. DATE CYCLE SERVICE TESTLERİ (Zaman Algoritmaları)
    // =========================================================================
    group('📅 DateCycleService Logic Tests (The Brain of Time)', () {

      test('Industry Standard: Adjusts Weekend Paydays to Friday', () {
        // DÜZELTME: Gelecekteki bir tarihi (2030) kullanıyoruz ki "Geçmiş Tarih" hesaplamasına girmesin.
        // 1 Haziran 2030 = CUMARTESİ.
        // Beklenti: 31 Mayıs 2030 (CUMA) olarak ödenmesi.

        final saturdayPayday = DateTime(2030, 6, 1);

        final adjusted = DateCycleService.calculateNextPayday(saturdayPayday, 'Monthly');

        expect(adjusted.weekday, DateTime.friday, reason: "Cumartesi (2030-06-01) maaşı Cuma'ya (2030-05-31) çekilmeli.");
        expect(adjusted.day, 31, reason: "Gün 31 Mayıs olmalı.");
        expect(adjusted.year, 2030);

        // 2 Haziran 2030 = PAZAR.
        // Beklenti: 31 Mayıs 2030 (CUMA).
        final sundayPayday = DateTime(2030, 6, 2);
        final adjustedSunday = DateCycleService.calculateNextPayday(sundayPayday, 'Monthly');

        expect(adjustedSunday.weekday, DateTime.friday, reason: "Pazar maaşı Cuma'ya çekilmeli.");
        expect(adjustedSunday.day, 31);
      });

      test('Fix: "Skip Today Bug" check (Today CAN be payday)', () {
        final today = DateTime.now();

        final nextPayday = DateCycleService.calculateNextPayday(today, 'Monthly');

        // Eğer bugün hafta içi ise, tarih değişmemeli (Bugün maaş günüyse bugün ödenir).
        if (today.weekday <= DateTime.friday) {
          expect(
              _isSameDay(nextPayday, today),
              isTrue,
              reason: "Maaş günü bugünse ve hafta içi ise, tarih ileri atılmamalı."
          );
        }
      });

      test('Get Pay Period Boundary correctly identifies previous payday', () {
        // Gelecek bir tarih veriyoruz
        final nextPayday = DateTime(2030, 5, 15);
        final period = DateCycleService.getCurrentPayPeriod(
            nextPayday: nextPayday,
            payCycle: 'Monthly'
        );

        // Beklenen Başlangıç: 15 Nisan 2030
        expect(period.start.month, 4, reason: "Dönem başlangıcı bir önceki ay olmalı.");
        expect(period.start.day, 15);
        expect(period.end, nextPayday);
      });
    });
  });
}

// Helper
bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}