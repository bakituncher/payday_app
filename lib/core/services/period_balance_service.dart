import 'package:payday/core/models/period_balance.dart';
import 'package:payday/core/models/pay_period.dart';
import 'package:payday/core/repositories/transaction_repository.dart';

/// Dönem (pay period) bazlı bakiyeyi ledger'dan (transactions) hesaplar.
///
/// Pool System Integration:
/// - Bu servis tüm gelir ve gider işlemlerini transaction log'dan çeker
/// - Payday Deposit işlemleri otomatik olarak income olarak sayılır
/// - Opening Balance, önceki dönemin Pool Balance'ıdır
/// - UI'da "para kayboldu" hissini engellemek için dönem ekranlarında bu hesap kullanılır.
class PeriodBalanceService {
  final TransactionRepository _transactionRepository;

  PeriodBalanceService({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository;

  /// [openingBalance] önceki dönemden devreden tutardır.
  /// Dönem aralığı: [period.start, period.end) (start dahil, end hariç)
  Future<PeriodBalance> compute({
    required String userId,
    required PayPeriod period,
    required double openingBalance,
  }) async {
    // Repo API'si "cycleStart" ile çekiyor; end filtresini burada uygularız.
    final transactions = await _transactionRepository.getTransactionsForCurrentCycle(
      userId,
      period.start,
    );

    final periodTx = transactions
        .where((t) =>
            (t.date.isAtSameMomentAs(period.start) || t.date.isAfter(period.start)) &&
            t.date.isBefore(period.end))
        .toList();

    final expensesGross = periodTx
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    // Savings goal'dan bütçeye geri dönüş (iade gibi), net harcamayı azaltır.
    final savingsWithdrawals = periodTx
        .where((t) => !t.isExpense && t.relatedGoalId != null)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    // Normal gelirler (maaş, manuel gelir vs.)
    final income = periodTx
        .where((t) => !t.isExpense && t.relatedGoalId == null)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final expensesNet = (expensesGross - savingsWithdrawals) < 0
        ? 0.0
        : (expensesGross - savingsWithdrawals);

    final closingBalance = openingBalance + income - expensesGross + savingsWithdrawals;

    return PeriodBalance(
      periodStart: period.start,
      periodEnd: period.end,
      openingBalance: openingBalance,
      income: income,
      expensesGross: expensesGross,
      savingsWithdrawals: savingsWithdrawals,
      expensesNet: expensesNet,
      closingBalance: closingBalance,
    );
  }

  /// Otomatik açılış bakiyesi hesaplayan sürüm: tüm geçmiş işlemlerden devreden tutarı bulur.
  Future<PeriodBalance> computeAuto({
    required String userId,
    required PayPeriod period,
  }) async {
    // 1) Kullanıcının tüm işlemlerini al
    final allTransactions = await _transactionRepository.getTransactions(userId);

    // 2) Bu dönemin başlangıcından önceki net bakiye = devreden açılış bakiyesi
    final openingBalance = allTransactions
        .where((t) => t.date.isBefore(period.start))
        .fold<double>(0.0, (sum, t) {
          if (t.isExpense) return sum - t.amount;
          return sum + t.amount;
        });

    // 3) Bu dönemdeki işlemler
    final periodTx = allTransactions
        .where((t) =>
            (t.date.isAtSameMomentAs(period.start) || t.date.isAfter(period.start)) &&
            t.date.isBefore(period.end))
        .toList();

    final expensesGross = periodTx
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final savingsWithdrawals = periodTx
        .where((t) => !t.isExpense && t.relatedGoalId != null)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final income = periodTx
        .where((t) => !t.isExpense && t.relatedGoalId == null)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final expensesNet = (expensesGross - savingsWithdrawals) < 0
        ? 0.0
        : (expensesGross - savingsWithdrawals);

    // 4) Kapanış bakiyesi
    final closingBalance = openingBalance + income - expensesGross + savingsWithdrawals;

    return PeriodBalance(
      periodStart: period.start,
      periodEnd: period.end,
      openingBalance: openingBalance,
      income: income,
      expensesGross: expensesGross,
      savingsWithdrawals: savingsWithdrawals,
      expensesNet: expensesNet,
      closingBalance: closingBalance,
    );
  }
}
