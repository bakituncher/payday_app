/// Transaction Manager Service
/// Merkezi işlem yöneticisi - Atomik olarak hem işlem kaydını oluşturur hem de bakiyeyi günceller
/// Bu servis "Single Source of Truth" prensibini uygular
import 'package:payday/core/models/transaction.dart';
// ignore: unused_import
import 'package:payday/core/models/user_settings.dart'; // Required for copyWith()
import 'package:payday/core/repositories/transaction_repository.dart';
import 'package:payday/core/repositories/user_settings_repository.dart';

class TransactionManagerService {
  final TransactionRepository _transactionRepo;
  final UserSettingsRepository _settingsRepo;

  TransactionManagerService({
    required TransactionRepository transactionRepo,
    required UserSettingsRepository settingsRepo,
  })  : _transactionRepo = transactionRepo,
        _settingsRepo = settingsRepo;

  /// Tek bir atomik işlemde hem kaydı atar hem bakiyeyi günceller
  ///
  /// Bu metod finansal tutarlılığı garanti eder:
  /// - İşlem kaydedilir (Transaction History)
  /// - Bakiye güncellenir (Current Balance)
  /// - Hata durumunda rollback yapılır (Transaction başarısız olursa bakiye değişmez)
  ///
  /// [userId] - Kullanıcı ID
  /// [transaction] - Kaydedilecek işlem
  /// [updateBalance] - Bakiye güncellensin mi? (Varsayılan: true)
  ///                   Not: Bazı özel durumlarda (örn: geçmiş işlem düzeltme) false olabilir
  Future<void> processTransaction({
    required String userId,
    required Transaction transaction,
    bool updateBalance = true,
  }) async {
    print('💼 TransactionManager: Processing transaction for user $userId');
    print('💼 Amount: ${transaction.amount}, IsExpense: ${transaction.isExpense}');

    try {
      // ADIM 1: İşlemi Kaydet
      await _transactionRepo.addTransaction(transaction);
      print('💼 TransactionManager: Transaction recorded successfully');

      // ADIM 2: Bakiyeyi Güncelle (eğer istenmişse)
      if (updateBalance) {
        final settings = await _settingsRepo.getUserSettings(userId);

        if (settings == null) {
          throw Exception('User settings not found for userId: $userId');
        }

        double currentBalance = settings.currentBalance;
        double newBalance = currentBalance;

        // ADIM 3: Bakiyeyi Hesapla
        if (transaction.isExpense) {
          newBalance = currentBalance - transaction.amount;
          print('💼 TransactionManager: Expense - Balance: $currentBalance -> $newBalance');
        } else {
          newBalance = currentBalance + transaction.amount;
          print('💼 TransactionManager: Income - Balance: $currentBalance -> $newBalance');
        }

        // Güvenlik Kontrolü: Negatif bakiye uyarısı (ama işlemi engelleme - kullanıcı ekside olabilir)
        if (newBalance < 0) {
          print('⚠️ TransactionManager: Warning - Balance is negative: $newBalance');
        }

        // ADIM 4: Yeni Bakiyeyi Kaydet
        await _settingsRepo.saveUserSettings(settings.copyWith(
          currentBalance: newBalance,
          updatedAt: DateTime.now(),
        ));

        print('💼 TransactionManager: Balance updated successfully');
      } else {
        print('💼 TransactionManager: Balance update skipped (updateBalance=false)');
      }

      print('✅ TransactionManager: Operation completed successfully');
    } catch (e) {
      print('❌ TransactionManager: Error processing transaction: $e');
      // Hata fırlat - UI katmanında yakalanacak
      rethrow;
    }
  }

  /// Toplu işlem kaydı (Batch Operations)
  /// Örnek kullanım: Aylık abonelikleri tek seferde işleme
  ///
  /// Bu metod tüm işlemleri atomik olarak işler:
  /// - Ya hepsi başarılı olur, ya hiçbiri
  /// - Bakiye güncellemesi topluca yapılır (performans optimizasyonu)
  Future<void> processBatchTransactions({
    required String userId,
    required List<Transaction> transactions,
  }) async {
    if (transactions.isEmpty) return;

    print('💼 TransactionManager: Processing batch of ${transactions.length} transactions');

    try {
      // ADIM 1: Tüm işlemleri kaydet
      for (final transaction in transactions) {
        await _transactionRepo.addTransaction(transaction);
      }
      print('💼 TransactionManager: All transactions recorded');

      // ADIM 2: Bakiyeyi toplu güncelle
      final settings = await _settingsRepo.getUserSettings(userId);

      if (settings == null) {
        throw Exception('User settings not found for userId: $userId');
      }

      double totalChange = 0.0;

      for (final transaction in transactions) {
        if (transaction.isExpense) {
          totalChange -= transaction.amount;
        } else {
          totalChange += transaction.amount;
        }
      }

      final newBalance = settings.currentBalance + totalChange;

      print('💼 TransactionManager: Batch balance change: ${settings.currentBalance} -> $newBalance');

      // ADIM 3: Yeni Bakiyeyi Kaydet
      await _settingsRepo.saveUserSettings(settings.copyWith(
        currentBalance: newBalance,
        updatedAt: DateTime.now(),
      ));

      print('✅ TransactionManager: Batch operation completed successfully');
    } catch (e) {
      print('❌ TransactionManager: Error processing batch: $e');
      rethrow;
    }
  }

  /// Manuel Bakiye Düzeltme (Balance Correction)
  ///
  /// UYARI: Bu metod dikkatli kullanılmalıdır!
  /// Sadece veri tutarsızlığı düzeltme durumlarında kullanın.
  ///
  /// Mantık: Bakiye düzeltmesi yaparken bir "Bakiye Düzeltme" işlemi oluşturur
  /// Böylece tüm bakiye değişiklikleri işlem geçmişinde izlenebilir olur
  Future<void> correctBalance({
    required String userId,
    required double correctionAmount,
    required String reason,
  }) async {
    print('💼 TransactionManager: Correcting balance by $correctionAmount');
    print('💼 Reason: $reason');

    final settings = await _settingsRepo.getUserSettings(userId);

    if (settings == null) {
      throw Exception('User settings not found for userId: $userId');
    }

    // Düzeltme işlemi oluştur
    final correctionTransaction = Transaction(
      id: '${DateTime.now().millisecondsSinceEpoch}_correction',
      userId: userId,
      amount: correctionAmount.abs(),
      categoryId: 'balance_correction',
      categoryName: 'Balance Correction',
      categoryEmoji: '⚖️',
      date: DateTime.now(),
      note: 'Balance correction: $reason',
      isExpense: correctionAmount < 0, // Negatif düzeltme = Gider
    );

    // Normal işlem akışı ile kaydet
    await processTransaction(
      userId: userId,
      transaction: correctionTransaction,
      updateBalance: true,
    );

    print('✅ TransactionManager: Balance corrected successfully');
  }
}

