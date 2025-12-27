import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:payday/core/constants/app_constants.dart';
import 'package:payday/core/services/date_cycle_service.dart';
import 'package:payday/core/theme/app_theme.dart';
import 'package:payday/shared/widgets/payday_button.dart';
import 'package:payday/features/settings/utils/date_picker_dialog.dart' as settings_utils;

class FinancialProfileSheet extends StatefulWidget {
  final double initialIncome;
  final double initialCurrentBalance;
  final String initialPayCycle;
  final DateTime initialNextPayday;
  final String initialCurrency;
  final void Function(
    double income,
    double currentBalance,
    String payCycle,
    DateTime nextPayday,
    String currency,
  ) onSave;

  const FinancialProfileSheet({
    super.key,
    required this.initialIncome,
    required this.initialCurrentBalance,
    required this.initialPayCycle,
    required this.initialNextPayday,
    required this.initialCurrency,
    required this.onSave,
  });

  @override
  State<FinancialProfileSheet> createState() => _FinancialProfileSheetState();
}

class _FinancialProfileSheetState extends State<FinancialProfileSheet> {
  late final TextEditingController _incomeController;
  late final TextEditingController _balanceController;

  late String _selectedPayCycle;
  late DateTime _selectedDate;
  late String _selectedCurrency;

  // This uses the repo standard list from AppConstants.
  late final List<String> _payCycles;

  // Single Source of Truth: currencies are defined in AppConstants.
  late final List<String> _currencies;

  bool _isDateAutoUpdated = false;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController(text: widget.initialIncome.toStringAsFixed(2));
    _balanceController = TextEditingController(text: widget.initialCurrentBalance.toStringAsFixed(2));
    _selectedPayCycle = widget.initialPayCycle;
    _selectedDate = widget.initialNextPayday;
    _selectedCurrency = widget.initialCurrency;
    _payCycles = List<String>.from(AppConstants.payCycleOptions);
    _currencies = List<String>.from(AppConstants.popularCurrencies);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  String _currencyPrefix(String c) {
    switch (c) {
      case 'USD':
        return r'$ ';
      case 'EUR':
        return '€ ';
      case 'TRY':
        return '₺ ';
      case 'GBP':
        return '£ ';
      default:
        return '$c ';
    }
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _adjustForWeekend(DateTime date) {
    final d = _normalizeDate(date);
    if (d.weekday == DateTime.saturday) return d.subtract(const Duration(days: 1));
    if (d.weekday == DateTime.sunday) return d.subtract(const Duration(days: 2));
    return d;
  }

  DateTime _suggestPaydayForCycle(String cycle) {
    final now = _normalizeDate(DateTime.now());

    switch (cycle) {
      case AppConstants.payCycleWeekly:
      case AppConstants.payCycleBiWeekly:
      case AppConstants.payCycleFortnightly:
        // Common payroll convention: Friday.
        var daysUntilFriday = DateTime.friday - now.weekday;
        if (daysUntilFriday <= 0) daysUntilFriday += 7;
        return _adjustForWeekend(now.add(Duration(days: daysUntilFriday)));

      case AppConstants.payCycleSemiMonthly:
        // 15th and last day of month.
        final day15 = DateTime(now.year, now.month, 15);
        final lastDay = DateTime(now.year, now.month + 1, 0);
        if (now.day < 15) return _adjustForWeekend(day15);
        if (now.day < lastDay.day) return _adjustForWeekend(lastDay);
        return _adjustForWeekend(DateTime(now.year, now.month + 1, 15));

      case AppConstants.payCycleMonthly:
      default:
        // Default: end of current month.
        return _adjustForWeekend(DateTime(now.year, now.month + 1, 0));
    }
  }

  void _onPayCycleChanged(String? newCycle) {
    if (newCycle == null || newCycle == _selectedPayCycle) return;

    final suggested = _suggestPaydayForCycle(newCycle);

    setState(() {
      _selectedPayCycle = newCycle;
      _selectedDate = suggested;
      _isDateAutoUpdated = true;
    });

    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isDateAutoUpdated = false);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Switched to $newCycle. Payday auto-adjusted to ${DateFormat('MMM dd').format(suggested)}. Please review your income per cycle.',
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getDaysUntilText() {
    final days = DateCycleService.getDaysRemaining(_selectedDate);
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return '$days days left';
  }

  Future<void> _pickDate() async {
    final picked = await settings_utils.DatePickerDialog.show(
      context: context,
      initialDate: _selectedDate,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _isDateAutoUpdated = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _save() {
    final income = double.tryParse(_incomeController.text) ?? 0.0;
    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Income must be greater than 0.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSave(income, balance, _selectedPayCycle, _selectedDate, _selectedCurrency);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Financial Configuration',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Update your pay cycle, income, currency, and next payday together to keep everything consistent.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Smart adjustments are enabled. Review and save your updated financial profile.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.getTextSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),

            _label('Pay Cycle'),
            _dropdown<String>(
              value: _selectedPayCycle,
              items: _payCycles,
              onChanged: _onPayCycleChanged,
            ),
            const SizedBox(height: 12),

            _label('Currency'),
            _dropdown<String>(
              value: _selectedCurrency,
              items: _currencies,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedCurrency = v);
                HapticFeedback.lightImpact();
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Income (per cycle)'),
                      TextFormField(
                        controller: _incomeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(context, prefix: _currencyPrefix(_selectedCurrency)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Pool Balance'),
                      TextFormField(
                        controller: _balanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _inputDecoration(context, prefix: _currencyPrefix(_selectedCurrency)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _label('Next Payday'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isDateAutoUpdated
                      ? AppColors.primaryPink.withOpacity(0.08)
                      : AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: _isDateAutoUpdated ? AppColors.primaryPink : AppColors.getBorder(context),
                    width: _isDateAutoUpdated ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: _isDateAutoUpdated ? AppColors.primaryPink : AppColors.getTextPrimary(context),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isDateAutoUpdated ? AppColors.primaryPink : null,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceVariant(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDaysUntilText(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            PaydayButton(
              text: 'Save Changes',
              icon: Icons.check_circle_rounded,
              width: double.infinity,
              onPressed: _save,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {String? prefix}) {
    return InputDecoration(
      prefixText: prefix,
      filled: true,
      fillColor: AppColors.getCardBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: theme.cardColor,
          items: items
              .map(
                (v) => DropdownMenuItem<T>(
                  value: v,
                  child: Text(v.toString()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
