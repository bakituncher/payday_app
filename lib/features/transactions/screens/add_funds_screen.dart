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

/// Income source options
const List<Map<String, String>> incomeSources = [
  {'name': 'Bonus', 'emoji': '🎁', 'id': 'bonus'},
  {'name': 'Gift', 'emoji': '💝', 'id': 'gift'},
  {'name': 'Freelance', 'emoji': '💻', 'id': 'freelance'},
  {'name': 'Side Hustle', 'emoji': '🚀', 'id': 'side_hustle'},
  {'name': 'Sold Item', 'emoji': '🏷', 'id': 'sold_item'},
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
  final FocusNode _amountFocusNode = FocusNode();

  String? _selectedSourceId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Otomatik odaklanma
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

                      // HERO: Tutar Girişi (Yeşil Tema)
                      _buildHeroAmountInput(theme, isDark, currencySymbol),

                      const SizedBox(height: AppSpacing.xl),

                      // Kaynak Seçimi Başlığı
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Income Source',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.getTextSecondary(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: AppSpacing.md),

                      // Yatay Kaynak Seçici
                      _buildHorizontalSourceSelector(theme, isDark),

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
                text: 'Add to Pool',
                onPressed: _isLoading ? null : _handleSubmit,
                isLoading: _isLoading,
                width: double.infinity,
                icon: Icons.add_circle_outline_rounded,
                // backgroundColor parametresini kaldırdım, PaydayButton default rengini kullansın
                // veya projeniz destekliyorsa buraya AppColors.success verebilirsiniz.
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
                'Add Income',
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
              color: AppColors.success, // Gelir olduğu için YEŞİL
              fontSize: 48,
            ),
            cursorColor: AppColors.success,
            cursorWidth: 3,
            cursorRadius: const Radius.circular(2),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,])?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixText: '$currencySymbol ',
              prefixStyle: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.success.withValues(alpha: 0.3),
                fontSize: 48,
              ),
              hintText: '0',
              hintStyle: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.success.withValues(alpha: 0.2),
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

  Widget _buildHorizontalSourceSelector(ThemeData theme, bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: incomeSources.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final source = incomeSources[index];
          final isSelected = _selectedSourceId == source['id'];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedSourceId = source['id']);
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
                          ? AppColors.success
                          : (isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray),
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        source['emoji']!,
                        style: TextStyle(fontSize: isSelected ? 30 : 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    source['name']!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.success
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
                  maxLines: 1, // Single line looks better in this grouped style
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g. Birthday gift...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
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
    // Tutar boşsa titret
    if (_amountController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    // Kaynak seçilmediyse uyar
    if (_selectedSourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a source'),
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
      final source = incomeSources.firstWhere((s) => s['id'] == _selectedSourceId);

      final transaction = Transaction(
        id: _uuid.v4(),
        userId: userId,
        amount: amount,
        categoryId: source['id']!,
        categoryName: source['name']!,
        categoryEmoji: source['emoji']!,
        date: DateTime.now(), // İstenildiği gibi, ekstra tarih seçimi yok
        note: _noteController.text.trim(),
        isExpense: false, // GELİR
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
                Text('Funds added successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
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