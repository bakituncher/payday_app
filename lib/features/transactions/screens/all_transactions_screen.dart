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
import 'package:intl/intl.dart';

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
          color: AppColors.darkCharcoal,
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
                color: AppColors.darkCharcoal,
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
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mediumGray),
                filled: true,
                fillColor: AppColors.subtleGray,
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
    final total = transactions.fold<double>(0, (sum, t) => sum + t.amount);

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
                  color: AppColors.mediumGray,
                ),
              ),
              Text(
                '-${CurrencyFormatter.format(total, widget.currency)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
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
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightPink.withOpacity(0.6),
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
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  if (transaction.note.isNotEmpty)
                    Text(
                      transaction.note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    DateFormat('h:mm a').format(transaction.date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${CurrencyFormatter.format(transaction.amount, widget.currency)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
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
              color: AppColors.subtleGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No transactions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Try a different search term',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
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
                color: AppColors.error.withOpacity(0.1),
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
          'Delete this ${transaction.categoryName} expense of ${CurrencyFormatter.format(transaction.amount, widget.currency)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.mediumGray)),
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

  Future<void> _deleteTransaction(Transaction transaction) async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.deleteTransaction(transaction.id);

      ref.invalidate(currentCycleTransactionsProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(dailyAllowableSpendProvider);
      ref.invalidate(budgetHealthProvider);
      ref.invalidate(currentMonthlySummaryProvider);

      if (mounted) {
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

