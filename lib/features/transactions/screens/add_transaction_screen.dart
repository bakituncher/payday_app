/// Add Transaction Screen - Bottom Sheet - Premium Industry-Grade Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/models/transaction.dart';
import 'package:payday/core/providers/repository_providers.dart';
import 'package:payday/core/utils/currency_formatter.dart';
import 'package:payday/features/home/providers/home_providers.dart';
import 'package:payday/features/insights/providers/monthly_summary_providers.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:payday/core/services/ad_service.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _uuid = const Uuid();

  String? _selectedCategoryId;
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
                              gradient: AppColors.pinkGradient,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPink.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Add Expense',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: AppSpacing.xl),

                  // Amount Input
                  Text(
                    'Amount',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(context),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.getBorder(context)),
                    ),
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimary(context),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,])?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          alignment: Alignment.centerLeft,
                          width: 60,
                          child: Text(
                            CurrencyFormatter.getSymbol(userSettings?.currency ?? 'USD'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.lg,
                        ),
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
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 150.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppSpacing.xl),

                  // Category Selection
                  Text(
                    'Category',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(context),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 200.ms),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: AppConstants.transactionCategories
                        .where((category) => category['id'] != AppConstants.savingsCategoryId) // 🔒 Hide system category
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final isSelected = _selectedCategoryId == category['id'];
                      return _buildCategoryChip(
                        category['emoji']!,
                        category['name']!,
                        category['id']!,
                        isSelected,
                        theme,
                        isDark,
                      )
                          .animate()
                          .fadeIn(duration: 200.ms, delay: (250 + index * 30).ms)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
                    }).toList(),
                  ),

                  if (_selectedCategoryId == null && _formKey.currentState?.validate() == false)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'Please select a category',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  // Note Input (Optional)
                  Text(
                    'Note (Optional)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(context),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 350.ms),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.getBorder(context)),
                    ),
                    child: TextFormField(
                      controller: _noteController,
                      maxLength: AppConstants.maxTransactionNameLength,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.getTextSecondary(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        counterStyle: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Submit Button
                  PaydayButton(
                    text: 'Add Expense',
                    onPressed: _isLoading ? null : _handleSubmit,
                    isLoading: _isLoading,
                    width: double.infinity,
                    icon: Icons.check_rounded,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 450.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String emoji,
    String name,
    String id,
    bool isSelected,
    ThemeData theme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCategoryId = _selectedCategoryId == id ? null : id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryPink.withValues(alpha: 0.2) : AppColors.lightPink)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.xs),
            Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryPink
                    : (isDark ? AppColors.darkTextPrimary : AppColors.darkCharcoal),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.primaryPink,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Validate category selection
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amountText = _amountController.text.replaceAll(',', '.');
      final amount = double.parse(amountText);
      final userId = ref.read(currentUserIdProvider);
      final category = AppConstants.transactionCategories
          .firstWhere((c) => c['id'] == _selectedCategoryId);

      final transaction = Transaction(
        id: _uuid.v4(),
        userId: userId,
        amount: amount,
        categoryId: category['id']!,
        categoryName: category['name']!,
        categoryEmoji: category['emoji']!,
        date: DateTime.now(),
        note: _noteController.text.trim(),
        isExpense: true,
      );

      // Process atomically via TransactionManagerService (transaction + balance)
      final transactionManager = ref.read(transactionManagerServiceProvider);
      await transactionManager.processTransaction(
        userId: userId,
        transaction: transaction,
      );

      // Refresh data
      ref.invalidate(userSettingsProvider);
      ref.invalidate(currentCycleTransactionsProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(dailyAllowableSpendProvider);
      ref.invalidate(budgetHealthProvider);
      ref.invalidate(currentMonthlySummaryProvider); // Update monthly summary

      if (mounted) {
        // 1️⃣ REKLAM GÖSTERİMİ (Harcama Ekleme)
        AdService().showInterstitial(1);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category['emoji']} Expense added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding expense: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
