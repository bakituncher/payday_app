/// Add Funds Screen - Bottom Sheet - Manual Income Entry
/// Allows users to manually add funds (income) to their Pool
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/services/ad_service.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';

/// Income source options for Add Funds
const List<Map<String, String>> incomeSources = [
  {'name': 'Bonus', 'emoji': '🎁', 'id': 'bonus'},
  {'name': 'Gift', 'emoji': '💝', 'id': 'gift'},
  {'name': 'Freelance', 'emoji': '💻', 'id': 'freelance'},
  {'name': 'Side Hustle', 'emoji': '🚀', 'id': 'side_hustle'},
  {'name': 'Sold Item', 'emoji': '🏷️', 'id': 'sold_item'},
  {'name': 'Refund', 'emoji': '💸', 'id': 'refund'},
  {'name': 'Investment', 'emoji': '📈', 'id': 'investment'},
  {'name': 'Other Income', 'emoji': '💰', 'id': 'other_income'},
];

class AddFundsScreen extends ConsumerStatefulWidget {
  const AddFundsScreen({super.key});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _uuid = const Uuid();

  String? _selectedSourceId;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final userSettings = ref.watch(userSettingsProvider).value;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: isDark ? Border(
          top: BorderSide(color: AppColors.darkBorder, width: 1),
        ) : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.getBorder(context),
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.success,
                                  AppColors.success.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Add Funds',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        color: AppColors.getTextSecondary(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Amount Input
                  Text(
                    'Amount',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                    decoration: InputDecoration(
                      prefixText: userSettings != null
                          ? '${CurrencyFormatter.getSymbol(userSettings.currency)} '
                          : '\$ ',
                      prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                      hintText: '0.00',
                      hintStyle: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                      ),
                      filled: true,
                      fillColor: AppColors.success.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                          color: AppColors.success,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Income Source Selection
                  Text(
                    'Source',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: incomeSources.map((source) {
                      final isSelected = _selectedSourceId == source['id'];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedSourceId = source['id']);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.getSubtle(context),
                            borderRadius: BorderRadius.circular(AppRadius.round),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.success
                                  : AppColors.getBorder(context),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                source['emoji']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                source['name']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.success
                                      : AppColors.getTextPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Note Input
                  Text(
                    'Note (Optional)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.getTextPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., Birthday gift from grandma',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: AppColors.getSubtle(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Add Funds Button
                  PaydayButton(
                    text: 'Add to Pool',
                    icon: Icons.add_rounded,
                    width: double.infinity,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _addFunds,
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addFunds() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a source'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      final source = incomeSources.firstWhere((s) => s['id'] == _selectedSourceId);

      final transaction = Transaction(
        id: _uuid.v4(),
        userId: userId,
        amount: double.parse(_amountController.text),
        categoryId: _selectedSourceId!,
        categoryName: source['name']!,
        categoryEmoji: source['emoji']!,
        date: DateTime.now(),
        note: _noteController.text.trim(),
        isExpense: false, // This is INCOME, not expense
      );

      // Use TransactionManagerService to process (adds to history + updates balance)
      final transactionManager = ref.read(transactionManagerServiceProvider);
      await transactionManager.processTransaction(
        userId: userId,
        transaction: transaction,
      );

      // Refresh providers
      ref.invalidate(userSettingsProvider);
      ref.invalidate(currentCycleTransactionsProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(currentMonthlySummaryProvider);

      if (mounted) {
        // 1️⃣ REKLAM GÖSTERİMİ (Premium Değilse)
        if (!ref.read(isPremiumProvider)) {
          AdService().showInterstitial(1);
        }

        HapticFeedback.heavyImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text('${source['emoji']} ${CurrencyFormatter.format(double.parse(_amountController.text), ref.read(userSettingsProvider).value?.currency ?? 'USD')} added to your pool!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
