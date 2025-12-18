import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/providers/auth_providers.dart'; // Fixed import: auth_providers.dart (plural) based on file list
import 'package:payday/core/providers/repository_providers.dart';

/// Provider for historical monthly spending
/// Returns a map of DateTime (Start of Month) -> Total Expenses
final historicalSpendingProvider = FutureProvider<Map<DateTime, double>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId.isEmpty) return {};

  // Fetch all transactions (Assuming local filtering for now)
  // Ideally, we'd have a query for this, but `getTransactions` works for MVP.
  final transactions = await repository.getTransactions(userId);

  final now = DateTime.now();
  final sixMonthsAgo = DateTime(now.year, now.month - 5, 1); // roughly

  final history = <DateTime, double>{};

  // Initialize last 6 months with 0
  for (int i = 0; i < 6; i++) {
    final month = DateTime(now.year, now.month - i, 1);
    history[month] = 0.0;
  }

  for (final t in transactions) {
    if (!t.isExpense) continue;
    if (t.date.isBefore(sixMonthsAgo)) continue;

    final monthKey = DateTime(t.date.year, t.date.month, 1);
    if (history.containsKey(monthKey)) {
      history[monthKey] = (history[monthKey] ?? 0.0) + t.amount;
    }
  }

  return history;
});
