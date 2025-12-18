/// Transaction Detail/Edit Screen
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
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  final String currency;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.currency,
  });

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedCategoryId;
  late DateTime _selectedDate;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
    _noteController = TextEditingController(text: widget.transaction.note);
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = AppConstants.transactionCategories.firstWhere(
      (c) => c['id'] == _selectedCategoryId,
      orElse: () => AppConstants.transactionCategories.first,
    );

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
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Transaction Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isEditing = true);
              },
              color: AppColors.primaryPink,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _confirmDelete,
            color: AppColors.error,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category & Amount Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.getBorder(context)),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    // Category Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.lightPink.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          category['emoji'] as String,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ).animate().scale(duration: 300.ms),

                    const SizedBox(height: AppSpacing.md),

                    // Category Name
                    if (_isEditing)
                      _buildCategorySelector(theme, isDark)
                    else
                      Text(
                        category['name'] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Amount
                    if (_isEditing)
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          prefixText: widget.currency == 'AUD' ? 'A\$' : '\$',
                          prefixStyle: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.getBorder(context)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.getBorder(context)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryPink, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      )
                    else
                      Text(
                        '-${CurrencyFormatter.format(widget.transaction.amount, widget.currency)}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Date & Time Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.getBorder(context)),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: AppColors.primaryPink,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Date & Time',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_isEditing)
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.getBorder(context)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM d, yyyy • h:mm a').format(_selectedDate),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                              Icon(
                                Icons.edit_calendar_rounded,
                                size: 20,
                                color: AppColors.primaryPink,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        DateFormat('MMMM d, yyyy • h:mm a').format(widget.transaction.date),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Note Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.getBorder(context)),
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_rounded,
                          size: 20,
                          color: AppColors.primaryPink,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Note',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_isEditing)
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.getTextPrimary(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)',
                          hintStyle: TextStyle(
                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide(color: AppColors.getBorder(context)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide(color: AppColors.getBorder(context)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                          ),
                        ),
                      )
                    else
                      Text(
                        widget.transaction.note.isEmpty
                          ? 'No note added'
                          : widget.transaction.note,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: widget.transaction.note.isEmpty
                            ? AppColors.getTextSecondary(context).withValues(alpha: 0.5)
                            : AppColors.getTextPrimary(context),
                        ),
                      ),
                  ],
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: PaydayButton(
                        text: 'Cancel',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _isEditing = false;
                            _amountController.text = widget.transaction.amount.toStringAsFixed(2);
                            _noteController.text = widget.transaction.note;
                            _selectedCategoryId = widget.transaction.categoryId;
                            _selectedDate = widget.transaction.date;
                          });
                        },
                        style: PaydayButtonStyle.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: PaydayButton(
                        text: 'Save Changes',
                        onPressed: _saveChanges,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.subtleGray,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryId,
          isExpanded: true,
          dropdownColor: AppColors.getCardBackground(context),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryPink),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
          items: AppConstants.transactionCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id'] as String,
              child: Row(
                children: [
                  Text(
                    category['emoji'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(category['name'] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategoryId = value);
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              surface: AppColors.getCardBackground(context),
              onSurface: AppColors.getTextPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryPink,
                onPrimary: Colors.white,
                surface: AppColors.getCardBackground(context),
                onSurface: AppColors.getTextPrimary(context),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final category = AppConstants.transactionCategories.firstWhere(
        (c) => c['id'] == _selectedCategoryId,
      );

      final updatedTransaction = widget.transaction.copyWith(
        amount: amount,
        categoryId: _selectedCategoryId,
        categoryName: category['name'] as String,
        categoryEmoji: category['emoji'] as String,
        date: _selectedDate,
        note: _noteController.text.trim(),
      );

      final repository = ref.read(transactionRepositoryProvider);
      await repository.updateTransaction(updatedTransaction);

      // Invalidate providers
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
                const Text('Transaction updated successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
        Navigator.pop(context, updatedTransaction);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        backgroundColor: AppColors.getCardBackground(context),
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
          'Delete this ${widget.transaction.categoryName} expense of ${CurrencyFormatter.format(widget.transaction.amount, widget.currency)}?',
          style: TextStyle(color: AppColors.getTextSecondary(context)),
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

    if (result == true && mounted) {
      await _deleteTransaction();
    }
  }

  Future<void> _deleteTransaction() async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.deleteTransaction(widget.transaction.id, widget.transaction.userId);

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
                Text('${widget.transaction.categoryEmoji} Transaction deleted'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transaction: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    }
  }
}

