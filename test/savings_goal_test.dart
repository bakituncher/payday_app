import 'package:flutter_test/flutter_test.dart';
import 'package:payday/core/models/savings_goal.dart';

void main() {
  group('🎯 DREAM CATCHER SUITE: Savings & Goals Logic', () {

    // =========================================================================
    // 1. İLERLEME VE TAMAMLANMA MANTIĞI
    // =========================================================================
    test('Calculates progress percentage correctly (Clamped to 100%)', () {
      // SENARYO: 10.000 TL hedefim var, 2.500 TL biriktirdim.
      // Beklenti: %25 ilerleme.

      final goal = SavingsGoal(
        id: 'g1',
        userId: 'u1',
        name: 'New Laptop',
        targetAmount: 10000,
        currentAmount: 2500,
        emoji: '💻', // Modelde zorunlu
        createdAt: DateTime.now(), // Modelde zorunlu
        targetDate: DateTime.now().add(const Duration(days: 30)),
      );

      // Modelindeki extension'ı kullanıyoruz
      expect(goal.progressPercentage, 25.0, reason: "2500, 10000'in %25'idir.");

      // SENARYO: Hedefi aştım! (11.000 biriktirdim)
      // Senin modelindeki kod: return progress.clamp(0.0, 100.0);
      // Bu yüzden %110 DEĞİL, %100 beklemeliyiz.
      final overAchieved = goal.copyWith(currentAmount: 11000);

      expect(overAchieved.progressPercentage, 100.0, reason: "Model mantığı gereği ilerleme %100'ü geçemez.");
    });

    test('Determines "Completed" status accurately', () {
      // SENARYO: Hedef 5000, Mevcut 4999.
      // Sonuç: Tamamlanmadı.
      final almostThere = SavingsGoal(
        id: 'g2',
        userId: 'u1',
        name: 'Vacation',
        targetAmount: 5000,
        currentAmount: 4999,
        emoji: '🏖️',
        createdAt: DateTime.now(),
        targetDate: DateTime.now(),
      );

      expect(almostThere.isCompleted, isFalse, reason: "1 TL eksikse bile bitmiş sayılmaz.");

      // SENARYO: Hedef 5000, Mevcut 5000.
      final done = almostThere.copyWith(currentAmount: 5000);
      expect(done.isCompleted, isTrue, reason: "Hedef tutturulduğunda tamamlandı sayılmalı.");
    });

    test('Calculates Remaining Amount correctly', () {
      final goal = SavingsGoal(
        id: 'g3',
        userId: 'u1',
        name: 'Car',
        targetAmount: 10000,
        currentAmount: 3000,
        emoji: '🚗',
        createdAt: DateTime.now(),
      );

      // 10000 - 3000 = 7000 kalmalı
      expect(goal.remainingAmount, 7000.0);

      // Fazla biriktirince kalan 0 olmalı (negatif olmamalı)
      final over = goal.copyWith(currentAmount: 12000);
      expect(over.remainingAmount, 0.0, reason: "Fazla birikimde kalan tutar 0 olmalı.");
    });

    // =========================================================================
    // 2. ZAMAN VE ACİLİYET MANTIĞI
    // =========================================================================
    test('Handling "No Deadline" goals', () {
      // Bazı hedeflerin tarihi olmaz (Örn: Emeklilik).
      // Uygulama null tarih görünce çökmüyor mu?

      final infiniteGoal = SavingsGoal(
        id: 'g4',
        userId: 'u1',
        name: 'Retirement',
        targetAmount: 1000000,
        currentAmount: 5000,
        emoji: '👴',
        createdAt: DateTime.now(),
        targetDate: null, // Tarih yok
      );

      expect(infiniteGoal.targetDate, isNull);
      // Burada hata almamak bile bir başarıdır (Null Safety Test).
    });

    // =========================================================================
    // 3. VERİ GÜVENLİĞİ (MODEL BÜTÜNLÜĞÜ)
    // =========================================================================
    test('JSON Serialization preserves Goal Data', () {
      // Veritabanına kaydedip geri okuduğumuzda veri bozuluyor mu?
      final original = SavingsGoal(
        id: 'g_json',
        userId: 'u_test',
        name: 'Tesla Model Y',
        targetAmount: 2000000,
        currentAmount: 500000,
        emoji: '🚗',
        createdAt: DateTime(2025, 1, 1),
        targetDate: DateTime(2026, 1, 1),
        autoTransferEnabled: true,
        autoTransferAmount: 1000.0,
      );

      final json = original.toJson();
      final recovered = SavingsGoal.fromJson(json);

      expect(recovered.name, 'Tesla Model Y');
      expect(recovered.targetAmount, 2000000);
      expect(recovered.emoji, '🚗');
      expect(recovered.autoTransferEnabled, isTrue);
      expect(recovered.createdAt, original.createdAt);
    });
  });
}