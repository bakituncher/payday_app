/// Subscription Processor Service
/// Abonelikleri otomatik işleyen servis - Ödeme günü geldiğinde bakiyeden düşer
///
/// Özellikler:
/// - Aktif abonelikleri kontrol eder
/// - Ödeme günü gelen/geçen abonelikleri işler
/// - Geçmişe dönük işlem desteği (Kullanıcı 1 ay açmazsa tüm geçmiş ödemeleri işler)
/// - TransactionManager ile atomik işlem garantisi
import 'package:payday/core/models/subscription.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/repositories/subscription_repository.dart';
import 'package:payday/core/services/transaction_manager_service.dart';
import 'package:payday/core/services/date_cycle_service.dart';
import 'package:uuid/uuid.dart';

class SubscriptionProcessorService {
  final SubscriptionRepository _subscriptionRepo;
  final TransactionManagerService _transactionManager;

  SubscriptionProcessorService({
    required SubscriptionRepository subscriptionRepo,
    required TransactionManagerService transactionManager,
  })  : _subscriptionRepo = subscriptionRepo,
        _transactionManager = transactionManager;

  /// Ana metod: Vadesi gelen abonelikleri kontrol edip işler
  ///
  /// Bu metod uygulama her açıldığında çağrılmalıdır.
  ///
  /// [userId] - Kullanıcı ID
  /// [processHistorical] - Geçmiş ödemeleri işle mi? (Varsayılan: true)
  ///                       true ise: Kullanıcı 3 ay açmamışsa 3 aylık ödeme işlenir
  ///                       false ise: Sadece bugünkü ödeme işlenir
  ///
  /// Returns: İşlenen abonelik sayısı
  Future<SubscriptionProcessResult> checkAndProcessDueSubscriptions(
    String userId, {
    bool processHistorical = true,
  }) async {
    print('💳 SubscriptionProcessor: Starting for user $userId');
    print('💳 Historical processing: $processHistorical');

    try {
      // ADIM 1: Aktif abonelikleri getir
      final subscriptions = await _subscriptionRepo.getActiveSubscriptions(userId);
      print('💳 SubscriptionProcessor: Found ${subscriptions.length} active subscriptions');

      if (subscriptions.isEmpty) {
        return SubscriptionProcessResult(
          success: true,
          processedCount: 0,
          totalAmount: 0.0,
          subscriptionNames: [],
        );
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int processedCount = 0;
      double totalAmount = 0.0;
      final processedNames = <String>[];
      final transactions = <Transaction>[];

      // ADIM 2: Her aboneliği kontrol et
      for (final sub in subscriptions) {
        try {
          // Aktif ve trial olmayan abonelikleri işle
          if (sub.status != SubscriptionStatus.active) {
            continue;
          }

          // Vadesi gelen işlemleri hesapla
          final result = await _processSubscription(
            subscription: sub,
            userId: userId,
            today: today,
            processHistorical: processHistorical,
          );

          if (result.transactionsCreated.isNotEmpty) {
            transactions.addAll(result.transactionsCreated);
            processedCount++;
            totalAmount += result.totalAmount;
            processedNames.add(sub.name);

            // Aboneliğin sonraki ödeme tarihini güncelle
            await _subscriptionRepo.updateSubscription(result.updatedSubscription);

            print('💳 SubscriptionProcessor: Processed ${sub.name} - ${result.transactionsCreated.length} payment(s)');
          }
        } catch (e) {
          print('❌ SubscriptionProcessor: Error processing ${sub.name}: $e');
          // Bir abonelik hatası diğerlerini etkilemez
          continue;
        }
      }

      // ADIM 3: Tüm işlemleri toplu olarak kaydet (Performans optimizasyonu)
      if (transactions.isNotEmpty) {
        print('💳 SubscriptionProcessor: Recording ${transactions.length} transaction(s)');
        await _transactionManager.processBatchTransactions(
          userId: userId,
          transactions: transactions,
        );
      }

      print('✅ SubscriptionProcessor: Complete - Processed: $processedCount, Total: $totalAmount');

      return SubscriptionProcessResult(
        success: true,
        processedCount: processedCount,
        totalAmount: totalAmount,
        subscriptionNames: processedNames,
      );
    } catch (e) {
      print('❌ SubscriptionProcessor: Fatal error: $e');
      return SubscriptionProcessResult(
        success: false,
        processedCount: 0,
        totalAmount: 0.0,
        subscriptionNames: [],
        error: e.toString(),
      );
    }
  }

  /// Tek bir aboneliği işler (Geçmiş ödemeleri dahil)
  ///
  /// Mantık:
  /// 1. Son ödeme tarihini kontrol et
  /// 2. Bugüne kadar kaç ödeme yapılması gerektiğini hesapla
  /// 3. Her ödeme için Transaction oluştur
  /// 4. Bir sonraki ödeme tarihini güncelle
  Future<_SubscriptionProcessDetails> _processSubscription({
    required Subscription subscription,
    required String userId,
    required DateTime today,
    required bool processHistorical,
  }) async {
    final transactions = <Transaction>[];
    double totalAmount = 0.0;
    DateTime currentBillingDate = subscription.nextBillingDate;

    // Trial -> Active: if trial ended and past date, flip to active before processing
    if (subscription.status == SubscriptionStatus.trial && subscription.trialEndsAt != null) {
      if (!subscription.trialEndsAt!.isAfter(today)) {
        subscription = subscription.copyWith(status: SubscriptionStatus.active);
      } else {
        // still in trial; skip billing
        return _SubscriptionProcessDetails(
          transactionsCreated: const [],
          totalAmount: 0.0,
          updatedSubscription: subscription,
        );
      }
    }

    // Grace period: if autoRenew is false, keep active until billing date, then cancel instead of charging
    if (!subscription.autoRenew && currentBillingDate.isAfter(today)) {
      return _SubscriptionProcessDetails(
        transactionsCreated: const [],
        totalAmount: 0.0,
        updatedSubscription: subscription,
      );
    }

    // Eğer ödeme günü henüz gelmediyse, işlem yapma
    if (currentBillingDate.isAfter(today)) {
      return _SubscriptionProcessDetails(
        transactionsCreated: [],
        totalAmount: 0.0,
        updatedSubscription: subscription,
      );
    }

    // If autoRenew is disabled and billing date is due/past: cancel without charging
    if (!subscription.autoRenew) {
      final nextDate = DateCycleService.calculateNextBillingDate(
        currentBillingDate,
        subscription.frequency,
      );
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.cancelled,
        cancelledAt: DateTime.now(),
        nextBillingDate: nextDate,
        updatedAt: DateTime.now(),
      );
      return _SubscriptionProcessDetails(
        transactionsCreated: const [],
        totalAmount: 0.0,
        updatedSubscription: updatedSubscription,
      );
    }

    // Geçmiş ödemeleri işle
    if (processHistorical) {
      // Bugüne kadar kaç ödeme yapılması gerektiğini hesapla
      int paymentsMissed = 0;
      DateTime checkDate = currentBillingDate;

      while (!checkDate.isAfter(today)) {
        // Her geçmiş ödeme için Transaction oluştur
        final transaction = Transaction(
          id: const Uuid().v4(),
          userId: userId,
          amount: subscription.amount,
          categoryId: _mapCategoryToId(subscription.category),
          categoryName: subscription.category.name,
          categoryEmoji: subscription.emoji,
          date: checkDate, // Gerçek ödeme tarihini kullan
          note: 'Auto-payment: ${subscription.name}',
          isExpense: true,
          subscriptionId: subscription.id,
          isRecurring: true,
        );

        transactions.add(transaction);
        totalAmount += subscription.amount;
        paymentsMissed++;

        // Bir sonraki ödeme tarihine geç
        checkDate = DateCycleService.calculateNextBillingDate(
          checkDate,
          subscription.frequency,
        );
      }

      // Güncellenen abonelik (Sonraki ödeme tarihi)
      final updatedSubscription = subscription.copyWith(
        nextBillingDate: checkDate,
        updatedAt: DateTime.now(),
      );

      if (paymentsMissed > 1) {
        print('⚠️ SubscriptionProcessor: ${subscription.name} had $paymentsMissed missed payments');
      }

      return _SubscriptionProcessDetails(
        transactionsCreated: transactions,
        totalAmount: totalAmount,
        updatedSubscription: updatedSubscription,
      );
    } else {
      // Sadece bugünkü ödemeyi işle
      if (_isSameDay(currentBillingDate, today) || currentBillingDate.isBefore(today)) {
        final transaction = Transaction(
          id: const Uuid().v4(),
          userId: userId,
          amount: subscription.amount,
          categoryId: _mapCategoryToId(subscription.category),
          categoryName: subscription.category.name,
          categoryEmoji: subscription.emoji,
          date: DateTime.now(),
          note: 'Auto-payment: ${subscription.name}',
          isExpense: true,
          subscriptionId: subscription.id,
          isRecurring: true,
        );

        transactions.add(transaction);
        totalAmount = subscription.amount;

        // Bir sonraki ödeme tarihini hesapla
        final nextDate = DateCycleService.calculateNextBillingDate(
          currentBillingDate,
          subscription.frequency,
        );

        final updatedSubscription = subscription.copyWith(
          nextBillingDate: nextDate,
          updatedAt: DateTime.now(),
        );

        return _SubscriptionProcessDetails(
          transactionsCreated: transactions,
          totalAmount: totalAmount,
          updatedSubscription: updatedSubscription,
        );
      }

      // Ödeme günü henüz gelmediyse
      return _SubscriptionProcessDetails(
        transactionsCreated: [],
        totalAmount: 0.0,
        updatedSubscription: subscription,
      );
    }
  }

  /// Kategori enum'unu ID'ye çevir
  String _mapCategoryToId(SubscriptionCategory category) {
    // Map to AppConstants transaction category IDs to ensure reports/graphs align
    switch (category) {
      case SubscriptionCategory.streaming:
      case SubscriptionCategory.gaming:
      case SubscriptionCategory.newsMedia:
        return 'entertainment';
      case SubscriptionCategory.productivity:
      case SubscriptionCategory.cloudStorage:
        return 'bills';
      case SubscriptionCategory.fitness:
        return 'health';
      case SubscriptionCategory.foodDelivery:
      case SubscriptionCategory.shopping:
        return 'shopping';
      case SubscriptionCategory.finance:
        return 'bills';
      case SubscriptionCategory.education:
        return 'other';
      case SubscriptionCategory.utilities:
        return 'bills';
      case SubscriptionCategory.other:
        return 'other';
    }
  }

  /// Tarih karşılaştırma yardımcı fonksiyonu
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// İşleme sonucu
class SubscriptionProcessResult {
  final bool success;
  final int processedCount;
  final double totalAmount;
  final List<String> subscriptionNames;
  final String? error;

  const SubscriptionProcessResult({
    required this.success,
    required this.processedCount,
    required this.totalAmount,
    required this.subscriptionNames,
    this.error,
  });
}

/// Tek bir aboneliğin işleme detayları (Internal use)
class _SubscriptionProcessDetails {
  final List<Transaction> transactionsCreated;
  final double totalAmount;
  final Subscription updatedSubscription;

  const _SubscriptionProcessDetails({
    required this.transactionsCreated,
    required this.totalAmount,
    required this.updatedSubscription,
  });
}
