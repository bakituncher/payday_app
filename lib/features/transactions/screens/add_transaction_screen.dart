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
  final FocusNode _amountFocusNode = FocusNode();

  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında direkt tutara odaklan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final userSettings = ref.watch(userSettingsProvider).value;
    final isDark = theme.brightness == Brightness.dark;
    final currencySymbol = CurrencyFormatter.getSymbol(userSettings?.currency ?? 'USD');

    // Klavye yüksekliği
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          // 1. Header & Handle
          _buildHeader(context),

          // 2. Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      // HERO: Tutar Girişi (Devasa ve Ortada)
                      _buildHeroAmountInput(theme, isDark, currencySymbol),

                      const SizedBox(height: AppSpacing.xl),

                      // Kategori Seçimi Başlığı
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Category',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextSecondary(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: AppSpacing.md),

                      // Yatay Kategori Seçici
                      _buildHorizontalCategorySelector(theme, isDark),

                      const SizedBox(height: AppSpacing.xl),

                      // Not Girişi
                      _buildNoteInput(theme, isDark, context),

                      // Klavye boşluğu
                      SizedBox(height: bottomInset > 0 ? AppSpacing.md : AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Buton (Klavye üstüne yapışır)
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: bottomInset > 0 ? bottomInset + AppSpacing.sm : mediaQuery.padding.bottom + AppSpacing.lg,
              top: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context),
              border: Border(
                top: BorderSide(
                  color: AppColors.getBorder(context).withValues(alpha: 0.5),
                ),
              ),
            ),
            child: SizedBox(
              height: 56,
              child: PaydayButton(
                text: 'Add Expense',
                onPressed: _isLoading ? null : _handleSubmit,
                isLoading: _isLoading,
                width: double.infinity,
                icon: Icons.check_circle_rounded,
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutQuart),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.getBorder(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadius.round),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
                color: AppColors.getTextSecondary(context),
              ),
              Text(
                'New Expense',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 48), // Dengelemek için boşluk
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.getBorder(context).withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildHeroAmountInput(ThemeData theme, bool isDark, String currencySymbol) {
    return Column(
      children: [
        Text(
          'Amount',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
          ),
        ).animate().fadeIn(),
        IntrinsicWidth(
          child: TextFormField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.getTextPrimary(context),
              fontSize: 48,
            ),
            cursorColor: AppColors.primaryPink,
            cursorWidth: 3,
            cursorRadius: const Radius.circular(2),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,])?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixText: '$currencySymbol ',
              prefixStyle: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                fontSize: 48,
              ),
              hintText: '0',
              hintStyle: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.2),
                fontSize: 48,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final amount = double.tryParse(value.replaceAll(',', '.'));
              if (amount == null || amount <= 0) return '';
              return null;
            },
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      ],
    );
  }

  Widget _buildHorizontalCategorySelector(ThemeData theme, bool isDark) {
    final categories = AppConstants.transactionCategories
        .where((c) => c['id'] != AppConstants.savingsCategoryId)
        .toList();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategoryId == category['id'];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategoryId = category['id']);
            },
            child: AnimatedContainer(
              duration: 200.ms,
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: 200.ms,
                    width: isSelected ? 68 : 60,
                    height: isSelected ? 68 : 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryPink
                          : (isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray),
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        category['emoji']!,
                        style: TextStyle(fontSize: isSelected ? 30 : 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    category['name']!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryPink
                          : AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (100 + (index * 50)).ms).slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildNoteInput(ThemeData theme, bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.getTextSecondary(context),
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5) : AppColors.subtleGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.getBorder(context).withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.edit_note_rounded, size: 22, color: AppColors.getTextSecondary(context)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _noteController,
                  maxLength: AppConstants.maxTransactionNameLength,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Add a note... (Optional)',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    counterText: "",
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    // Tutar boşsa hafif titret
    if (_amountController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    // Kategori seçilmediyse uyar
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

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
        date: DateTime.now(), // Orijinal mantık: Şu anki zaman
        note: _noteController.text.trim(),
        isExpense: true,
      );

      final transactionManager = ref.read(transactionManagerServiceProvider);
      await transactionManager.processTransaction(
        userId: userId,
        transaction: transaction,
      );

      // Provider'ları yenile
      ref.invalidate(userSettingsProvider);
      ref.invalidate(currentCycleTransactionsProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(dailyAllowableSpendProvider);
      ref.invalidate(budgetHealthProvider);
      ref.invalidate(currentMonthlySummaryProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}