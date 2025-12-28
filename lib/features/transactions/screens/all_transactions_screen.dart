/// All Transactions Screen
/// Shows complete list of transactions with search and filter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/features/transactions/screens/transaction_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:payday/core/services/ad_service.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';

class AllTransactionsScreen extends ConsumerStatefulWidget {
  final String currency;

  const AllTransactionsScreen({
    super.key,
    required this.currency,
  });

  @override
  ConsumerState<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(currentCycleTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.getTextPrimary(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Transactions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.getTextSecondary(context)),
                filled: true,
                fillColor: AppColors.getSubtle(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPink),
              ),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
              data: (transactions) {
                // Filter transactions
                var filtered = transactions.where((t) {
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    return t.categoryName.toLowerCase().contains(query) ||
                        t.note.toLowerCase().contains(query);
                  }
                  return true;
                }).toList();

                if (_selectedCategory != null) {
                  filtered = filtered
                      .where((t) => t.categoryId == _selectedCategory)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState(theme);
                }

                // Group by date
                final grouped = _groupByDate(filtered);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    return _buildDateGroup(
                      theme,
                      entry.key,
                      entry.value,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    for (final t in transactions) {
      final key = _formatDateHeader(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMMM d, yyyy').format(date);
  }

  Widget _buildDateGroup(
    ThemeData theme,
    String dateHeader,
    List<Transaction> transactions,
  ) {
    // Net değişimi hesapla: Gelirler (+), Giderler (-)
    final netTotal = transactions.fold<double>(0, (sum, t) {
      return sum + (t.isExpense ? -t.amount : t.amount);
    });

    final isNegative = netTotal < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateHeader,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              Text(
                '${netTotal > 0 ? '+' : ''}${CurrencyFormatter.format(netTotal, widget.currency)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isNegative ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ),
        ...transactions.map((t) => _buildTransactionTile(theme, t)),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildTransactionTile(ThemeData theme, Transaction transaction) {
    final isExpense = transaction.isExpense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await _confirmDelete(transaction);
      },
      onDismissed: (_) => _deleteTransaction(transaction),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
        ),
      ),
      child: InkWell(
        onTap: () => _openTransactionDetail(transaction),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppColors.getCardShadow(context),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  // Gelirse Yeşil, Giderse Pembe arka plan
                  color: isExpense
                      ? AppColors.lightPink.withValues(alpha: 0.6)
                      : AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    transaction.categoryEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.categoryName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    if (transaction.note.isNotEmpty)
                      Text(
                        transaction.note,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      DateFormat('h:mm a').format(transaction.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Tutar Renklendirme ve İşaret
              Text(
                '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount, widget.currency)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isExpense ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.getSubtle(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No transactions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Try a different search term',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Transaction transaction) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Delete Transaction?'),
          ],
        ),
        content: Text(
          'Delete this ${transaction.categoryName} ${transaction.isExpense ? 'expense' : 'income'} of ${CurrencyFormatter.format(transaction.amount, widget.currency)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.getTextSecondary(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openTransactionDetail(Transaction transaction) async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          transaction: transaction,
          currency: widget.currency,
        ),
      ),
    );

    // Refresh if transaction was updated
    if (result != null && mounted) {
      ref.invalidate(currentCycleTransactionsProvider);
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      final manager = ref.read(transactionManagerServiceProvider);
      await manager.deleteTransaction(
        userId: transaction.userId,
        transaction: transaction,
      );

      ref.invalidate(userSettingsProvider);
      ref.invalidate(currentCycleTransactionsProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(dailyAllowableSpendProvider);
      ref.invalidate(budgetHealthProvider);
      ref.invalidate(currentMonthlySummaryProvider);

      if (mounted) {
        // 4️⃣ REKLAM GÖSTERİMİ (Premium Değilse)
        if (!ref.read(isPremiumProvider)) {
          AdService().showInterstitial(4);
        }

        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('${transaction.categoryEmoji} Transaction deleted'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
